const Task = require('../models/Task');
const Board = require('../models/Board');
const Joi = require('joi');

// Validation schemas
const taskCreateSchema = Joi.object({
  title: Joi.string().min(1).required(),
  description: Joi.string().allow('').optional(),
  status: Joi.string().valid('todo', 'in-progress', 'done').optional(),
  boardId: Joi.string().optional()
});

exports.createTask = async (req, res) => {
  try {
    const { error, value } = taskCreateSchema.validate(req.body);
    if (error) return res.status(400).json({ message: error.message });

    const task = await Task.create({
      ...value,
      userId: req.user.id
    });
    res.status(201).json(task);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getTasks = async (req, res) => {
  try {
    // If querying by boardId, ensure requester is a member of that board
    if (req.query.boardId) {
      const board = await Board.findById(req.query.boardId);
      if (!board) return res.status(404).json({ message: 'Board not found' });
      const isMember = board.members.some(m => m.toString() === req.user.id);
      if (!isMember) return res.status(403).json({ message: 'Not authorized to view tasks for this board' });
      const tasks = await Task.find({ boardId: req.query.boardId }).sort({ createdAt: -1 });
      return res.json(tasks);
    }

    // default: return tasks owned by the user
    const tasks = await Task.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getTaskById = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: 'Task not found' });

    // allow access if requester is task owner OR a member of the task's board
    if (task.userId.toString() === req.user.id) return res.json(task);

    if (task.boardId) {
      const board = await Board.findById(task.boardId);
      if (!board) return res.status(404).json({ message: 'Board not found' });
      const isMember = board.members.some(m => m.toString() === req.user.id);
      if (isMember) return res.json(task);
    }

    return res.status(403).json({ message: 'Forbidden' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: 'Task not found' });

    // allow update if task owner OR board owner
    let allowed = false;
    if (task.userId.toString() === req.user.id) allowed = true;
    if (!allowed && task.boardId) {
      const board = await Board.findById(task.boardId);
      if (board && board.createdBy.toString() === req.user.id) allowed = true;
    }
    if (!allowed) return res.status(403).json({ message: 'Forbidden' });

    const { title, description, status, boardId } = req.body;
    if (title !== undefined) task.title = title;
    if (description !== undefined) task.description = description;
    if (status !== undefined) task.status = status;
    if (boardId !== undefined) task.boardId = boardId;

    await task.save();
    res.json(task);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: 'Task not found' });

    // allow delete if task owner OR board owner
    let allowed = false;
    if (task.userId.toString() === req.user.id) allowed = true;
    if (!allowed && task.boardId) {
      const board = await Board.findById(task.boardId);
      if (board && board.createdBy.toString() === req.user.id) allowed = true;
    }
    if (!allowed) return res.status(403).json({ message: 'Forbidden' });

    await task.deleteOne();
    res.json({ message: 'Task removed' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
