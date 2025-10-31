import axios from 'axios';

// Use environment variable or default to current host origin (ensures matching scheme)
const BASE_URL =
    process.env.REACT_APP_API_URL ||
    (typeof window !== 'undefined' && window.location && window.location.origin) ||
    '';

// Helpful runtime debug to verify which base URL the client is using (temporary)
/* eslint-disable no-console */
if (typeof window !== 'undefined' && window.console && window.console.debug) {
    console.debug('[api] BASE_URL:', BASE_URL);
}
/* eslint-enable no-console */

const api = axios.create({
    baseURL: BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Add token to requests if available
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('token');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        // Debug: log computed request target and ensure we don't send http:// on an https page
        try {
            const runtimeOrigin = (typeof window !== 'undefined' && window.location && window.location.origin) || '';
            // Normalize baseURL if page is served over HTTPS to avoid mixed content
            if (typeof window !== 'undefined' && window.location && window.location.protocol === 'https:') {
                if (config.baseURL && config.baseURL.startsWith('http://')) {
                    config.baseURL = config.baseURL.replace(/^http:\/\//i, 'https://');
                }
            }

            const base = config.baseURL || runtimeOrigin;
            const url = config.url || '';
            let fullUrl = url;
            try {
                fullUrl = new URL(url, base).href;
            } catch (e) {
                fullUrl = (base ? base.replace(/\/$/, '') : '') + '/' + url.replace(/^\//, '');
            }
            if (window && window.console && window.console.debug) {
                console.debug('[api] request ->', config.method, fullUrl, { base, url });
            }
        } catch (e) {
            // ignore debug errors
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Handle response errors
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            // Token expired or invalid
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

export default api;
