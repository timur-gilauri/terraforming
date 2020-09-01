const AWS = require('aws-sdk')

exports.handler = async (event, context, callback) => {
  const dynamodb = new AWS.DynamoDB.DocumentClient()

  try {
    const items = JSON.parse(event.body).map(item => {
      return {
        PutRequest: {
          Item: {
            ...item
          }
        }
      }
    })

    await dynamodb.batchWrite({
      RequestItems: {
        'Teams': items
      }
    }).promise()

    return callback(null, { statusCode: 200, body: 'Items successfully saved to DB' })
  } catch (e) {
    return callback(null, {statusCode: 200, body: e.message})
  }
}