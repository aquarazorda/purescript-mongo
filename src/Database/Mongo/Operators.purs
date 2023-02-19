module Database.Mongo.Operators where

import Prelude
import Simple.JSON (class WriteForeign, write)
import Unsafe.Coerce (unsafeCoerce)

foreign import data Operator :: Type

instance writeOperator :: WriteForeign Operator where
  writeImpl = unsafeCoerce

set :: ∀ a. WriteForeign a => a -> Operator
set v = unsafeCoerce $ write { "$set": v }

unset :: ∀ a. WriteForeign a => a -> Operator
unset v = unsafeCoerce $ write { "$unset": v }

setOnInsert :: ∀ a. WriteForeign a => a -> Operator
setOnInsert v = unsafeCoerce $ write { "$setOnInsert": v }

currentDate :: ∀ a. WriteForeign a => a -> Operator
currentDate v = unsafeCoerce $ write { "$currentDate": v }
