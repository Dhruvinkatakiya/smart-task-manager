const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  getBoards,
  getBoardById,
  createBoard,
  updateBoard,
  deleteBoard,
  addMember,
  removeMember,
} = require('../controllers/boardController');

const router = express.Router();

router.get('/', protect, getBoards);
router.get('/:id', protect, getBoardById);
router.post('/', protect, createBoard);
router.put('/:id', protect, updateBoard);
router.delete('/:id', protect, deleteBoard);
router.post('/:id/members', protect, addMember);
router.delete('/:id/members/:userId', protect, removeMember);

module.exports = router;
