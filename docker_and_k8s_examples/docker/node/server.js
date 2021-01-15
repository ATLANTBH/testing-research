'use strict';

const express = require('express');
const mongodb = require('mongodb');
const bodyParser = require('body-parser');

// Web app Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// Mongo creds
const MONGO_HOST = process.env.MONGO_HOST || 'mongo'
const MONGO_PORT = process.env.MONGO_PORT || '8080'
const MONGO_DB_NAME = process.env.MONGO_DB_NAME || 'testdb'
const MONGO_DB_COLLECTION = process.env.MONGO_DB_NAME || 'employees'
const MONGO_DB_URL = `mongodb://${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB_NAME}`

// Mongo client
const MongoClient = mongodb.MongoClient;

MongoClient.connect(MONGO_DB_URL, (err, client) => {
  if (err) { throw err; }
  console.log('Database connection successful');
  client.close();
});

// App
const app = express();
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

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