const { S3, DeleteObjectCommand, GetObjectCommand, PutObjectCommand } = require('@aws-sdk/client-s3');

class S3Client {

    s3Client;

    constructor() {
        this.s3Client = new S3({ region: 'eu-central-1' });
    }

    async getObject(bucketName, key) {
        try {
            const params = {
                Bucket: bucketName,
                Key: key
            };
            const getObjectCommand = new GetObjectCommand(params);
            const response = await this.s3Client.send(getObjectCommand);
            const bodyStream = response.Body;
            let data = "";

            for await (const chunk of bodyStream) {
                data += chunk;
            }

            const object = JSON.parse(data);
            return object;
        } catch (error) {
            console.log(error);
            return null;
        }
    }

    async removeObject(bucketName, key) {
        try {
            const params = {
                Bucket: bucketName,
                Key: key
            };
            const removeObjectCommand = new DeleteObjectCommand(params);
            await this.s3Client.send(removeObjectCommand);
        } catch (error) {
            console.log(error);
            return null;
        }
    }

    async uploadFileToS3(bucketName, key, body, contentType) {
        try {
            const params = {
                Bucket: bucketName,
                Key: key,
                Body: body,
                ContentType: contentType
            }
            const putObjectCommand = new PutObjectCommand(params);
            await this.s3Client.send(putObjectCommand);
        } catch (error) {
            console.log(error);
            return null;
        }
    }
}

module.exports = S3Client;