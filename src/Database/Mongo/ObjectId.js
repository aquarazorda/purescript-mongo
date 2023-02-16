'use strict';

import { ObjectId } from "bson";

export const _show = function (oid) {
  return oid;
}

export const _eq = function (a) {
  return function (b) {
    return a === b;
  }
}

export const fromString = function (s) {
  return ObjectId(s);
}
