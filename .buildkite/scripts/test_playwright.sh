#!/bin/bash

set -euo pipefail

# Caching browser binaries is not recommended, since the amount of time it takes to restore 
# the cache is comparable to the time it takes to download the binaries. Especially under 
# Linux, operating system dependencies need to be installed, which are not cacheable.
# https://playwright.dev/docs/ci#caching-browsers
nix-shell --run "pnpm playwright install --with-deps"

nix-shell --run "pnpm playwright test"
# upload artifact?
# buildkite-agent artifact upload playwright-report/index.html