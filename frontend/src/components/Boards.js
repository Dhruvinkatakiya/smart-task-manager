import React, { useState, useEffect } from 'react';
import { boardService } from '../services/taskService';
import authService from '../services/authService';
import { useAuth } from '../context/AuthContext';
import './Boards.css';

const Boards = () => {
    const { user } = useAuth();
    const currentUserId = user?._id || user?.id || null;
    const [boards, setBoards] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingBoard, setEditingBoard] = useState(null);
    const [formData, setFormData] = useState({ name: '', description: '' });
    const [error, setError] = useState('');

    // Member modal state
    const [showMembersModal, setShowMembersModal] = useState(false);
    const [selectedBoard, setSelectedBoard] = useState(null);
    const [memberEmail, setMemberEmail] = useState('');
    const [memberError, setMemberError] = useState('');

    useEffect(() => {
        fetchBoards();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const fetchBoards = async () => {
        setLoading(true);
        try {
            const data = await boardService.getBoards();
            setBoards(data);
        } catch (err) {
            console.error('Boards fetch error:', err);
            setError(err.response?.data?.message || 'Failed to fetch boards');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        try {
            if (editingBoard) {
                await boardService.updateBoard(editingBoard._id, formData);
            } else {
                await boardService.createBoard(formData);
            }
            await fetchBoards();
            setShowModal(false);
            resetForm();
        } catch (err) {
            setError(err.response?.data?.message || 'Failed to save board');
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this board?')) return;
        try {
            await boardService.deleteBoard(id);
            await fetchBoards();
        } catch (err) {
            setError('Failed to delete board');
        }
    };

    const handleEdit = (board) => {
        setEditingBoard(board);
        setFormData({ name: board.name, description: board.description });
        setShowModal(true);
    };

    const resetForm = () => {
        setEditingBoard(null);
        setFormData({ name: '', description: '' });
    };

    const handleCloseModal = () => {
        setShowModal(false);
        resetForm();
    };

    // Member management
    const openMembers = (board) => {
        setSelectedBoard(board);
        setMemberEmail('');
        setMemberError('');
        setShowMembersModal(true);
    };

    const closeMembers = () => {
        setSelectedBoard(null);
        setShowMembersModal(false);
    };

    const handleAddMember = async () => {
        if (!memberEmail) return setMemberError('Enter a user email');
        setMemberError('');
        try {
            const u = await authService.findUserByEmail(memberEmail);
            await boardService.addMember(selectedBoard._id, u._id);
            await fetchBoards();
            closeMembers();
        } catch (err) {
            setMemberError(err.response?.data?.message || err.message || 'Failed to add member');
        }
    };

    const handleRemoveMember = async (userId) => {
        if (!selectedBoard) return;
        if (!window.confirm('Remove this member?')) return;
        try {
            await boardService.removeMember(selectedBoard._id, userId);
            await fetchBoards();
        } catch (err) {
            setMemberError('Failed to remove member');
        }
    };

    if (loading) return <div className="loading">Loading boards...</div>;

    return (
        <div className="page-container">
            <div className="page-header">
                <div>
                    <h1 className="page-title">My Boards</h1>
                    <p className="page-subtitle">Organize your tasks into boards</p>
                </div>
                <button onClick={() => setShowModal(true)} className="btn btn-primary">
                    + New Board
                </button>
            </div>

            {error && <div className="error-message">{error}</div>}

            <div className="boards-grid">
                {boards.length === 0 ? (
                    <div className="empty-state">
                        <h3>No boards yet</h3>
                        <p>Create your first board to organize your tasks</p>
                        <button onClick={() => setShowModal(true)} className="btn btn-primary">
                            Create Board
                        </button>
                    </div>
                ) : (
                    boards.map((board) => (
                        <BoardCard
                            key={board._id}
                            board={board}
                            onEdit={handleEdit}
                            onDelete={handleDelete}
                            onManageMembers={() => openMembers(board)}
                            currentUser={user}
                        />
                    ))
                )}
            </div>

            {/* Create / Edit modal */}
            {showModal && (
                <div className="modal-overlay" onClick={handleCloseModal}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                        <div className="modal-header">
                            <h2>{editingBoard ? 'Edit Board' : 'Create New Board'}</h2>
                            <button onClick={handleCloseModal} className="close-btn">&times;</button>
                        </div>

                        <form onSubmit={handleSubmit} className="modal-form">
                            <div className="form-group">
                                <label htmlFor="name">Board Name</label>
                                <input
                                    type="text"
                                    id="name"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    required
                                    className="form-input"
                                    placeholder="Enter board name"
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
                                    placeholder="Enter board description"
                                />
                            </div>

                            <div className="modal-actions">
                                <button type="button" onClick={handleCloseModal} className="btn btn-secondary">
                                    Cancel
                                </button>
                                <button type="submit" className="btn btn-primary">
                                    {editingBoard ? 'Update' : 'Create'} Board
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Members modal */}
            {showMembersModal && selectedBoard && (
                <div className="modal-overlay" onClick={closeMembers}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                        <div className="modal-header">
                            <h2>Manage Members - {selectedBoard.name}</h2>
                            <button onClick={closeMembers} className="close-btn">&times;</button>
                        </div>

                        <div className="modal-form">
                            <div className="form-group">
                                <label htmlFor="memberEmail">Add member by email</label>
                                <input
                                    id="memberEmail"
                                    type="email"
                                    value={memberEmail}
                                    onChange={(e) => setMemberEmail(e.target.value)}
                                    className="form-input"
                                    placeholder="user@example.com"
                                />
                                {memberError && <div className="error-message">{memberError}</div>}
                            </div>

                            <div className="modal-actions">
                                <button type="button" onClick={handleAddMember} className="btn btn-primary">
                                    Add Member
                                </button>
                                <button type="button" onClick={closeMembers} className="btn btn-secondary">
                                    Close
                                </button>
                            </div>

                            <div className="member-list">
                                <h4>Current members</h4>
                                {selectedBoard.members && selectedBoard.members.length > 0 ? (
                                    <ul>
                                        {selectedBoard.members.map((m) => {
                                            const memberId = m._id || m;
                                            const memberName = m.name || m.email || memberId;
                                            const initials = memberName.split(' ').map(s => s[0]).slice(0, 2).join('').toUpperCase();
                                            return (
                                                <li key={memberId} className="member-item">
                                                    <div className="member-info">
                                                        <span className="member-avatar">{initials}</span>
                                                        <div>
                                                            <span className="member-name">{memberName}</span>
                                                            {m.email && <span className="member-email">{m.email}</span>}
                                                        </div>
                                                    </div>
                                                    {(selectedBoard.createdBy && ((selectedBoard.createdBy._id || selectedBoard.createdBy).toString() === currentUserId)) ? (
                                                        <button className="btn-link" onClick={() => handleRemoveMember(memberId)}>
                                                            Remove
                                                        </button>
                                                    ) : null}
                                                </li>
                                            );
                                        })}
                                    </ul>
                                ) : (
                                    <p>No members yet</p>
                                )}
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

const BoardCard = ({ board, onEdit, onDelete, onManageMembers, currentUser }) => {
    const currentUserIdLocal = currentUser?._id || currentUser?.id || null;
    const ownerId = (board.createdBy && (board.createdBy._id ? board.createdBy._id : board.createdBy)).toString();
    const isOwner = ownerId === currentUserIdLocal;

    return (
        <div className="board-card">
            <div className="board-card-header">
                <h3 className="board-card-title">{board.name}</h3>
                <div className="board-card-actions">
                    {isOwner && (
                        <button onClick={() => onEdit(board)} className="btn-icon" title="Edit">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                            </svg>
                        </button>
                    )}
                    {isOwner && (
                        <button onClick={() => onDelete(board._id)} className="btn-icon" title="Delete">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M3 6h18" />
                                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6" />
                                <path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                                <line x1="10" y1="11" x2="10" y2="17" />
                                <line x1="14" y1="11" x2="14" y2="17" />
                            </svg>
                        </button>
                    )}
                    {/* Manage members - only show to owner */}
                    {isOwner && (
                        <button onClick={() => onManageMembers(board)} className="btn-icon" title="Manage Members" style={{ marginLeft: '6px' }}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4z" />
                                <path d="M6 20v-1a4 4 0 014-4h4a4 4 0 014 4v1" />
                            </svg>
                        </button>
                    )}
                </div>
            </div>
            <p className="board-card-description">{board.description || 'No description provided'}</p>
            <div className="board-card-footer">
                <span className="board-date">Created {new Date(board.createdAt).toLocaleDateString()}</span>
            </div>
        </div>
    );
};

export default Boards;
