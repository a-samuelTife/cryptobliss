const express = require('express');
const router = express.Router();

// this will import our coins data and dynamo service
const coins = require('../coins');
const { getCoinSentimentSummary } = require('../services/dynamo');

// Returns all 20 coins with their basic information
router.get('/', async (req, res) => {
  try {
    const coinsWithSentiment = await Promise.all(
      coins.map(async (coin) => {
        try {
          const sentiment = await getCoinSentimentSummary(coin.id);
          return { ...coin, sentiment };
        } catch (err) {
          // If sentiment fetch fails for one coin
          // still return the coin with empty sentiment
          return {
            ...coin,
            sentiment: {
              total: 0,
              dominant: 'NO REVIEWS',
              breakdown: {
                POSITIVE: 0,
                NEGATIVE: 0,
                NEUTRAL: 0,
                MIXED: 0
              }
            }
          };
        }
      })
    );

    res.json({
      success: true,
      count: coinsWithSentiment.length,
      data: coinsWithSentiment
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch coins',
      error: error.message
    });
  }
});

// Returns one specific coin by its id
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Find the coin in our data array
    const coin = coins.find(c => c.id === id);

    // If coin not found return 404
    if (!coin) {
      return res.status(404).json({
        success: false,
        message: `Coin with id "${id}" not found`
      });
    }

    // Get sentiment summary for this coin
    const sentiment = await getCoinSentimentSummary(coin.id);

    res.json({
      success: true,
      data: { ...coin, sentiment }
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch coin',
      error: error.message
    });
  }
});

module.exports = router;