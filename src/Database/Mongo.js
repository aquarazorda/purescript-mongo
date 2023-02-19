'use strict';

import { MongoClient } from 'mongodb';

export const _connect = async (uri, left, right) => {
  var client = MongoClient;
  try {
    const conn = await client.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });
    return right(conn);
  } catch (err) {
    return left(err);
  }
};

export const _defaultDb = function _defaultDb(client) {
  return client.db();
}

export const _db = function _defaultDb(dbName, options, client) {
  return client.db(dbName, options);
}

export const __db = function _defaultDb(dbName, client) {
  return client.db(dbName);
}

export const _handleParseFailure = function _handleParseFailure(err, canceler, errback) {
  process.nextTick(function () {
    errback(err)();
  });
  var client = MongoClient;
  return canceler(client);
};

export const _close = function _close(client, canceler, callback, left, right) {
  client.close(function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });
  return canceler({});
};

export const _collection = async (name, db, left, right) => {
  try {
    const collection = await db.collection(name);
    return right(collection);
  } catch (error) {
    return left(error);
  }
};

export const _collect = function _collect(cursor, canceler, callback, left, right) {
  cursor.toArray(function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });
  return canceler(cursor);
};

export const _collectOne = function _collectOne(cursor, canceler, callback, left, right) {
  cursor.next(function (err, x) {
    if (err) {
      callback(left(err))();
    } else if (x === null) {
      var error = new Error('Not Found.');
      error.name = 'MongoError';
      callback(left(error))();
    } else {
      callback(right(x))();
    }
  });
  return canceler(cursor);
};

export const _findOne = async (selector, fields, collection, left, right) => {
  try {
    const res = await collection.findOne(selector, fields);
    return res ? right(res) : left({ success: false });
  } catch (err) {
    return left(err);
  }
};

export const _find = async (selector, fields, collection, left, right) => {
  try {
    const res = await collection.find(selector, fields);
    return res ? right(res) : left({ success: false });
  } catch (err) {
    return left(err);
  }
};

export const _insertOne = async (json, options, collection, left, right) => {
  try {
    const res = await collection.insertOne(json, options);
    return res ? right(res) : left({ success: false });
  } catch (err) {
    return left(err);
  }
};

export const _insertMany = async (json, options, collection, left, right) => {
  try {
    const { res } = await collection.insertMany(json, options);
    return res ? right(res) : left({ success: false });
  } catch (err) {
    return left(err);
  }
};

export const _updateOne = async (selector, operators, options, collection, left, right) => {
  try {
    const ops = Object.assign({}, ...operators);
    const res = await collection.updateOne(selector, ops, options);
    return res ? right(res) : left({ success: false });
  } catch (err) {
    return left(err);
  }
};

export const _updateMany = async (selector, json, options, collection, left, right) => {
  try {
    const res = await collection.updateMany(selector, { $set: json }, options);
    return res ? right(res) : left({ success: false });
  } catch (err) {
    return left(err);
  }
};

export const _countDocuments = function (selector, options, collection, canceler, callback, left, right) {
  collection["countDocuments"](selector, options, function (err, x) {
    (err ? callback(left(err)) : callback(right(x.result)))();
  });

  return canceler(collection);
};

export const _aggregate = function (pipeline, options, collection, canceler, callback, left, right) {
  collection["aggregate"](pipeline, options, function (err, x) {
    (err ? callback(left(err)) : callback(right(x)))();
  });

  return canceler(collection);
};
