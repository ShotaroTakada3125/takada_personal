import React, { useState } from 'react';
import { X, Plus } from 'lucide-react';
import { SubtaskSuggestion } from '../types/task';

interface KeywordModalProps {
  isOpen: boolean;
  suggestions: SubtaskSuggestion[];
  mainTaskTitle: string;
  onClose: () => void;
  onAddSubtasks: (subtasks: SubtaskSuggestion[]) => void;
  onAddMainTask: (title: string) => void;
}

export const KeywordModal: React.FC<KeywordModalProps> = ({
  isOpen,
  suggestions,
  mainTaskTitle,
  onClose,
  onAddSubtasks,
  onAddMainTask,
}) => {
  const [selectedSubtasks, setSelectedSubtasks] = useState<
    Set<string>
  >(new Set());

  if (!isOpen) return null;

  const handleToggleSubtask = (title: string) => {
    const newSelected = new Set(selectedSubtasks);
    if (newSelected.has(title)) {
      newSelected.delete(title);
    } else {
      newSelected.add(title);
    }
    setSelectedSubtasks(newSelected);
  };

  const handleConfirm = () => {
    // Add main task first
    if (mainTaskTitle.trim()) {
      onAddMainTask(mainTaskTitle);
    }

    // Then add selected subtasks
    const tasksToAdd = suggestions.filter((s) =>
      selectedSubtasks.has(s.title)
    );
    if (tasksToAdd.length > 0) {
      onAddSubtasks(tasksToAdd);
    }

    handleClose();
  };

  const handleClose = () => {
    setSelectedSubtasks(new Set());
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black bg-opacity-20"
        onClick={handleClose}
      />

      {/* Modal */}
      <div className="relative bg-white rounded-lg shadow-lg max-w-[500px] w-full mx-4 p-6 z-10">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">
            タスク案を提案
          </h2>
          <button
            onClick={handleClose}
            className="p-1 hover:bg-gray-100 rounded transition-colors"
          >
            <X className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        {/* Main task display */}
        <div className="mb-6 p-4 bg-indigo-50 rounded-lg border border-indigo-200">
          <p className="text-sm text-gray-600 mb-1">メインタスク</p>
          <p className="text-lg font-semibold text-indigo-900">
            {mainTaskTitle}
          </p>
        </div>

        {/* Subtask suggestions */}
        <div className="mb-6">
          <h3 className="text-sm font-semibold text-gray-700 mb-3">
            関連するサブタスク
          </h3>
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {suggestions.map((suggestion) => (
              <label
                key={suggestion.title}
                className="flex items-center gap-3 p-3 hover:bg-gray-50 rounded-lg cursor-pointer transition-colors"
              >
                <input
                  type="checkbox"
                  checked={selectedSubtasks.has(suggestion.title)}
                  onChange={() =>
                    handleToggleSubtask(suggestion.title)
                  }
                  className="w-4 h-4 text-indigo-500 rounded"
                />
                <div className="flex-1">
                  <p className="text-sm font-medium text-gray-900">
                    {suggestion.title}
                  </p>
                  {suggestion.difficulty && (
                    <p className="text-xs text-gray-500">
                      難易度: {suggestion.difficulty}/5
                    </p>
                  )}
                </div>
              </label>
            ))}
          </div>
        </div>

        {/* Action buttons */}
        <div className="flex gap-3">
          <button
            onClick={handleClose}
            className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50 transition-colors"
          >
            キャンセル
          </button>
          <button
            onClick={handleConfirm}
            disabled={selectedSubtasks.size === 0}
            className="flex-1 px-4 py-2 bg-indigo-500 text-white font-medium rounded-lg hover:bg-indigo-600 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-2"
          >
            <Plus className="w-4 h-4" />
            追加 ({selectedSubtasks.size})
          </button>
        </div>
      </div>
    </div>
  );
};
