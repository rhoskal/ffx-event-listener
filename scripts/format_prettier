#!/bin/bash

set -euo pipefail

nix-shell --run "pnpm prettier --check '{e2e,src}/**/*.{css,json,js,ts,mjs,mts}'"
