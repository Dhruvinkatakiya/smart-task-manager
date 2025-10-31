const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const boardRoutes = require('./routes/boardRoutes');
const connectDB = require('./config/db');

// Ensure User model is registered so Mongoose populate('members') can resolve refs
require('./models/User');

dotenv.config();

// Connect to MongoDB
connectDB();

const app = express();
app.use(express.json());
// Trust proxy headers (X-Forwarded-Proto) so Express knows the original request scheme behind nginx/ngrok
app.set('trust proxy', true);

// Sample route
app.get('/', (req, res) => {
  res.send('Board Service Running!');
});

// Routes
app.use('/api/boards', boardRoutes);

const PORT = process.env.PORT || 8002;
app.listen(PORT, () => console.log(`Board Service running on port ${PORT}`));
