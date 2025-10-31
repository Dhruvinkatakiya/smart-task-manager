const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
  title: { type: String, required: true, trim: true },
  description: { type: String, default: '' },
  status: {
    type: String,
    enum: ['todo', 'in-progress', 'done'],
    default: 'todo'
  },
  boardId: { type: mongoose.Schema.Types.ObjectId, ref: 'Board', required: false },
  userId: { type: mongoose.Schema.Types.ObjectId, required: true }, // owner
}, { timestamps: true });

module.exports = mongoose.model('Task', TaskSchema);
