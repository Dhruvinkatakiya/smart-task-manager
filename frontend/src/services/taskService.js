import api from './api';

export const taskService = {
    // Get all tasks
    getTasks: async () => {
        const response = await api.get('/api/tasks');
        return response.data;
    },

    // Get task by ID
    getTask: async (id) => {
        const response = await api.get(`/api/tasks/${id}`);
        return response.data;
    },

    // Create new task
    createTask: async (taskData) => {
        const response = await api.post('/api/tasks', taskData);
        return response.data;
    },

    // Update task
    updateTask: async (id, taskData) => {
        const response = await api.put(`/api/tasks/${id}`, taskData);
        return response.data;
    },

    // Delete task
    deleteTask: async (id) => {
        const response = await api.delete(`/api/tasks/${id}`);
        return response.data;
    },
};

export const boardService = {
    // Get all boards
    getBoards: async () => {
        const response = await api.get('/api/boards');
        return response.data;
    },

    // Get board by ID
    getBoard: async (id) => {
        const response = await api.get(`/api/boards/${id}`);
        return response.data;
    },

    // Create new board
    createBoard: async (boardData) => {
        const response = await api.post('/api/boards', boardData);
        return response.data;
    },

    // Update board
    updateBoard: async (id, boardData) => {
        const response = await api.put(`/api/boards/${id}`, boardData);
        return response.data;
    },

    // Delete board
    deleteBoard: async (id) => {
        const response = await api.delete(`/api/boards/${id}`);
        return response.data;
    },

    // Add member to board
    addMember: async (boardId, userId) => {
        const response = await api.post(`/api/boards/${boardId}/members`, { userId });
        return response.data;
    },

    // Remove member from board
    removeMember: async (boardId, userId) => {
        const response = await api.delete(`/api/boards/${boardId}/members/${userId}`);
        return response.data;
    },
};
