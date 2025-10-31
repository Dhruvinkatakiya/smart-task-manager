import api from './api';

const authService = {
    getMe: async () => {
        const response = await api.get('/api/auth/me');
        return response.data;
    },
    findUserByEmail: async (email) => {
        const response = await api.get(`/api/auth/user?email=${encodeURIComponent(email)}`);
        return response.data;
    },
};

export default authService;
