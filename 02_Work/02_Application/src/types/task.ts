export type TaskStatus = 'todo' | 'wip' | 'done';

export interface Task {
  id: string;
  title: string;
  base_difficulty: number; // 1-5
  current_difficulty: number; // 1-5
  location: string;
  mood_category: string;
  is_recurring: boolean;
  cycle: number; // 日単位の周期
  status: TaskStatus;
  createdAt: string; // ISO 8601 format
}

export interface FilterOptions {
  mood: string | null;
  location: string | null;
  status: TaskStatus | null;
}

export interface SubtaskSuggestion {
  title: string;
  difficulty?: number;
}

export interface KeywordDefinition {
  keyword: string;
  subtasks: SubtaskSuggestion[];
}
