import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import './Header.css';

const Header = () => {
    const { isAuthenticated, user, logout } = useAuth();
    const location = useLocation();
    const navigate = useNavigate();

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    return (
        <header className="header">
            <div className="container">
                <div className="header-content">
                    <Link to="/" className="logo">
                        <h1>Smart Task Manager</h1>
                    </Link>

                    {isAuthenticated ? (
                        <nav className="nav">
                            <Link
                                to="/dashboard"
                                className={`nav-link ${location.pathname === '/dashboard' ? 'active' : ''}`}
                            >
                                Dashboard
                            </Link>
                            <Link
                                to="/tasks"
                                className={`nav-link ${location.pathname === '/tasks' ? 'active' : ''}`}
                            >
                                Tasks
                            </Link>
                            <Link
                                to="/boards"
                                className={`nav-link ${location.pathname === '/boards' ? 'active' : ''}`}
                            >
                                Boards
                            </Link>
                            <div className="user-menu">
                                <span className="user-name">{user?.name || user?.email}</span>
                                <button onClick={handleLogout} className="btn btn-secondary btn-sm">
                                    Logout
                                </button>
                            </div>
                        </nav>
                    ) : (
                        <nav className="nav">
                            {location.pathname !== '/login' && (
                                <Link to="/login" className="btn btn-primary btn-sm">
                                    Login
                                </Link>
                            )}
                            {location.pathname !== '/register' && (
                                <Link to="/register" className="btn btn-secondary btn-sm">
                                    Register
                                </Link>
                            )}
                        </nav>
                    )}
                </div>
            </div>
        </header>
    );
};

export default Header;
