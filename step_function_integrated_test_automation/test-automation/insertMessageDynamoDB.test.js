const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');
const dynamoDbClient = new DynamoDBClient({ region: 'eu-central-1' });
const S3Client = require('./S3Client');

describe('Adding message to the DynamoDB messages table', () => {
    let item;
    beforeAll(async () => {
        item = {
            ID: { S: new Date().toISOString() },
            fName: { S: 'Test_First_Name' },
            lName: { S: 'Test_Last_Name' },
            points: { N: '500' },
            is_processed: { BOOL: false },
            region: { S: 'US' }
        };
    });
    it('Adding message', async () => {
        const params = {
            TableName: 'messages',
            Item: item
        };

        try {
            const command = new PutItemCommand(params);
            await dynamoDbClient.send(command);
            console.log('Data inserted successfully.');
        } catch (error) {
            console.log('Error inserting data:', error);
        }
    }, 10000);

    it('Save message to S3 as a job artifact ', async () => {
        const s3Client = new S3Client();
        const bucket = 'sfn-blog';
        const key = 'test-message.json';
        await s3Client.removeObject(bucket, key);

        await s3Client.uploadFileToS3(
            bucket,
            key,
            JSON.stringify(item),
            'application/json'
        );
    }, 20000);

});