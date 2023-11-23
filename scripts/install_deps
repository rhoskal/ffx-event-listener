#!/bin/bash

set -euo pipefail

echo "--- Install dependencies"

nix-shell --run "pnpm install"

nix-shell --run "elm make --output=/dev/null src/Main.elm"
nix-shell --run "cd review && elm make src/ReviewConfig.elm"