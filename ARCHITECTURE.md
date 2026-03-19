# System Architecture

## Module Map

```
stonks_cli/
  __init__.py        Package version
  main.py            Click CLI group: add, remove, add-cash, remove-cash,
                     show, dashboard, list
                     Helper functions: _fetch_portfolio_data,
                     _format_show_table
  storage.py         PortfolioStore: load/save YAML portfolio files
  models.py          Domain models: Portfolio, Position, CashPosition
  app.py             PortfolioApp: Textual TUI with live-refreshing DataTable
  fetcher.py         PriceFetcher: yfinance prices, forex rates,
                     session detection, ~65 exchange definitions
  data/              Bundled sample portfolio YAML
```

## Dependency Flow

```
main.py
  ├── storage.py  →  models.py
  ├── fetcher.py               (used by show command directly)
  └── app.py      →  fetcher.py, models.py
```

The `show` command calls `_fetch_portfolio_data()` which instantiates a
`PriceFetcher` and runs the same three-tier price cascade as the TUI
(extended → batch → single fallback), then formats a plain-text table via
`_format_show_table()`.

## Communication Patterns

- **CLI → Storage**: synchronous load/save via `PortfolioStore`.
- **CLI → Fetcher**: synchronous calls in `show`; background worker thread
  in `dashboard`.
- **TUI refresh**: `_refresh_prices` runs in a Textual `@work(thread=True)`
  worker, pushes results to the main thread via `call_from_thread`.

## Folder Structure

```
stonks-cli/
  src/stonks_cli/    Source package
  tests/             Pytest test suite
  scripts/           CI helper scripts
  config/            Sample portfolio files
  docs/              Documentation assets
```

## Coding Standards

- **Formatter/Linter**: Ruff (rules E/F/I)
- **Type checker**: mypy with strict_optional
- **Tests**: pytest + pytest-asyncio; all network calls mocked
- **Commits**: Conventional Commits with Signed-off-by trailer
