import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { taskService, boardService } from '../services/taskService';
import './Dashboard.css';

const Dashboard = () => {
    const { user } = useAuth();
    const [stats, setStats] = useState({
        totalTasks: 0,
        todoTasks: 0,
        inProgressTasks: 0,
        completedTasks: 0,
        totalBoards: 0,
    });
    const [recentTasks, setRecentTasks] = useState([]);
    const [recentBoards, setRecentBoards] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchDashboardData();
    }, []);

    const fetchDashboardData = async () => {
        try {
            const [tasks, boards] = await Promise.all([
                taskService.getTasks(),
                boardService.getBoards(),
            ]);

            const todoTasks = tasks.filter((t) => t.status === 'todo').length;
            const inProgressTasks = tasks.filter((t) => t.status === 'in-progress').length;
            const completedTasks = tasks.filter((t) => t.status === 'done').length;

            setStats({
                totalTasks: tasks.length,
                todoTasks,
                inProgressTasks,
                completedTasks,
                totalBoards: boards.length,
            });

            setRecentTasks(tasks.slice(0, 5));
            setRecentBoards(boards.slice(0, 4));
        } catch (error) {
            console.error('Error fetching dashboard data:', error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return <div className="loading">Loading dashboard...</div>;
    }

    return (
        <div className="page-container">
            <div className="page-header">
                <h1 className="page-title">Welcome back, {user?.name}!</h1>
                <p className="page-subtitle">Here's what's happening with your tasks</p>
            </div>

            <div className="dashboard-grid">
                <div className="stat-card">
                    <div className="stat-icon" style={{ background: '#dbeafe' }}>
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#2563eb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M9 11l3 3L22 4" />
                            <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11" />
                        </svg>
                    </div>
                    <div className="stat-content">
                        <p className="stat-label">Total Tasks</p>
                        <h3 className="stat-value">{stats.totalTasks}</h3>
                    </div>
                </div>

                <div className="stat-card">
                    <div className="stat-icon" style={{ background: '#fef3c7' }}>
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <circle cx="12" cy="12" r="10" />
                            <polyline points="12 6 12 12 16 14" />
                        </svg>
                    </div>
                    <div className="stat-content">
                        <p className="stat-label">To Do</p>
                        <h3 className="stat-value">{stats.todoTasks}</h3>
                    </div>
                </div>

                <div className="stat-card">
                    <div className="stat-icon" style={{ background: '#e0e7ff' }}>
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M12 2v20M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6" />
                        </svg>
                    </div>
                    <div className="stat-content">
                        <p className="stat-label">In Progress</p>
                        <h3 className="stat-value">{stats.inProgressTasks}</h3>
                    </div>
                </div>

                <div className="stat-card">
                    <div className="stat-icon" style={{ background: '#d1fae5' }}>
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#10b981" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M22 11.08V12a10 10 0 11-5.93-9.14" />
                            <polyline points="22 4 12 14.01 9 11.01" />
                        </svg>
                    </div>
                    <div className="stat-content">
                        <p className="stat-label">Completed</p>
                        <h3 className="stat-value">{stats.completedTasks}</h3>
                    </div>
                </div>
            </div>

            <div className="dashboard-section">
                <div className="section-header">
                    <h2 className="section-title">Recent Tasks</h2>
                    <Link to="/tasks" className="btn btn-primary">
                        View All
                    </Link>
                </div>

                {recentTasks.length > 0 ? (
                    <div className="task-list">
                        {recentTasks.map((task) => (
                            <div key={task._id} className="task-item">
                                <div className="task-info">
                                    <h3 className="task-title">{task.title}</h3>
                                    <p className="task-description">{task.description}</p>
                                </div>
                                <span className={`task-badge task-badge-${task.status}`}>
                                    {task.status}
                                </span>
                            </div>
                        ))}
                    </div>
                ) : (
                    <div className="empty-state">
                        <div className="empty-state-icon">
                            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" />
                                <polyline points="14 2 14 8 20 8" />
                                <line x1="12" y1="18" x2="12" y2="12" />
                                <line x1="9" y1="15" x2="15" y2="15" />
                            </svg>
                        </div>
                        <h3 className="empty-state-title">No tasks yet</h3>
                        <p className="empty-state-text">Create your first task to get started</p>
                        <Link to="/tasks" className="btn btn-primary">
                            Create Task
                        </Link>
                    </div>
                )}
            </div>

            <div className="dashboard-section">
                <div className="section-header">
                    <h2 className="section-title">Boards</h2>
                    <Link to="/boards" className="btn btn-primary">
                        View All
                    </Link>
                </div>

                {recentBoards.length > 0 ? (
                    <div className="boards-grid">
                        {recentBoards.map((board) => (
                            <div key={board._id} className="board-card-mini">
                                <div className="board-card-header">
                                    <div className="board-icon">
                                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                        </svg>
                                    </div>
                                    <h3 className="board-name">{board.name}</h3>
                                </div>
                                <p className="board-description">{board.description}</p>
                                {board.members && (
                                    <div className="board-members">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                            <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" />
                                            <circle cx="9" cy="7" r="4" />
                                            <path d="M23 21v-2a4 4 0 00-3-3.87" />
                                            <path d="M16 3.13a4 4 0 010 7.75" />
                                        </svg>
                                        <span>{board.members.length} {board.members.length === 1 ? 'member' : 'members'}</span>
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                ) : (
                    <div className="empty-state">
                        <div className="empty-state-icon">
                            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                            </svg>
                        </div>
                        <h3 className="empty-state-title">No boards yet</h3>
                        <p className="empty-state-text">Create your first board to organize your tasks</p>
                        <Link to="/boards" className="btn btn-primary">
                            Create Board
                        </Link>
                    </div>
                )}
            </div>
        </div>
    );
};

export default Dashboard;
