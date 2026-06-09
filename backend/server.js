
const express = require('express');
const cors    = require('cors');

require('dotenv').config();

const app = express();


app.use(cors());

app.use(express.json());

const coinsRoutes    = require('./routes/coins');
const reviewsRoutes  = require('./routes/reviews');
const feedbackRoutes = require('./routes/feedback');

app.use('/api/coins',    coinsRoutes);
app.use('/api/reviews',  reviewsRoutes);
app.use('/api/feedback', feedbackRoutes);

app.get('/', (req, res) => {
  res.json({
    message:     '🚀 Welcome to CryptoBliss API',
    description: 'Crypto sentiment platform powered by Amazon Comprehend',
    version:     '1.0.0',
    endpoints: {
      coins:    'GET  /api/coins',
      coin:     'GET  /api/coins/:id',
      reviews:  'GET  /api/reviews/:coinId',
      review:   'POST /api/reviews',
      feedback: 'GET  /api/feedback/:coinId',
      submit:   'POST /api/feedback',
      health:   'GET  /health'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({
    status:    'healthy',
    service:   'cryptobliss-api',
    timestamp: new Date().toISOString()
  });
});

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.url} not found`
  });
});

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err.message);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error:   err.message
  });
});

// START SERVER
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`✅ CryptoBliss API running on port ${PORT}`);
  console.log(`🤖 Amazon Comprehend: ready`);
  console.log(`🗄️  DynamoDB tables: cryptobliss-reviews, cryptobliss-feedback`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
});