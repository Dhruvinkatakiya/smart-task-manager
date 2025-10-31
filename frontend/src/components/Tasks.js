import React, { useState, useEffect } from 'react';
import { taskService, boardService } from '../services/taskService';
import './Tasks.css';

const Tasks = () => {
    const [tasks, setTasks] = useState([]);
    const [boards, setBoards] = useState([]);
    const [selectedBoard, setSelectedBoard] = useState('all');
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingTask, setEditingTask] = useState(null);
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        status: 'todo',
        boardId: '',
    });
    const [error, setError] = useState('');

    useEffect(() => {
        fetchBoards();
        fetchTasks();
    }, []);

    const fetchBoards = async () => {
        try {
            const data = await boardService.getBoards();
            setBoards(data);
        } catch (err) {
            console.error('Failed to fetch boards:', err);
        }
    };

    const fetchTasks = async () => {
        try {
            const data = await taskService.getTasks();
            setTasks(data);
        } catch (err) {
            setError('Failed to fetch tasks');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');

        try {
            if (editingTask) {
                await taskService.updateTask(editingTask._id, formData);
            } else {
                await taskService.createTask(formData);
            }

            await fetchTasks();
            setShowModal(false);
            resetForm();
        } catch (err) {
            setError(err.response?.data?.message || 'Failed to save task');
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this task?')) return;

        try {
            await taskService.deleteTask(id);
            await fetchTasks();
        } catch (err) {
            setError('Failed to delete task');
        }
    };

    const handleEdit = (task) => {
        setEditingTask(task);
        setFormData({
            title: task.title,
            description: task.description,
            status: task.status,
            boardId: task.boardId || '',
        });
        setShowModal(true);
    };

    const resetForm = () => {
        setEditingTask(null);
        setFormData({ title: '', description: '', status: 'todo', boardId: '' });
    };

    const handleCloseModal = () => {
        setShowModal(false);
        resetForm();
    };

    const getTasksByStatus = (status) => {
        let filteredTasks = tasks;

        // Filter by board if selected
        if (selectedBoard !== 'all') {
            if (selectedBoard === 'none') {
                filteredTasks = tasks.filter(task => !task.boardId);
            } else {
                filteredTasks = tasks.filter(task => task.boardId === selectedBoard);
            }
        }

        return filteredTasks.filter((task) => task.status === status);
    };

    if (loading) {
        return <div className="loading">Loading tasks...</div>;
    }

    return (
        <div className="page-container">
            <div className="page-header">
                <div>
                    <h1 className="page-title">My Tasks</h1>
                    <p className="page-subtitle">Manage your tasks efficiently</p>
                </div>
                <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                    <select
                        value={selectedBoard}
                        onChange={(e) => setSelectedBoard(e.target.value)}
                        className="form-input"
                        style={{ width: '200px' }}
                    >
                        <option value="all">All Boards</option>
                        <option value="none">No Board</option>
                        {boards.map(board => (
                            <option key={board._id} value={board._id}>{board.name}</option>
                        ))}
                    </select>
                    <button onClick={() => setShowModal(true)} className="btn btn-primary">
                        + New Task
                    </button>
                </div>
            </div>

            {error && <div className="error-message">{error}</div>}

            <div className="tasks-board">
                <div className="task-column">
                    <div className="column-header">
                        <h3>To Do</h3>
                        <span className="task-count">{getTasksByStatus('todo').length}</span>
                    </div>
                    <div className="task-cards">
                        {getTasksByStatus('todo').map((task) => (
                            <TaskCard key={task._id} task={task} boards={boards} onEdit={handleEdit} onDelete={handleDelete} />
                        ))}
                    </div>
                </div>

                <div className="task-column">
                    <div className="column-header">
                        <h3>In Progress</h3>
                        <span className="task-count">{getTasksByStatus('in-progress').length}</span>
                    </div>
                    <div className="task-cards">
                        {getTasksByStatus('in-progress').map((task) => (
                            <TaskCard key={task._id} task={task} boards={boards} onEdit={handleEdit} onDelete={handleDelete} />
                        ))}
                    </div>
                </div>

                <div className="task-column">
                    <div className="column-header">
                        <h3>Done</h3>
                        <span className="task-count">{getTasksByStatus('done').length}</span>
                    </div>
                    <div className="task-cards">
                        {getTasksByStatus('done').map((task) => (
                            <TaskCard key={task._id} task={task} boards={boards} onEdit={handleEdit} onDelete={handleDelete} />
                        ))}
                    </div>
                </div>
            </div>

            {showModal && (
                <div className="modal-overlay" onClick={handleCloseModal}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                        <div className="modal-header">
                            <h2>{editingTask ? 'Edit Task' : 'Create New Task'}</h2>
                            <button onClick={handleCloseModal} className="close-btn">&times;</button>
                        </div>

                        <form onSubmit={handleSubmit} className="modal-form">
                            <div className="form-group">
                                <label htmlFor="title">Title</label>
                                <input
                                    type="text"
                                    id="title"
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    required
                                    className="form-input"
                                    placeholder="Enter task title"
                                />
                            </div>

                            <div className="form-group">
                                <label htmlFor="description">Description</label>
                                <textarea
                                    id="description"
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    className="form-input"
                                    rows="4"
                                    placeholder="Enter task description"
                                />
                            </div>

                            <div className="form-group">
                                <label htmlFor="status">Status</label>
                                <select
                                    id="status"
                                    value={formData.status}
                                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                                    className="form-input"
                                >
                                    <option value="todo">To Do</option>
                                    <option value="in-progress">In Progress</option>
                                    <option value="done">Done</option>
                                </select>
                            </div>

                            <div className="form-group">
                                <label htmlFor="boardId">Board (Optional)</label>
                                <select
                                    id="boardId"
                                    value={formData.boardId}
                                    onChange={(e) => setFormData({ ...formData, boardId: e.target.value })}
                                    className="form-input"
                                >
                                    <option value="">No Board</option>
                                    {boards.map(board => (
                                        <option key={board._id} value={board._id}>{board.name}</option>
                                    ))}
                                </select>
                            </div>

                            <div className="modal-actions">
                                <button type="button" onClick={handleCloseModal} className="btn btn-secondary">
                                    Cancel
                                </button>
                                <button type="submit" className="btn btn-primary">
                                    {editingTask ? 'Update' : 'Create'} Task
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

const TaskCard = ({ task, boards, onEdit, onDelete }) => {
    const board = boards.find(b => b._id === task.boardId);

    return (
        <div className="task-card">
            <h4 className="task-card-title">{task.title}</h4>
            <p className="task-card-description">{task.description}</p>
            {board && (
                <div className="task-card-board" style={{
                    fontSize: '0.85em',
                    color: '#666',
                    marginTop: '8px',
                    padding: '4px 8px',
                    background: '#f0f0f0',
                    borderRadius: '4px',
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '6px'
                }}>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                    {board.name}
                </div>
            )}
            <div className="task-card-actions">
                <button onClick={() => onEdit(task)} className="btn-icon" title="Edit">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                    </svg>
                </button>
                <button onClick={() => onDelete(task._id)} className="btn-icon" title="Delete">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M3 6h18" />
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6" />
                        <path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                        <line x1="10" y1="11" x2="10" y2="17" />
                        <line x1="14" y1="11" x2="14" y2="17" />
                    </svg>
                </button>
            </div>
        </div>
    );
};

export default Tasks;
