{ sources = [ "src/**/*.purs", "test/**/*.purs" ]
, name = "mongo"
, dependencies =
  [ "effect", "aff", "simple-json", "node-process", "bifunctors", "either", "exceptions", "foreign", "functions", "maybe", "nullable", "prelude", "record", "typelevel-prelude", "unsafe-coerce" ]
, packages = ./packages.dhall
}
