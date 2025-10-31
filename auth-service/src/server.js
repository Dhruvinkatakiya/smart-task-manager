const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');

dotenv.config();
connectDB();

const app = express();
app.use(express.json());
// Trust proxy headers (X-Forwarded-Proto) so Express knows the original request scheme behind nginx/ngrok
app.set('trust proxy', true);

// Routes
app.use('/api/auth', require('./routes/authRoutes'));

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => console.log(`Auth Service running on port ${PORT}`));
