## Test automation integrated in AWS Step Function Workflow
AWS Step Function is an AWS resource that offers serverless function orchestration and makes it easy to sequence multiple AWS resources into one business workflow. With this example we will demonstrate the concept of development and application of the Step Function, with test automation integrated in its workflow.
This repository is divided in two parts, one for Step Function definition including its AWS Lambdas and second part is test automation with test automation scripts and GitHub Actions. Both parts are using the same dependencies from package.json.

## Starting point
Install serverless framework via NPM
-------
    `npm install -g serverless`
After cloning the repository install node packages
-------
    `npm install`

## Step Function definition
Step Function is defined in serverless.yml file, AWS Lambdas are defined in handler.js, and environment variables should be defined in env.json.

First, configure AWS credentials for serverless framework by running following command:
-------
    `sls config credentials --provider aws --key <YOUR_ACCESS_KEY> --secret <YOUR_SECRET_KEY>`

Second, deploy the Step Function to AWS account by running following command:
-------
    `sls deploy`

## Test automation
Here are two test automation scripts inside 'test-automation' folder. First one is for the data generation (insertMessageDynamoDB.test.js), and second one is for the data verification (verifyStepFunctionOutcome.test.js).

You can run them locally by following commands:
-------
    `npm test test-automation/insertMessageDynamoDB.test.js`
-------
    `npm test test-automation/verifyStepFunctionOutcome.test.js`

For complete CI/CD we are using GitHub Actions, defined in .github folder. We have two YAML files for each test automation script that should be triggered by AWS Lambdas.

GitHub credentials and Actions Workflow triggers should be defined in env.json. AWS secrets should be defined on GitHub secrets.
