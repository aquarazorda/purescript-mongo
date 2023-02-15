let mkPackage =
      https://raw.githubusercontent.com/spacchetti/spacchetti/20181209/src/mkPackage.dhall
        sha256:0b197efa1d397ace6eb46b243ff2d73a3da5638d8d0ac8473e8e4a8fc528cf57

let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.7-20230215/packages.dhall
        sha256:b8d513f39bfc07e2198b4575334ba2d7e59d22f174d38568f1d86faee218947e

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
