
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const {
  DynamoDBDocumentClient,
  PutCommand,
  QueryCommand,
  ScanCommand
} = require('@aws-sdk/lib-dynamodb');

// creating connection to dynamoDB
const dynamoClient = new DynamoDBClient({
  region: process.env.AWS_REGION || 'us-east-1'
});

//Wrappint it with DocumentClient makes it easier to work with, it automatically converts JavaScript objects to DynamoDB format and back. Without it you'd have to write: { "S": "hello" } instead of just "hello"
const docClient = DynamoDBDocumentClient.from(dynamoClient);

const REVIEWS_TABLE   = process.env.REVIEWS_TABLE   || 'cryptobliss-reviews';
const FEEDBACK_TABLE  = process.env.FEEDBACK_TABLE  || 'cryptobliss-feedback';

const saveReview = async (reviewData) => {
  // PutCommand = insert a new item into DynamoDB
  const command = new PutCommand({
    TableName: REVIEWS_TABLE,
    Item: {
      reviewId:      `review_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      coinId:        reviewData.coinId,
      coinName:      reviewData.coinName,
      reviewText:    reviewData.reviewText,
      reviewerName:  reviewData.reviewerName || 'Anonymous',
      // Sentiment data from Comprehend
      sentiment:     reviewData.sentiment,
      confidence:    reviewData.confidence,
      dominantScore: reviewData.dominantScore,
      language:      reviewData.language,
      // createdAt = when the review was submitted
      // ISO string looks like: 2024-01-15T10:30:00.000Z
      createdAt:     new Date().toISOString(),
    }
  });

  await docClient.send(command);
  return command.input.Item;
};

const getReviewsByCoin = async (coinId) => {

 
  const command = new ScanCommand({
    TableName: REVIEWS_TABLE,
    FilterExpression: 'coinId = :coinId',
    // ExpressionAttributeValues maps the :coinId
    // placeholder to the actual value we're searching for
    ExpressionAttributeValues: {
      ':coinId': coinId
    }
  });

  const result = await docClient.send(command);

  // Sort reviews by newest first
  return result.Items.sort((a, b) => 
    b.createdAt.localeCompare(a.createdAt)
  );
};

// Fetches every review across all coins
// Used for the sentiment dashboard/overview page
const getAllReviews = async () => {
  const command = new ScanCommand({
    TableName: REVIEWS_TABLE
  });

  const result = await docClient.send(command);
  return result.Items.sort((a, b) =>
    b.createdAt.localeCompare(a.createdAt)
  );
};

// Saves post-transaction feedback to DynamoDB
// Called after a user simulates a buy or sell
const saveFeedback = async (feedbackData) => {
  const command = new PutCommand({
    TableName: FEEDBACK_TABLE,
    Item: {
      feedbackId:    `feedback_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      coinId:        feedbackData.coinId,
      coinName:      feedbackData.coinName,
      action:        feedbackData.action,
      // action = "BUY" or "SELL"
      feedbackText:  feedbackData.feedbackText,
      userName:      feedbackData.userName || 'Anonymous',
      sentiment:     feedbackData.sentiment,
      confidence:    feedbackData.confidence,
      dominantScore: feedbackData.dominantScore,
      language:      feedbackData.language,
      createdAt:     new Date().toISOString(),
    }
  });

  await docClient.send(command);
  return command.input.Item;
};

// Fetches all transaction feedback for a specific coin
const getFeedbackByCoin = async (coinId) => {
  const command = new ScanCommand({
    TableName: FEEDBACK_TABLE,
    FilterExpression: 'coinId = :coinId',
    ExpressionAttributeValues: {
      ':coinId': coinId
    }
  });

  const result = await docClient.send(command);
  return result.Items.sort((a, b) =>
    b.createdAt.localeCompare(a.createdAt)
  );
};

// Counts how many positive, negative, neutral, mixed
const getCoinSentimentSummary = async (coinId) => {
  const reviews = await getReviewsByCoin(coinId);
  const summary = reviews.reduce((acc, review) => {
    const sentiment = review.sentiment;
    acc[sentiment] = (acc[sentiment] || 0) + 1;
    return acc;
  }, {});

  // Figure out the overall dominant sentiment
  const total = reviews.length;
  let dominant = 'NO REVIEWS';

  if (total > 0) {
    // Find which sentiment has the highest count
    dominant = Object.keys(summary).reduce((a, b) =>
      summary[a] > summary[b] ? a : b
    );
  }

  return {
    total,
    dominant,
    breakdown: {
      POSITIVE: summary.POSITIVE || 0,
      NEGATIVE: summary.NEGATIVE || 0,
      NEUTRAL:  summary.NEUTRAL  || 0,
      MIXED:    summary.MIXED    || 0,
    }
  };
};

// Export all functions
module.exports = {
  saveReview,
  getReviewsByCoin,
  getAllReviews,
  saveFeedback,
  getFeedbackByCoin,
  getCoinSentimentSummary
};