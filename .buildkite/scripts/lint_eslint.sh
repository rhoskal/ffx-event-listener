#!/bin/bash

set -euo pipefail

nix-shell --run "pnpm eslint '{e2e,src}/**/*.{js,ts,mjs,mts}'"
