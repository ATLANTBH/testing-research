const { DynamoDBClient, PutItemCommand, ScanCommand, UpdateItemCommand } = require('@aws-sdk/client-dynamodb');
const dynamoDbClient = new DynamoDBClient({ region: 'eu-central-1' });

module.exports.FetchFromDynamoDBState = async () => {
    try {
        const params = {
            TableName: 'messages',
            FilterExpression: 'is_processed = :processed',
            ExpressionAttributeValues: {
                ':processed': { BOOL: false },
            }
        };
        const scanCommand = new ScanCommand(params);
        let result = await dynamoDbClient.send(scanCommand);
        const items = result.Items;
        return {
            items
        };
    } catch (error) {
        throw error;
    }
}

module.exports.ProcessUSUsersEvents = async (item) => {
    return await processUsersEvents(item, 'US_users_events');
}

module.exports.ProcessEUUsersEvents = async (item) => {
    return await processUsersEvents(item, 'EU_users_events');
}

const processUsersEvents = async (item, tableName) => {
    let dataProcessed = false;
    try {
        await processItem(item, tableName);
        await updateIsProcessedColumn(item.ID.S);
        dataProcessed = true;
    } catch (error) {
        console.log(error);
    }
    return dataProcessed;
}


const processItem = async (item, tableName) => {
    const eventItem = {
        ID: { S: item.ID.S },
        fName: { S: item.fName.S },
        lName: { S: item.lName.S },
        points: { N: item.points.N },
    }
    const params = {
        TableName: tableName,
        Item: eventItem
    };
    const command = new PutItemCommand(params);
    await dynamoDbClient.send(command);
}

const updateIsProcessedColumn = async (itemId) => {
    const paramsForUpdate = {
        TableName: 'messages',
        Key: {
            ID: { S: itemId },
            UpdateExpression: 'SET is_processed = :value',
            ExpressionAttributeValues: { ':value': { BOOL: true } },
            ReturnValues: 'UPDATED_NEW'
        }
    };
    const updateItemCommand = new UpdateItemCommand(paramsForUpdate);
    await dynamoDbClient.send(updateItemCommand);
}

const axios = require('axios');

module.exports.InsertMessageDynamoDBTest = async () => {
    await triggerWorkflow(process.env.INSERT_ACTION_TRIGGER_ID);
}

module.exports.VerifyStepFunctionOutcomeTest = async () => {
    await triggerWorkflow(process.env.VERIFY_ACTION_TRIGGER_ID);
}

const triggerWorkflow = async (workFlowId) => {
    const owner = process.env.GITHUB_OWNER;
    const repo = process.env.GITHUB_REPO;
    const token = process.env.GITHUB_TOKEN;
    let response;

    try {
        response = await axios.post(
            `https://api.github.com/repos/${owner}/${repo}/actions/workflows/${workFlowId}/dispatches`,
            {
                ref: 'main'
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            }
        );

        console.log('Job triggered successfully:', response.data);
    } catch (error) {
        console.error('Failed to trigger job:', error.response.data);
    }

    return response;
}
