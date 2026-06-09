const express = require('express');
const router = express.Router();

const { analyzeSentiment, getSentimentDisplay } = require('../services/comprehend');
const { saveFeedback, getFeedbackByCoin } = require('../services/dynamo');


router.get('/:coinId', async (req, res) => {
  try {
    const { coinId } = req.params;
    const feedback = await getFeedbackByCoin(coinId);

    res.json({
      success: true,
      coinId,
      count: feedback.length,
      data: feedback
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch feedback',
      error: error.message
    });
  }
});


router.post('/', async (req, res) => {
  try {
    const { 
      coinId, 
      coinName, 
      action, 
      feedbackText, 
      userName 
    } = req.body;

    if (!coinId || !coinName || !action || !feedbackText) {
      return res.status(400).json({
        success: false,
        message: 'Please provide coinId, coinName, action and feedbackText'
      });
    }

    // Action must be either BUY or SELL
    if (!['BUY', 'SELL'].includes(action.toUpperCase())) {
      return res.status(400).json({
        success: false,
        message: 'Action must be either BUY or SELL'
      });
    }

    if (feedbackText.trim().length < 10) {
      return res.status(400).json({
        success: false,
        message: 'Feedback must be at least 10 characters long'
      });
    }

    if (feedbackText.trim().length > 4500) {
      return res.status(400).json({
        success: false,
        message: 'Feedback must not exceed 4500 characters'
      });
    }

    console.log(`Analyzing sentiment for ${action} feedback on ${coinName}...`);
    const sentimentResult = await analyzeSentiment(feedbackText);

    const display = getSentimentDisplay(sentimentResult.sentiment);

    const savedFeedback = await saveFeedback({
      coinId,
      coinName,
      action: action.toUpperCase(),
      feedbackText: feedbackText.trim(),
      userName: userName || 'Anonymous',
      ...sentimentResult
    });

    res.status(201).json({
      success: true,
      message: `${action.toUpperCase()} feedback submitted and analyzed!`,
      data: {
        ...savedFeedback,
        display
      }
    });

  } catch (error) {
    console.error('Feedback submission error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to submit feedback',
      error: error.message
    });
  }
});

module.exports = router;