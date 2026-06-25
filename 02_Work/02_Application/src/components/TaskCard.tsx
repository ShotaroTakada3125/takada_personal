import React from 'react';
import { Trash2, CheckCircle2, Circle, AlertCircle } from 'lucide-react';
import { Task, TaskStatus } from '../types/task';

interface TaskCardProps {
  task: Task;
  onStatusChange: (id: string, status: TaskStatus) => void;
  onDifficultyChange: (id: string, difficulty: number) => void;
  onDelete: (id: string) => void;
}

export const TaskCard: React.FC<TaskCardProps> = ({
  task,
  onStatusChange,
  onDifficultyChange,
  onDelete,
}) => {
  const statusColors = {
    todo: 'border-l-4 border-gray-300',
    wip: 'border-l-4 border-amber-400',
    done: 'border-l-4 border-green-400',
  };

  const statusIcons = {
    todo: <Circle className="w-5 h-5 text-gray-400" />,
    wip: <AlertCircle className="w-5 h-5 text-amber-500" />,
    done: <CheckCircle2 className="w-5 h-5 text-green-500" />,
  };

  return (
    <div
      className={`bg-white rounded-lg p-4 shadow-sm hover:shadow-md transition-shadow ${statusColors[task.status]}`}
    >
      <div className="flex items-start justify-between gap-4">
        <div className="flex-1">
          {/* Header with status icon and title */}
          <div className="flex items-center gap-3 mb-3">
            <button
              onClick={() => {
                const nextStatus: TaskStatus =
                  task.status === 'todo' ? 'wip' : task.status === 'wip' ? 'done' : 'todo';
                onStatusChange(task.id, nextStatus);
              }}
              className="p-1 hover:bg-gray-100 rounded transition-colors"
              title={`Change status to ${task.status === 'todo' ? 'in progress' : task.status === 'wip' ? 'done' : 'todo'}`}
            >
              {statusIcons[task.status]}
            </button>
            <h3 className="text-base font-medium text-gray-900 flex-1 text-left">
              {task.title}
            </h3>
          </div>

          {/* Task metadata */}
          <div className="flex flex-wrap gap-2 mb-3">
            <span className="inline-block px-2 py-1 bg-indigo-50 text-indigo-700 text-xs rounded font-medium">
              🏠 {task.location || 'どこでも'}
            </span>
            <span className="inline-block px-2 py-1 bg-blue-50 text-blue-700 text-xs rounded font-medium">
              💭 {task.mood_category || '気分選択なし'}
            </span>
          </div>

          {/* Difficulty selector */}
          <div className="flex items-center gap-2">
            <span className="text-xs text-gray-600 font-medium">難易度:</span>
            <div className="flex gap-1">
              {[1, 2, 3, 4, 5].map((level) => (
                <button
                  key={level}
                  onClick={() => onDifficultyChange(task.id, level)}
                  className={`w-6 h-6 rounded text-xs font-bold transition-colors ${
                    task.current_difficulty === level
                      ? 'bg-indigo-500 text-white'
                      : 'bg-gray-200 text-gray-600 hover:bg-gray-300'
                  }`}
                >
                  {level}
                </button>
              ))}
            </div>
          </div>

          {/* Recurring info */}
          {task.is_recurring && (
            <div className="text-xs text-gray-500 mt-2">
              🔄 周期: {task.cycle}日
            </div>
          )}
        </div>

        {/* Delete button */}
        <button
          onClick={() => onDelete(task.id)}
          className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded transition-colors"
          title="Delete task"
        >
          <Trash2 className="w-5 h-5" />
        </button>
      </div>
    </div>
  );
};
