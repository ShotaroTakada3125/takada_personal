#!/usr/bin/env python3
import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import List, Optional

SCREENSHOT_RE = re.compile(r"^スクリーンショット\s(\d{4}-\d{2}-\d{2})\s(\d{2}\.\d{2}\.\d{2})(?:\.png)?$")
STATE_FILE = ".rename_metrics_state.json"
DEFAULT_CONFIG_PATH = Path(__file__).with_name("rename_metrics_config.json")

DEFAULT_METRIC_SUFFIXES = [
    "口座開設_ECS_CPUUtilization.png",
    "口座開設_ECS_MemoryUtilization.png",
    "口座開設_DB_CPUUtilization.png",
    "口座開設_DB_FreeableMemory.png",
    "シンプル等_ECS_CPUUtilization.png",
    "シンプル等_ECS_MemoryUtilization.png",
    "シンプル等_DB_CPUUtilization.png",
    "シンプル等_DB_FreeableMemory.png",
]


@dataclass
class Shot:
    path: Path
    date_str: str
    time_str: str

    @property
    def sort_key(self) -> datetime:
        return datetime.strptime(f"{self.date_str} {self.time_str}", "%Y-%m-%d %H.%M.%S")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "スクリーンショットを古い順に、固定のメトリクス名へリネームします。"
            "対象は 'スクリーンショット YYYY-MM-DD HH.MM.SS'（拡張子あり/なし両対応）です。"
        )
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=DEFAULT_CONFIG_PATH,
        help=f"設定ファイル(JSON)。未指定時は {DEFAULT_CONFIG_PATH}",
    )
    parser.add_argument(
        "period_pos",
        nargs="?",
        choices=["auto", "am", "pm"],
        help="接頭辞の短縮指定（位置引数）。例: auto",
    )
    parser.add_argument(
        "date_pos",
        nargs="?",
        help="対象日付の短縮指定（位置引数）。例: 20260608",
    )
    parser.add_argument(
        "--folder",
        type=Path,
        default=None,
        help="対象フォルダ。未指定時は設定ファイル内 target_folder を使用",
    )
    parser.add_argument(
        "--period",
        choices=["auto", "am", "pm"],
        default=None,
        help="接頭辞の選択。未指定時は auto（対象日付の午前ファイル有無で自動判定）",
    )
    parser.add_argument(
        "--date",
        help="対象日付 (YYYY-MM-DD または YYYYMMDD)。未指定時は候補内の最新日付",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="実際には変更せず、変更予定のみ表示",
    )
    parser.add_argument(
        "--use-state",
        action="store_true",
        help="状態ファイルを使って前回処理済みより新しいものだけ対象にする",
    )
    return parser.parse_args()


def load_config(config_path: Path) -> dict:
    if not config_path.exists():
        raise FileNotFoundError(f"設定ファイルが存在しません: {config_path}")

    try:
        config = json.loads(config_path.read_text(encoding="utf-8"))
    except Exception as e:
        raise ValueError(f"設定ファイルをJSONとして読めません: {e}") from e

    if not isinstance(config, dict):
        raise ValueError("設定ファイルのトップレベルはオブジェクトである必要があります。")

    target_folder = config.get("target_folder")
    rename_order = config.get("rename_order")

    if not isinstance(target_folder, str) or not target_folder.strip():
        raise ValueError("target_folder は空でない文字列で指定してください。")

    if not isinstance(rename_order, list) or len(rename_order) != 8:
        raise ValueError("rename_order は8件の配列で指定してください。")

    if not all(isinstance(x, str) and x.strip() for x in rename_order):
        raise ValueError("rename_order の各要素は空でない文字列で指定してください。")

    return {
        "target_folder": Path(target_folder),
        "rename_order": rename_order,
    }


def detect_period(folder: Path, preferred: str, target_date: str) -> str:
    if preferred == "am":
        return "午前"
    if preferred == "pm":
        return "午後"

    # 日付ごとのフォルダ運用を前提に、対象日付に対して午前ファイルの有無で判定する。
    # 「午前_* があるなら午後、なければ午前」を採用。
    _ = target_date
    has_am = any(folder.glob("午前_*.png"))
    return "午後" if has_am else "午前"


def normalize_date_arg(raw: str) -> str:
    if re.fullmatch(r"\d{4}-\d{2}-\d{2}", raw):
        return raw
    if re.fullmatch(r"\d{8}", raw):
        return f"{raw[0:4]}-{raw[4:6]}-{raw[6:8]}"
    raise ValueError("--date は YYYY-MM-DD または YYYYMMDD で指定してください。")


def load_shots(folder: Path) -> List[Shot]:
    shots: List[Shot] = []
    for p in folder.iterdir():
        if not p.is_file():
            continue
        m = SCREENSHOT_RE.match(p.name)
        if not m:
            continue
        shots.append(Shot(path=p, date_str=m.group(1), time_str=m.group(2)))
    return sorted(shots, key=lambda s: s.sort_key)


def read_state(folder: Path) -> Optional[datetime]:
    state_path = folder / STATE_FILE
    if not state_path.exists():
        return None
    try:
        data = json.loads(state_path.read_text(encoding="utf-8"))
        raw = data.get("last_processed")
        if not raw:
            return None
        return datetime.strptime(raw, "%Y-%m-%d %H.%M.%S")
    except Exception:
        return None


def write_state(folder: Path, value: datetime) -> None:
    state_path = folder / STATE_FILE
    payload = {"last_processed": value.strftime("%Y-%m-%d %H.%M.%S")}
    state_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def main() -> int:
    args = parse_args()

    try:
        config = load_config(args.config)
    except Exception as e:
        print(f"[ERROR] {e}")
        return 1

    folder = args.folder or config["target_folder"]
    metric_suffixes = config["rename_order"]
    period = args.period if args.period is not None else (args.period_pos or "auto")
    date_raw = args.date if args.date is not None else args.date_pos

    if not folder.exists() or not folder.is_dir():
        print(f"[ERROR] フォルダが存在しません: {folder}")
        return 1

    shots = load_shots(folder)
    if not shots:
        print("[ERROR] 対象スクリーンショットが見つかりません。")
        return 1

    if date_raw:
        try:
            target_date = normalize_date_arg(date_raw)
        except ValueError as e:
            print(f"[ERROR] {e}")
            return 1
    else:
        target_date = max(s.date_str for s in shots)
    shots = [s for s in shots if s.date_str == target_date]

    if args.use_state:
        last_processed = read_state(folder)
        if last_processed is not None:
            shots = [s for s in shots if s.sort_key > last_processed]

    if len(shots) < 8:
        print(f"[ERROR] 候補が不足しています。対象日付={target_date}, 候補数={len(shots)}")
        return 1

    # 指定日付の最新8件を取り出し、その中で古い順に並べる。
    selected = sorted(shots, key=lambda s: s.sort_key)[-8:]
    target_period = detect_period(folder, period, target_date)

    rename_pairs = []
    date_prefix = target_date.replace('-', '')
    for idx, shot in enumerate(selected):
        new_name = f"{date_prefix}_{target_period}_{metric_suffixes[idx]}"
        dst = folder / new_name
        rename_pairs.append((shot.path, dst))

    # 既存ファイルと衝突するなら停止
    for src, dst in rename_pairs:
        if dst.exists() and dst.resolve() != src.resolve():
            print(f"[ERROR] 既存ファイルと衝突します: {dst.name}")
            return 1

    print(f"対象フォルダ: {folder}")
    print(f"対象日付: {target_date}")
    print(f"接頭辞: {target_period}")
    print("リネーム計画:")
    for src, dst in rename_pairs:
        print(f"  {src.name} -> {dst.name}")

    if args.dry_run:
        print("[DRY-RUN] 実際の変更は行っていません。")
        return 0

    for src, dst in rename_pairs:
        src.rename(dst)

    if args.use_state:
        write_state(folder, selected[-1].sort_key)

    print("[OK] リネーム完了")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
