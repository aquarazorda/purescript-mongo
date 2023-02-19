module Database.Mongo
  ( Client
  , Database
  , Collection
  , Cursor
  , connect
  , defaultDb
  , db
  , close
  , collection
  , insertOne
  , insertMany
  , updateOne
  , updateOne'
  , updateMany
  , updateMany'
  , find
  , findOne
  , countDocuments
  , aggregate
  , defaultFindOptions
  , defaultCountOptions
  , defaultAggregationOptions
  , module Database.Mongo.Types
  , module Database.Mongo.ObjectId
  , module Database.Mongo.Options
  ) where

import Prelude
import Control.Bind (bindFlipped)
import Control.Promise (Promise, toAffE)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn5, Fn7, runFn1, runFn2, runFn5, runFn7)
import Data.Nullable (null)
import Database.Mongo.ObjectId (ObjectId)
import Database.Mongo.Operators (Operator, set)
import Database.Mongo.Options (defaultInsertOptions, defaultUpdateOptions, InsertOptions, UpdateOptions)
import Database.Mongo.Query (Query)
import Database.Mongo.Types (AggregationOptions, CountOptions, InsertOneResult, InsertManyResult, UpdateResult, FindOptions)
import Effect (Effect)
import Effect.Aff (Aff, Canceler, error, makeAff, nonCanceler)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Exception (Error)
import Effect.Uncurried (EffectFn3, EffectFn4, EffectFn5, EffectFn6, runEffectFn3, runEffectFn4, runEffectFn5, runEffectFn6)
import Foreign (Foreign)
import Simple.JSON (class ReadForeign, class WriteForeign, read, write)

foreign import data Client :: Type

foreign import data Database :: Type

foreign import data Collection :: Type -> Type

foreign import data Cursor :: Type

-- | Connect to MongoDB using a url as documented at
-- | docs.mongodb.org/manual/reference/connection-string/
connect :: String -> Aff (Either Error Client)
connect str = toAffE $ runEffectFn3 _connect str Left Right

-- | Get the default database
defaultDb :: Client -> Database
defaultDb = runFn1 _defaultDb

-- | Get database from client by name 
db :: String -> Client -> Database
db = runFn2 __db

-- | Close the connection to the database
close :: ∀ m. MonadAff m => Client -> m Unit
close cli =
  liftAff
    $ makeAff \cb ->
        runFn5 _close cli noopCancel cb Left Right

-- | Fetch a specific collection by name
collection :: ∀ a. String -> Database -> Aff (Either Error (Collection a))
collection name d = toAffE $ runEffectFn4 _collection name d Left Right

-- | Fetches the an array of documents that match the query
find :: ∀ a. ReadForeign a => Query a -> FindOptions -> Collection a -> Aff (Either Error (Array a))
find q opts col = toAffE $ runEffectFn5 _find (write q) opts col Left Right

-- | Fetches the first document that matches the query
findOne :: ∀ a. ReadForeign a => Query a -> FindOptions -> Collection a -> Aff (Either Error a)
findOne q opts col = toAffE $ runEffectFn5 _findOne (write q) opts col Left Right

-- | Inserts a single document into MongoDB
insertOne ::
  ∀ a.
  WriteForeign a =>
  a ->
  InsertOptions ->
  Collection a ->
  Aff (Either Error InsertOneResult)
insertOne j o c = toAffE $ runEffectFn5 _insertOne (write j) (write o) c Left Right

-- | Inserts an array of documents into MongoDB
insertMany ::
  ∀ a.
  WriteForeign a =>
  Array a ->
  InsertOptions ->
  Collection a ->
  Aff (Either Error InsertManyResult)
insertMany j o c = toAffE $ runEffectFn5 _insertMany (write j) (write o) c Left Right

-- | Update a single document in a collection
-- | by passing Operators to the update
updateOne ::
  ∀ a.
  WriteForeign a =>
  Query a ->
  Array Operator ->
  UpdateOptions ->
  Collection a ->
  Aff (Either Error UpdateResult)
updateOne q op o c = toAffE $ runEffectFn6 _updateOne (write q) (write op) (write o) c Left Right

-- | Update a single document in a collection
-- | by passing a document to the update as second argument
updateOne' ::
  ∀ a.
  WriteForeign a =>
  Query a ->
  a ->
  UpdateOptions ->
  Collection a ->
  Aff (Either Error UpdateResult)
updateOne' q u o c = updateOne q [ set u ] o c

-- | Update a single document in a collection
updateMany ::
  ∀ a.
  WriteForeign a =>
  Query a ->
  Array Operator ->
  UpdateOptions ->
  Collection a ->
  Aff (Either Error a)
updateMany q u o c = toAffE $ runEffectFn6 _updateMany (write q) (write u) (write o) c Left Right

updateMany' ::
  ∀ a.
  WriteForeign a =>
  Query a ->
  a ->
  UpdateOptions ->
  Collection a ->
  Aff (Either Error a)
updateMany' q u o c = updateMany q [ set u ] o c

-- | Gets the number of documents matching the filter
countDocuments :: ∀ a m. MonadAff m => Query a -> CountOptions -> Collection a -> m Int
countDocuments q o col =
  liftAff
    $ makeAff \cb ->
        runFn7 _countDocuments (write q) o col noopCancel cb Left Right

-- | WIP: implement typesafe aggregation pipelines
-- | Calculates aggregate values for the data in a collection
aggregate ::
  ∀ a m.
  ReadForeign a =>
  MonadAff m =>
  Array Foreign ->
  AggregationOptions ->
  Collection a ->
  m (Array a)
aggregate p o col = liftAff $ makeAff aggregate' >>= collect
  where
  aggregate' cb = runFn7 _aggregate p o col noopCancel cb Left Right

defaultFindOptions :: FindOptions
defaultFindOptions = { limit: null, skip: null, sort: null }

defaultCountOptions :: CountOptions
defaultCountOptions = { limit: null, maxTimeMS: null, skip: null, hint: null }

defaultAggregationOptions :: AggregationOptions
defaultAggregationOptions =
  { explain: null
  , allowDiskUse: null
  , cursor: null
  , maxTimeMS: null
  , readConcern: null
  , hint: null
  }

collect :: ∀ a m. ReadForeign a => MonadAff m => Cursor -> m (Array a)
collect cur =
  liftAff
    $ makeAff \cb ->
        runFn5 _collect cur noopCancel (cb <<< bindFlipped parse) Left Right
  where
  parse = lmap (error <<< show) <<< read

-- | Do nothing on cancel.
noopCancel :: forall a. a -> Canceler
noopCancel _ = nonCanceler

foreign import _connect ::
  EffectFn3 String
    (Error -> Either Error Client)
    (Client -> Either Error Client)
    (Promise (Either Error Client))

foreign import _defaultDb :: Fn1 Client Database

foreign import _db :: Fn3 String Foreign Client Database

foreign import __db :: Fn2 String Client Database

foreign import _handleParseFailure ::
  Fn3 Error
    (Client -> Canceler)
    (Error -> Effect Unit)
    (Effect Canceler)

foreign import _close ::
  Fn5 Client
    (Unit -> Canceler)
    (Either Error Unit -> Effect Unit)
    (Error -> Either Error Unit)
    (Unit -> Either Error Unit)
    (Effect Canceler)

foreign import _collection ::
  ∀ a.
  EffectFn4 String
    Database
    (Error -> Either Error (Collection a))
    (Collection a -> Either Error (Collection a))
    (Promise (Either Error (Collection a)))

foreign import _collect ::
  Fn5 Cursor
    (Cursor -> Canceler)
    (Either Error Foreign -> Effect Unit)
    (Error -> Either Error Foreign)
    (Foreign -> Either Error Foreign)
    (Effect Canceler)

foreign import _collectOne ::
  Fn5 Cursor
    (Cursor -> Canceler)
    (Either Error Foreign -> Effect Unit)
    (Error -> Either Error Foreign)
    (Foreign -> Either Error Foreign)
    (Effect Canceler)

foreign import _findOne ::
  ∀ a.
  EffectFn5 Foreign
    FindOptions
    (Collection a)
    (Error -> Either Error Foreign)
    (Foreign -> Either Error Foreign)
    (Promise (Either Error a))

foreign import _find ::
  ∀ a.
  EffectFn5 Foreign
    FindOptions
    (Collection a)
    (Error -> Either Error Cursor)
    (Cursor -> Either Error Cursor)
    (Promise (Either Error (Array a)))

foreign import _insertOne ::
  ∀ a.
  EffectFn5
    Foreign
    Foreign
    (Collection a)
    (Error -> Either Error Foreign)
    (Foreign -> Either Error Foreign)
    (Promise (Either Error InsertOneResult))

foreign import _insertMany ::
  ∀ a.
  EffectFn5
    Foreign
    Foreign
    (Collection a)
    (Error -> Either Error Foreign)
    (Foreign -> Either Error Foreign)
    (Promise (Either Error InsertManyResult))

foreign import _updateOne ::
  ∀ a.
  EffectFn6
    Foreign
    Foreign
    Foreign
    (Collection a)
    (Error -> Either Error Foreign)
    (Foreign -> Either Error Foreign)
    (Promise (Either Error UpdateResult))

foreign import _updateMany ::
  ∀ a.
  EffectFn6
    Foreign
    Foreign
    Foreign
    (Collection a)
    (Error -> Either Error Foreign)
    (Foreign -> Either Error Foreign)
    (Promise (Either Error a))

foreign import _countDocuments ::
  ∀ a.
  Fn7 Foreign
    (CountOptions)
    (Collection a)
    (Collection a -> Canceler)
    (Either Error Int -> Effect Unit)
    (Error -> Either Error Int)
    (Int -> Either Error Int)
    (Effect Canceler)

foreign import _aggregate ::
  ∀ a.
  Fn7 (Array Foreign)
    (AggregationOptions)
    (Collection a)
    (Collection a -> Canceler)
    (Either Error Cursor -> Effect Unit)
    (Error -> Either Error Cursor)
    (Cursor -> Either Error Cursor)
    (Effect Canceler)
