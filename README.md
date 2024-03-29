# RediSolar for Node.js

# Introduction

This is a simple application that uses Redis as a backend Database for Solar sites monitoring system.

---

[![CircleCI](https://circleci.com/gh/tutugodfrey/redis-solar.svg?style=svg)](https://circleci.com/gh/tutugodfrey/redis-solar)

---

## Architecture Diagram
![Data center Architecture Diagram](RediSolar.png)

---

# Prerequisites

In order to start and run this application, you will need:

* [Node.js](https://nodejs.org/en/download/) (8.9.4 or newer, we recommend using the current Long Term Stable version)
* npm (installed with Node.js)
* Access to a local or remote installation of [Redis](https://redis.io/download) version 5 or newer

# Enable RedisSeries Module
Depending on how Redis is setup, you may need to install and enable Redis time series module when starting Redis. Then start the Redis server by specifying the location of the time series module.

[Instruction on how to download RedisTimeseries](https://oss.redislabs.com/redistimeseries/#setup)

**Starting the Redis server with time series enable**

`$redis-server --loadmodule /path/to/module/redistimeseries.so`

E.g 
```
$ redis-server --loadmodule ~/RedisTimeSeries/bin/redistimeseries.so
```
**Note:** Some test are dependent on the Time Series module

# Setup

To get started with the default configuration (server on port 8081, Redis on localhost port 6379):

```
$ npm install
$ npm run dev
```

This should start a live reloading server that uses [nodemon](https://www.npmjs.com/package/nodemon).  You should be able to see the front end solar dashboard app at: 

```
http://localhost:8081/
```

# Configuration 

The application uses a configuration file, `config.json` to specify the port that it listens 
on plus some logging parameters and how it connects to a database.

There are two options for the database, `static` or `redis`.  `static` just returns static 
responses and all write operations will do nothing.  It is included to show how you could 
organize your code using the DAO pattern when you might have more than one database type 
to consider.

You should use the `redis` database, and the supplied `config.json` file is already set up 
to use Redis on localhost port 6379.

```
{
  "application": {
    "port": 8081,
    "logLevel": "debug",
    "dataStore": "redis"
  },
  "dataStores": {
    "redis": {
      "host": "localhost",
      "port": 6379,
      "keyPrefix": "ru102js"
    },
    "static": {}
  }
}
```

The `keyPrefix` for Redis is used to namespace all the keys that the application generates or 
references.  So for example a key 'sites:999' would be 'ru102js:sites:999' when written to Redis.

# Load Sample Data

To load sample site data and sample metrics, run:

```
npm run load src/resources/data/sites.json flushdb
```

`flushdb` is optional, and will erase ALL data from Redis before inserting the sample data.

The application uses the key prefix `ru102js` by default, so you should be able to use the 
same Redis instance for this application and other data if necessary.

# Development Workflow

In order to speed up development, you can run the application using `nodemon`, so that any 
changes to source code files cause the server to reload and start using your changes.

```
npm run dev
```

Edit code, application will hot reload on save.

## Running Tests

The project is setup to use [Jest](https://jestjs.io/en/) for testing.  To run all tests:

```
npm test
```

To run a specific suite of tests (e.g. those in `tests/basic.test.js`):

```
npm test -t basic
```

To run Jest continuously in watch mode, which gives you access to menus allowing you to run 
subsets of tests and many more options:

```
npm testdev
```

## Linting

This project uses [ESLint](https://eslint.org/) with a slightly modified version of the 
[Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript).

* The file `.eslintrc` contains a short list of rules that have been disabled for this project.
* The file `.eslintignore` contains details of paths that the linter will not consider when 
linting the project.

To run the linter:

```
npm run lint
```

# Application Deployment

Click on the link below for instructions on how to deploy the application

[Deployment to AWS Cloud](aws-cloud-infra/README.md)



---
**Discliamer:** I (Tutu Godfrey), did not build the application from ground up. My initial contact with this application occur while  I was taking the Redis for Javascript developers course from Redis University. However, the application has provided a basis for me to develop and build on other skills. For example, I am developing and demonstrating my DevOps expertise by building various infrastructure that can serve as Deployment platform for the application.
