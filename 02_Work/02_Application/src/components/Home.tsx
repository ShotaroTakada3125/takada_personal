import React, { useState } from 'react';
import { Plus, Lightbulb } from 'lucide-react';
import { Task, TaskStatus, FilterOptions, SubtaskSuggestion } from '../types/task';
import { useLocalStorage } from '../hooks/useLocalStorage';
import { extractKeywordMatches, hasKeywordMatch } from '../utils/keywordExtractor';
import { TaskCard } from './TaskCard';
import { KeywordModal } from './KeywordModal';
import { FilterBar } from './FilterBar';

export const Home: React.FC = () => {
  const [tasks, setTasks] = useLocalStorage<Task[]>('tasks', []);
  const [inputValue, setInputValue] = useState('');
  const [selectedMood, setSelectedMood] = useState<string | null>(null);
  const [selectedLocation, setSelectedLocation] = useState<string | null>(null);
  const [filters, setFilters] = useState<FilterOptions>({
    mood: null,
    location: null,
    status: null,
  });

  // Modal state
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalSuggestions, setModalSuggestions] = useState<SubtaskSuggestion[]>([]);
  const [modalMainTask, setModalMainTask] = useState('');

  const handleAddTask = () => {
    if (!inputValue.trim()) return;

    // Check for keyword matches
    const matches = extractKeywordMatches(inputValue);

    if (matches.length > 0) {
      // Open modal with suggestions
      setModalSuggestions(matches);
      setModalMainTask(inputValue);
      setIsModalOpen(true);
    } else {
      // Add task directly if no matches
      addSingleTask(inputValue, selectedMood, selectedLocation);
      setInputValue('');
      setSelectedMood(null);
      setSelectedLocation(null);
    }
  };

  const addSingleTask = (
    title: string,
    mood: string | null = null,
    location: string | null = null,
    difficulty: number = 3
  ) => {
    const newTask: Task = {
      id: Date.now().toString(),
      title: title.trim(),
      base_difficulty: difficulty,
      current_difficulty: difficulty,
      location: location || '',
      mood_category: mood || '',
      is_recurring: false,
      cycle: 0,
      status: 'todo',
      createdAt: new Date().toISOString(),
    };
    setTasks([...tasks, newTask]);
  };

  const handleAddSubtasks = (subtasks: SubtaskSuggestion[]) => {
    subtasks.forEach((subtask) => {
      addSingleTask(
        subtask.title,
        selectedMood,
        selectedLocation,
        subtask.difficulty || 2
      );
    });
  };

  const handleAddMainTask = (title: string) => {
    addSingleTask(title, selectedMood, selectedLocation);
  };

  const handleStatusChange = (id: string, status: TaskStatus) => {
    setTasks(
      tasks.map((task) => (task.id === id ? { ...task, status } : task))
    );
  };

  const handleDifficultyChange = (id: string, difficulty: number) => {
    setTasks(
      tasks.map((task) =>
        task.id === id ? { ...task, current_difficulty: difficulty } : task
      )
    );
  };

  const handleDeleteTask = (id: string) => {
    setTasks(tasks.filter((task) => task.id !== id));
  };

  // Filter tasks based on current filters
  const filteredTasks = tasks.filter((task) => {
    if (filters.mood && task.mood_category !== filters.mood) return false;
    if (filters.location && task.location !== filters.location) return false;
    if (filters.status && task.status !== filters.status) return false;
    return true;
  });

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-white">
      <div className="max-w-3xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            最強ToDo
          </h1>
          <p className="text-gray-600">
            思考を入力すると、最適なタスクが提案されます
          </p>
        </div>

        {/* Input Section */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
          <div className="mb-4">
            <label className="block text-sm font-semibold text-gray-700 mb-2">
              🧠 思考を入力
            </label>
            <textarea
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && e.ctrlKey) {
                  handleAddTask();
                }
              }}
              placeholder="例: 旅行の準備をしたい、部屋を掃除したい..."
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent resize-none"
              rows={3}
            />
            {inputValue.trim() && hasKeywordMatch(inputValue) && (
              <div className="flex items-center gap-2 mt-2 text-indigo-600 text-sm">
                <Lightbulb className="w-4 h-4" />
                <span>関連するサブタスクが提案されます</span>
              </div>
            )}
          </div>

          {/* Mood and Location Selection */}
          <div className="grid grid-cols-2 gap-4 mb-4">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                気分 (オプション)
              </label>
              <select
                value={selectedMood || ''}
                onChange={(e) =>
                  setSelectedMood(e.target.value || null)
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              >
                <option value="">選択なし</option>
                <option value="集中">🎯 集中</option>
                <option value="疲れ">😴 疲れ</option>
                <option value="サクッと">⚡ サクッと</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                場所 (オプション)
              </label>
              <select
                value={selectedLocation || ''}
                onChange={(e) =>
                  setSelectedLocation(e.target.value || null)
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              >
                <option value="">選択なし</option>
                <option value="家">🏠 家</option>
                <option value="外出先">🌐 外出先</option>
                <option value="オフィス">💼 オフィス</option>
              </select>
            </div>
          </div>

          {/* Add Button */}
          <button
            onClick={handleAddTask}
            disabled={!inputValue.trim()}
            className="w-full px-4 py-3 bg-indigo-500 text-white font-semibold rounded-lg hover:bg-indigo-600 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-2"
          >
            <Plus className="w-5 h-5" />
            タスクを追加
          </button>
        </div>

        {/* Filter Section */}
        <div className="mb-6">
          <FilterBar filters={filters} onFilterChange={setFilters} />
        </div>

        {/* Tasks List */}
        <div className="space-y-3">
          {filteredTasks.length > 0 ? (
            filteredTasks.map((task) => (
              <TaskCard
                key={task.id}
                task={task}
                onStatusChange={handleStatusChange}
                onDifficultyChange={handleDifficultyChange}
                onDelete={handleDeleteTask}
              />
            ))
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-500 text-lg">
                {tasks.length === 0
                  ? 'タスクはまだありません。思考を入力して追加してみてください！'
                  : 'フィルタに一致するタスクがありません'}
              </p>
            </div>
          )}
        </div>

        {/* Stats */}
        {tasks.length > 0 && (
          <div className="mt-8 p-4 bg-indigo-50 rounded-lg border border-indigo-200">
            <div className="grid grid-cols-4 gap-4 text-center">
              <div>
                <p className="text-2xl font-bold text-indigo-600">
                  {tasks.length}
                </p>
                <p className="text-xs text-gray-600">全タスク</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-600">
                  {tasks.filter((t) => t.status === 'todo').length}
                </p>
                <p className="text-xs text-gray-600">ToDo</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-amber-600">
                  {tasks.filter((t) => t.status === 'wip').length}
                </p>
                <p className="text-xs text-gray-600">進行中</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-green-600">
                  {tasks.filter((t) => t.status === 'done').length}
                </p>
                <p className="text-xs text-gray-600">完了</p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Modal */}
      <KeywordModal
        isOpen={isModalOpen}
        suggestions={modalSuggestions}
        mainTaskTitle={modalMainTask}
        onClose={() => {
          setIsModalOpen(false);
          setInputValue('');
          setSelectedMood(null);
          setSelectedLocation(null);
        }}
        onAddSubtasks={handleAddSubtasks}
        onAddMainTask={handleAddMainTask}
      />
    </div>
  );
};
