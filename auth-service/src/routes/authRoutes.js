const express = require('express');
const { registerUser, loginUser, getMe, findUserByEmail } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', (req, res) => {
    res.json({ message: 'Auth Service Running!' });
});
router.post('/register', registerUser);
router.post('/login', loginUser);
router.get('/me', protect, getMe);
// lookup user by email (protected)
router.get('/user', protect, findUserByEmail);

module.exports = router;
