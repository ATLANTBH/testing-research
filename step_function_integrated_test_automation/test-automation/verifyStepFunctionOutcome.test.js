const { DynamoDBClient, ScanCommand } = require('@aws-sdk/client-dynamodb');
const dynamoDbClient = new DynamoDBClient({ region: 'eu-central-1' });
const S3Client = require('./S3Client');

describe('Verify that message has been processed', () => {
    let item;
    const s3Client = new S3Client();
    beforeAll(async () => {
        item = await s3Client.getObject('sfn-blog', 'test-message.json');
    }, 200000);

    it('Verify DynamoDB US_users_events', async () => {
        const params = {
            TableName: 'US_users_events'
        };

        const scanCommand = new ScanCommand(params);
        const response = await dynamoDbClient.send(scanCommand);
        const records = response.Items;
        const testRecord = records.filter(it => it.ID.S == item.ID.S);
        expect(testRecord.length).toBe(1);
        expect(testRecord[0].fName.S).toBe(item.fName.S);
        expect(testRecord[0].lName.S).toBe(item.lName.S);
        expect(testRecord[0].points.N).toBe(item.points.N);
    }, 20000);
});