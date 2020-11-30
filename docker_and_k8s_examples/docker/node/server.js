'use strict';

const express = require('express');
const mongoose = require('mongoose');

// Web app Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// Mongo creds
const MONGO_HOST = "mongo"
const MONGO_PORT = "27017"
const MONGO_DB_URL = `mongodb://${MONGO_HOST}:${MONGO_PORT}/testdb`

// Mongo conn
mongoose.connect(MONGO_DB_URL, (err) => {
  if (err)
    console.error("Error occured while connecting to mongo db")
  else
    console.log("Database connection established correctly")
});

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello World');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);