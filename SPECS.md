# Technical Specs

## Data Models

### Position
| Field      | Type   | Constraints              |
|------------|--------|--------------------------|
| symbol     | str    | non-empty, uppercased    |
| quantity   | int    | > 0                      |
| avg_cost   | float  | > 0                      |
| currency   | str    | ISO 4217, default "USD"  |

Methods: `market_value(last_price)`, `unrealized_pnl(last_price)`.

### CashPosition
| Field    | Type   | Constraints              |
|----------|--------|--------------------------|
| currency | str    | non-empty, uppercased    |
| amount   | float  | > 0                      |

### Portfolio
| Field         | Type              | Constraints                    |
|---------------|-------------------|--------------------------------|
| positions     | list[Position]    | no duplicate symbols           |
| cash          | list[CashPosition]| no duplicate currencies        |
| base_currency | str               | ISO 4217, default "USD"        |
| name          | str               | optional label                 |

Mutation methods: `add_position`, `remove_position`, `add_cash`, `remove_cash`.
Lookup methods: `get_position`, `get_cash`.

## CLI Commands

| Command       | Arguments / Options           | Description                          |
|---------------|-------------------------------|--------------------------------------|
| `add`         | SYMBOL QUANTITY PRICE         | Add shares to portfolio              |
| `remove`      | SYMBOL QUANTITY               | Remove shares from portfolio         |
| `add-cash`    | CURRENCY AMOUNT               | Add cash holding                     |
| `remove-cash` | CURRENCY AMOUNT               | Remove cash holding                  |
| `show`        | *(none)*                      | One-shot stdout table with live data |
| `dashboard`   | `--refresh` (float, default 5)| Live-refreshing TUI                  |
| `list`        | *(none)*                      | List portfolio files in config dir   |

Global option: `-p` / `--portfolio` (repeatable) selects portfolio files.

## show Command

### Behaviour
1. Load all portfolios from `-p` stores.
2. Call `_fetch_portfolio_data()` which runs the PriceFetcher cascade:
   - `fetch_extended_prices` (1-min bars, prepost=True)
   - `fetch_prices` fallback (daily bars for missing symbols)
   - `fetch_price_single` fallback (individual lookups)
   - `fetch_exchange_names` (concurrent exchange code lookups)
   - `fetch_forex_rates` (one call per unique base currency)
3. Format each portfolio as a plain-text table via `_format_show_table()`.
4. Print to stdout and exit.

### Output columns
Instrument | Exchange | Qty | Avg Cost | Last Price | Mkt Value | Unrealized P&L

Session badges: PRE, AH, CLS appended to Last Price.
Cash rows show `--` for Unrealized P&L.
Total line at the bottom sums market values in the base currency.

### Graceful degradation
- Missing price → `N/A` for Last Price, Mkt Value, Unrealized P&L.
- Missing forex rate → Total shows `N/A`.
- Empty portfolio → prints "Portfolio is empty." and exits.

## PriceFetcher API

| Method                | Returns                           |
|-----------------------|-----------------------------------|
| `fetch_prices`        | `dict[str, float]`                |
| `fetch_price_single`  | `float \| None`                   |
| `fetch_extended_prices` | `dict[str, tuple[float, str]]`  |
| `current_session`     | `str` (pre/regular/post/closed)   |
| `fetch_exchange_names` | `dict[str, str]`                 |
| `fetch_forex_rates`   | `dict[str, float]`                |
