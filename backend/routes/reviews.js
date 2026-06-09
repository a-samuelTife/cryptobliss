
const express = require('express');
const router = express.Router();

// Import our services
const { analyzeSentiment, getSentimentDisplay } = require('../services/comprehend');
const { saveReview, getReviewsByCoin, getAllReviews } = require('../services/dynamo');

router.get('/', async (req, res) => {
  try {
    const reviews = await getAllReviews();

    res.json({
      success: true,
      count: reviews.length,
      data: reviews
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reviews',
      error: error.message
    });
  }
});


router.get('/:coinId', async (req, res) => {
  try {
    const { coinId } = req.params;
    const reviews = await getReviewsByCoin(coinId);

    res.json({
      success: true,
      coinId,
      count: reviews.length,
      data: reviews
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reviews',
      error: error.message
    });
  }
});


router.post('/', async (req, res) => {
  try {
    const { coinId, coinName, reviewText, reviewerName } = req.body;

    if (!coinId || !coinName || !reviewText) {
      return res.status(400).json({
        success: false,
        message: 'Please provide coinId, coinName and reviewText'
      });
    }

    
    if (reviewText.trim().length < 10) {
      return res.status(400).json({
        success: false,
        message: 'Review must be at least 10 characters long'
      });
    }

    
    if (reviewText.trim().length > 4500) {
      return res.status(400).json({
        success: false,
        message: 'Review must not exceed 4500 characters'
      });
    }

    
    console.log(`Analyzing sentiment for ${coinName} review...`);
    const sentimentResult = await analyzeSentiment(reviewText);

    
    const display = getSentimentDisplay(sentimentResult.sentiment);

    
    const savedReview = await saveReview({
      coinId,
      coinName,
      reviewText: reviewText.trim(),
      reviewerName: reviewerName || 'Anonymous',
      ...sentimentResult
      // ...sentimentResult spreads:
      // sentiment, confidence, dominantScore, language
    });

    res.status(201).json({
      success: true,
      message: 'Review submitted and analyzed successfully!',
      data: {
        ...savedReview,
        display
        // display adds: emoji, color, label
      }
    });

  } catch (error) {
    console.error('Review submission error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to submit review',
      error: error.message
    });
  }
});

module.exports = router;