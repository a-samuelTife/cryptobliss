
const {
  ComprehendClient,
  DetectSentimentCommand,
  DetectDominantLanguageCommand
} = require('@aws-sdk/client-comprehend');

//creating comprehend connection
const comprehendClient = new ComprehendClient({
  region: process.env.AWS_REGION || 'us-east-1'
});


const detectLanguage = async (text) => {
  const command = new DetectDominantLanguageCommand({
    Text: text
  });

  const result = await comprehendClient.send(command);

  return result.Languages[0].LanguageCode;
};

// this will analyze sentiment 
const analyzeSentiment = async (text) => {
  try {
    // Step 1: detect language automatically
    const language = await detectLanguage(text);

    // Step 2: send text to Comprehend for sentiment
    const command = new DetectSentimentCommand({
      Text: text,
      LanguageCode: language
    });

    const result = await comprehendClient.send(command);
    const scores = result.SentimentScore;
    return {
      sentiment: result.Sentiment,
      // sentiment is one of:
      // POSITIVE, NEGATIVE, NEUTRAL, MIXED
      confidence: {
        positive: (scores.Positive * 100).toFixed(2) + '%',
        negative: (scores.Negative * 100).toFixed(2) + '%',
        neutral:  (scores.Neutral  * 100).toFixed(2) + '%',
        mixed:    (scores.Mixed    * 100).toFixed(2) + '%',
      },
      // dominantScore = how confident Comprehend is
      dominantScore: (Math.max(
        scores.Positive,
        scores.Negative,
        scores.Neutral,
        scores.Mixed
      ) * 100).toFixed(2) + '%',
      language: language
    };

  } catch (error) {
    console.error('Comprehend error:', error.message);
    throw new Error('Failed to analyze sentiment: ' + error.message);
  }
};

const getSentimentDisplay = (sentiment) => {
  const display = {
    POSITIVE: { emoji: '😊', color: '#16A34A', label: 'Positive' },
    NEGATIVE: { emoji: '😞', color: '#DC2626', label: 'Negative' },
    NEUTRAL:  { emoji: '😐', color: '#CA8A04', label: 'Neutral'  },
    MIXED:    { emoji: '🤔', color: '#7C3AED', label: 'Mixed'    },
  };

  // Return the matching display or a default
  return display[sentiment] || { 
    emoji: '❓', 
    color: '#6B7280', 
    label: 'Unknown' 
  };
};

// Export all three functions so other files can use them
module.exports = { 
  analyzeSentiment, 
  detectLanguage,
  getSentimentDisplay 
};