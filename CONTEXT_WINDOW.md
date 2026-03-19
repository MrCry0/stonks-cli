# Context Window -- Decision Log

## Revision History

### 2026-03-19 -- Add `show` command

**What:** New `stonks show` CLI command that fetches live prices once and
prints a formatted portfolio table to stdout.

**Why:** The only way to view portfolio state was the interactive TUI
dashboard, which requires a terminal that supports Textual and runs
continuously. Users needed a quick, scriptable, one-shot way to inspect
their portfolio (e.g. in cron jobs, CI pipelines, or piped to other tools).

**Decisions:**
- Reused the same PriceFetcher cascade (extended → batch → single fallback)
  from `app.py` rather than creating a simplified path, to ensure price
  quality parity with the TUI.
- Extracted `_fetch_portfolio_data()` and `_format_show_table()` as module-level
  helpers in `main.py` to keep them testable without mocking the full Click
  context.
- Plain-text formatting with f-string alignment rather than pulling in `rich`
  or `tabulate` as a dependency, since the output is meant to be
  pipe-friendly.
- Graceful degradation: `N/A` for missing prices/forex rather than failing
  with an error, matching the TUI behaviour.

## Integration Notes

- The `_fetch_portfolio_data` function mirrors the logic in
  `PortfolioApp._refresh_prices` (app.py). If the fetcher cascade changes
  in one place, update the other.
- Tests mock `_fetch_portfolio_data` at the function boundary so no yfinance
  network calls occur. Unit tests for `_format_show_table` use model
  instances directly.

## Resolved Logic Conflicts

*(none yet)*
