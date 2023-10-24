#!/bin/bash

set -euo pipefail

nix-shell --run "pnpm netlify deploy --prod"