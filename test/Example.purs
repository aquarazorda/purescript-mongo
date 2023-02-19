module Database.Mongo.Example where

import Data.Either (Either(..))
import Database.Mongo (defaultFindOptions)
import Database.Mongo as Mongo
import Database.Mongo.Query (Query)
import Database.Mongo.Query as Q
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Node.Process (exit)
import Prelude (Unit, bind, ($), discard)

main :: Effect Unit
main = launchAff_ $ do
  client <- Mongo.connect "mongodb://user:pass@host:port/db"
  case client of
    Left _ -> do
      liftEffect $ exit 1
    Right client -> do
      let db = Mongo.db "db" client
      col <- Mongo.collection "item" db
      -- _ <- Mongo.find searchQuery defaultFindOptions col
      liftEffect $ exit 0

type Item = { id :: Int, name :: String, inner :: Inner  }

type Inner = { number :: Number } 

searchQuery :: Query Item
searchQuery = Q.or
  [ Q.by { id: Q.eq 26637 }
  , Q.by { inner: { number: Q.lte 10.0 } }
  ]
