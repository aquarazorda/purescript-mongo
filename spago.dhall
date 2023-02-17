{ sources = [ "src/**/*.purs", "test/**/*.purs" ]
, name = "mongo"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "bifunctors"
  , "effect"
  , "either"
  , "exceptions"
  , "foreign"
  , "functions"
  , "maybe"
  , "node-process"
  , "nullable"
  , "prelude"
  , "record"
  , "simple-json"
  , "typelevel-prelude"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
}
