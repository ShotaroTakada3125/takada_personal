import { KeywordDefinition, SubtaskSuggestion } from '../types/task';

export const KEYWORD_DICTIONARY: KeywordDefinition[] = [
  {
    keyword: '掃除',
    subtasks: [
      { title: '部屋の片付け', difficulty: 2 },
      { title: 'ゴミ出し', difficulty: 1 },
      { title: '床拭き', difficulty: 3 },
    ],
  },
  {
    keyword: '旅行',
    subtasks: [
      { title: 'チケット確認', difficulty: 2 },
      { title: 'ホテル予約', difficulty: 2 },
      { title: 'パッキングリスト作成', difficulty: 1 },
      { title: 'スーツケース準備', difficulty: 2 },
    ],
  },
  {
    keyword: '運動',
    subtasks: [
      { title: 'ストレッチ', difficulty: 1 },
      { title: '5分ランニング', difficulty: 2 },
      { title: '筋トレ', difficulty: 3 },
    ],
  },
  {
    keyword: '美容院',
    subtasks: [
      { title: '予約の確認', difficulty: 1 },
      { title: '持ち物チェック', difficulty: 1 },
      { title: '移動時間確保', difficulty: 1 },
    ],
  },
  {
    keyword: '病院',
    subtasks: [
      { title: '予約の確認', difficulty: 1 },
      { title: '持ち物チェック（保険証など）', difficulty: 1 },
      { title: '移動時間確保', difficulty: 1 },
    ],
  },
  {
    keyword: '銀行',
    subtasks: [
      { title: '予約の確認', difficulty: 1 },
      { title: '必要書類の準備', difficulty: 1 },
      { title: '営業時間確認', difficulty: 1 },
    ],
  },
  {
    keyword: '役所',
    subtasks: [
      { title: '必要書類確認', difficulty: 2 },
      { title: '持ち物チェック', difficulty: 1 },
      { title: '営業時間確認', difficulty: 1 },
    ],
  },
  {
    keyword: '買い物',
    subtasks: [
      { title: 'リスト作成', difficulty: 1 },
      { title: '予算決定', difficulty: 1 },
      { title: '時間確保', difficulty: 1 },
    ],
  },
  {
    keyword: '勉強',
    subtasks: [
      { title: '目標設定', difficulty: 1 },
      { title: '教材準備', difficulty: 1 },
      { title: '学習時間確保', difficulty: 2 },
    ],
  },
];

export function extractKeywordMatches(text: string): SubtaskSuggestion[] {
  const lowerText = text.toLowerCase();
  const matches: SubtaskSuggestion[] = [];

  for (const definition of KEYWORD_DICTIONARY) {
    if (lowerText.includes(definition.keyword.toLowerCase())) {
      matches.push(...definition.subtasks);
    }
  }

  // 重複を削除
  const uniqueMatches = Array.from(
    new Map(matches.map((m) => [m.title, m])).values()
  );

  return uniqueMatches;
}

export function hasKeywordMatch(text: string): boolean {
  return extractKeywordMatches(text).length > 0;
}
