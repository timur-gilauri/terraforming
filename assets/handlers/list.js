const AWS = require('aws-sdk')

exports.handler = async (event, context, callback) => {
  const dynamodb = new AWS.DynamoDB.DocumentClient()

  try {
    const result = await dynamodb.scan({
      TableName: 'Teams'
    }).promise()

    callback(null, {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(result.Items)
    })
  } catch (e) {
    return callback(e)
  }
}