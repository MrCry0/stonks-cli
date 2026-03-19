# Project Overview

## Project Pitch

stonks-cli is a terminal-native investment portfolio tracker. It gives
investors a quick way to check holdings, live prices, and unrealized P&L
without opening a browser or a heavyweight app.

## Core Loop

1. User defines positions and cash in a YAML file (or via CLI commands).
2. `stonks show` prints a one-shot table with live prices to stdout.
3. `stonks dashboard` launches a live-refreshing TUI for continuous monitoring.
4. `stonks add/remove` commands mutate the portfolio file atomically.

## Target Platform

- Python 3.11+
- Any terminal emulator (Linux, macOS, Windows with modern terminal)
- Runs in Docker containers for headless/remote use

## Key Constraints

- **No API keys required** -- all market data comes from Yahoo Finance via
  yfinance.
- **Offline-tolerant** -- the `show` command degrades gracefully (shows `N/A`)
  when prices cannot be fetched.
- **Immutable domain models** -- `Portfolio`, `Position`, and `CashPosition`
  use frozen-style dataclasses; mutation returns new instances or modifies
  in-place through controlled methods.
- **No external database** -- all state lives in YAML files under
  `~/.config/stonks/`.
