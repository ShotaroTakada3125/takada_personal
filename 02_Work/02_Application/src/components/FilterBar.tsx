import React from 'react';
import { FilterOptions, TaskStatus } from '../types/task';

interface FilterBarProps {
  filters: FilterOptions;
  onFilterChange: (filters: FilterOptions) => void;
}

const MOOD_OPTIONS = [
  { value: '集中', label: '🎯 集中' },
  { value: '疲れ', label: '😴 疲れ' },
  { value: 'サクッと', label: '⚡ サクッと' },
];

const LOCATION_OPTIONS = [
  { value: '家', label: '🏠 家' },
  { value: '外出先', label: '🌐 外出先' },
  { value: 'オフィス', label: '💼 オフィス' },
];

const STATUS_OPTIONS: { value: TaskStatus | null; label: string }[] = [
  { value: null, label: 'すべて' },
  { value: 'todo', label: '📝 ToDo' },
  { value: 'wip', label: '⏳ 進行中' },
  { value: 'done', label: '✅ 完了' },
];

export const FilterBar: React.FC<FilterBarProps> = ({
  filters,
  onFilterChange,
}) => {
  return (
    <div className="bg-white rounded-lg p-4 border border-gray-200 space-y-4">
      <div>
        <h3 className="text-sm font-semibold text-gray-700 mb-2">気分</h3>
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() =>
              onFilterChange({ ...filters, mood: null })
            }
            className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
              filters.mood === null
                ? 'bg-indigo-500 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            すべて
          </button>
          {MOOD_OPTIONS.map((option) => (
            <button
              key={option.value}
              onClick={() =>
                onFilterChange({
                  ...filters,
                  mood: filters.mood === option.value ? null : option.value,
                })
              }
              className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                filters.mood === option.value
                  ? 'bg-indigo-500 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      <div>
        <h3 className="text-sm font-semibold text-gray-700 mb-2">場所</h3>
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() =>
              onFilterChange({ ...filters, location: null })
            }
            className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
              filters.location === null
                ? 'bg-indigo-500 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            すべて
          </button>
          {LOCATION_OPTIONS.map((option) => (
            <button
              key={option.value}
              onClick={() =>
                onFilterChange({
                  ...filters,
                  location: filters.location === option.value ? null : option.value,
                })
              }
              className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                filters.location === option.value
                  ? 'bg-indigo-500 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      <div>
        <h3 className="text-sm font-semibold text-gray-700 mb-2">ステータス</h3>
        <div className="flex flex-wrap gap-2">
          {STATUS_OPTIONS.map((option) => (
            <button
              key={option.value}
              onClick={() =>
                onFilterChange({ ...filters, status: option.value })
              }
              className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                filters.status === option.value
                  ? 'bg-indigo-500 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};
