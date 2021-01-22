'use strict';

const express = require('express');
const mongodb = require('mongodb');
const bodyParser = require('body-parser');
const fs = require('fs');
const yaml = require('js-yaml');

// Web app Constants
const PORT = 8080;
const HOST = '0.0.0.0';

const config = yaml.load(fs.readFileSync('/config/environment.yaml', 'utf-8'));

// Mongo creds
const MONGO_HOST = config.environment.mongo.host
const MONGO_PORT = config.environment.mongo.port
const MONGO_DB_NAME = process.env.MONGO_DB_NAME || 'testdb'
const MONGO_DB_COLLECTION = process.env.MONGO_DB_NAME || 'employees'
const MONGO_DB_URL = `mongodb://${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB_NAME}`

// Mongo client
const MongoClient = mongodb.MongoClient;

MongoClient.connect(MONGO_DB_URL, (err, client) => {
  if (err) { throw err; }
  console.log(`Database connection successfully in environment: ${config.environment.name}`);
  client.close();
});

// App
const app = express();
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

app.get('/ping', (req, res) => {
  res.send({ 'message': 'pong from version v1! '})
});

app.get('/employees', (req, res) => {
  MongoClient.connect(MONGO_DB_URL, function(err, client) {
    if (err) throw err;
    const db = client.db(MONGO_DB_NAME);

    db.collection(MONGO_DB_COLLECTION).find({}).toArray(function(err, result) {
      if (err) throw err;
      res.send(result);
      client.close();
    });
  }); 
});

app.post('/employee', function(req, res) {
  const employeeContent = req.body;
  MongoClient.connect(MONGO_DB_URL, function(err, client) {
    if (err) throw err;
    const db = client.db(MONGO_DB_NAME);
    const collection = db.collection(MONGO_DB_COLLECTION)

    collection.insertOne(employeeContent, (err, result) => {
      if (err) { throw err; }
      console.log(result.result);
    });
    client.close();
  }); 
  res.send('Employee has been added successfully!');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);