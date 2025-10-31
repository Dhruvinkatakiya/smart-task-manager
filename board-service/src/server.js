const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const boardRoutes = require('./routes/boardRoutes');
// Ensure User model is registered so Mongoose populate('members') can resolve refs
require('./models/User');

dotenv.config();
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

// Connect to MongoDB
mongoose.connect("mongodb://localhost:27017/board-service", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
  .then(() => console.log('MongoDB connected!'))
  .catch(err => console.error('MongoDB connection error:', err));

const PORT = process.env.PORT || 8002;
app.listen(PORT, () => console.log(`Board Service running on port ${PORT}`));
