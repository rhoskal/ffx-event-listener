<p align="center">
  <img alt="build status badge" src="https://badge.buildkite.com/0dd3611b72c9a1ce418262de97a3bd7f38122b25b8f93e385e.svg" />
</p>

---

Flatfile debugging prototype.

<img width="1728" alt="Dashboard" src="https://user-images.githubusercontent.com/9221098/235733269-cdf75fbd-88e8-433f-b7cb-33291d8f1e05.png">

## Setup (w/ Nix)

1. Configure env vars using `direnv allow`

## Setup (w/o Nix)

1. `pnpm add -g elm`

## Dev

1. Install deps via `make deps`
2. Run dev server via `make run`

## Run with

1. docker build . -t ffx-event-listener
2. docker run -p 443:443 ffx-event-listener
