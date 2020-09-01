const AWS = require('aws-sdk');

exports.handler = async (event, context, callback) => {
    const dynamodb = new AWS.DynamoDB.DocumentClient();

    try {
        const result = await dynamodb.scan({
            TableName: "Teams"
        }).promise();

        return context.succeed(result.Items);
    } catch (e) {
        return context.succeed(e);
    }
}