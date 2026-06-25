## テスト1

お題：「3月までにTOEICで800点取りたい。今は600点。」

結果：

```json
[
  {
    "id": 1,
    "task": "現状分析と公式問題集による模試実施",
    "description": "最新の公式問題集を解き、現在のリスニング・リーディング各セクションの弱点（パート別正答率）を特定する。",
    "depends_on": [],
    "logical_importance": 5,
    "estimated_weight": 2
  },
  {
    "id": 2,
    "task": "目標スコア達成のための学習計画策定",
    "description": "3月までの残り期間から逆算し、週単位の学習時間（単語、文法、精読、速読、リスニング）を割り振る。",
    "depends_on": [1],
    "logical_importance": 4,
    "estimated_weight": 2
  },
  {
    "id": 3,
    "task": "金フレ等の頻出英単語2000語の習得",
    "description": "800点レベルに必要な語彙を定着させる。毎日100〜200語の復習サイクルを回す。",
    "depends_on": [],
    "logical_importance": 5,
    "estimated_weight": 4
  },
  {
    "id": 4,
    "task": "英文法（Part 5・6対策）の総復習",
    "description": "600点から800点へのステップアップに不可欠な高校レベルの文法を完璧にし、Part 5を10分以内に解く訓練をする。",
    "depends_on": [1],
    "logical_importance": 4,
    "estimated_weight": 3
  },
  {
    "id": 5,
    "task": "リスニングのシャドウイング訓練",
    "description": "Part 3・4を対象に、スクリプトを見ずに正確に発音・追唱できるまで繰り返しトレーニングし、耳を慣らす。",
    "depends_on": [1],
    "logical_importance": 4,
    "estimated_weight": 4
  },
  {
    "id": 6,
    "task": "リーディングの精読と速読トレーニング",
    "description": "Part 7の長文を返り読みせず左から右へ読む訓練を行い、1分間に150語（WPM150）以上の読解速度を目指す。",
    "depends_on": [4],
    "logical_importance": 4,
    "estimated_weight": 5
  },
  {
    "id": 7,
    "task": "本番形式の時間配分シミュレーション",
    "description": "2時間通しで模試を解き、最後まで解ききるための時間管理（各パートの目標終了時刻）を身体に叩き込む。",
    "depends_on": [3, 4, 5, 6],
    "logical_importance": 5,
    "estimated_weight": 3
  },
  {
    "id": 8,
    "task": "TOEIC公開テストの申し込みと受験",
    "description": "3月の試験日を確認し、締め切り前に申し込みを完了させる。当日はシミュレーション通りに解答する。",
    "depends_on": [7],
    "logical_importance": 5,
    "estimated_weight": 1
  }
]
```


## テスト2

お題：「大学の友人と3人で沖縄へ卒業旅行に行きたい。予算は5万。」
結果：
```json
[
  {
    "id": 1,
    "task": "旅行日程の確定と航空券予約",
    "description": "LCC（格安航空会社）のセールや早期割引を利用し、往復2万円以内を目指してフライトを確保する。",
    "depends_on": [],
    "logical_importance": 5,
    "estimated_weight": 3
  },
  {
    "id": 2,
    "task": "宿泊先の選定と予約",
    "description": "1人1泊5,000円以下を目標に、ゲストハウスや民泊（Airbnb）、素泊まりのビジネスホテルを3人で1室予約する。",
    "depends_on": [1],
    "logical_importance": 4,
    "estimated_weight": 3
  },
  {
    "id": 3,
    "task": "現地交通手段の確保（レンタカーまたはバス）",
    "description": "3人での移動効率を考え格安レンタカーを予約、または路線バス周遊パスの料金を比較検討する。",
    "depends_on": [2],
    "logical_importance": 4,
    "estimated_weight": 2
  },
  {
    "id": 4,
    "task": "低予算アクティビティのリストアップ",
    "description": "公営ビーチ、国際通りの散策、首里城公園など、入場料の安い、または無料の観光スポットを抽出する。",
    "depends_on": [],
    "logical_importance": 3,
    "estimated_weight": 2
  },
  {
    "id": 5,
    "task": "食事プランの作成と予算配分",
    "description": "沖縄そばやタコライスなどのB級グルメを中心に、1日あたりの食費を3,000円〜4,000円に抑える計画を立てる。",
    "depends_on": [],
    "logical_importance": 3,
    "estimated_weight": 3
  },
  {
    "id": 6,
    "task": "最終収支シミュレーション",
    "description": "固定費（交通・宿泊）と変動費（飲食・観光）を合算し、予備費を含めて5万円以内に収まるか確認する。",
    "depends_on": [1, 2, 3, 4, 5],
    "logical_importance": 5,
    "estimated_weight": 2
  }
]
```