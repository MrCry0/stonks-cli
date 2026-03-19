Always keep the following files actual. Update them on any changes in the
project.

Project Blueprint (README.md)
This is the entry point. It defines the high-level vision, core mechanics, and
the «Definition of Done.»
Purpose: To give the AI context on the overall goal.
Key Sections: What it does, Build, Install, Usage. Documentation, Tests,
License.

Project Blueprint (OVERVIEW.md)
It defines the high-level vision, core mechanics, and the «Definition of Done.»
Purpose: To give the AI context on the overall goal.
Key Sections: Project Pitch, Core Loop, Target Platform, and Key Constraints.

System Architecture Guide (ARCHITECTURE.md)
This defines how your Unity code is organized. Since Unity can easily become
«spaghetti code,» this document prevents the AI from suggesting conflicting
patterns.
Purpose: To enforce coding standards and structural patterns.
Key Sections: Dependency Management, Communication Patterns (Events vs.
Interfaces), and Folder Structure.

The Technical Specs (SPECS.md)
A living document where you detail specific features before they are coded.
Purpose: To serve as the prompt-basis for generating actual rust code.
Key Sections: Data Models, State Machine logic, and API signatures.

The «Memory» Log (CONTEXT_WINDOW.md)
In a long-term project, AI «forgets» why certain decisions were made.
Purpose: To track major architectural shifts or «known bugs» that shouldn’t be
reintroduced.
Key Sections: Revision History, Integration Notes, and Resolved Logic Conflicts.

The README.md should include relative references to all other .md files from
this request.

Read further global instructions from the file COMMIT_INSTRUCTIONS.md.

Reuse the following information about the project to reduce your scope of work.

## Project

stonks-cli is a Python CLI investment portfolio tracker with a Textual TUI dashboard. It tracks stock holdings with live market prices via yfinance, calculates unrealized P&L, and supports multiple currencies and global exchanges.

## Commands

Both Poetry and uv are supported. Use whichever is installed.

### Poetry

```bash
poetry install
poetry run bash ./scripts/ci-check
poetry run ruff format --check .          # Format check
poetry run ruff check .                   # Lint
poetry run mypy                           # Type check
poetry run pytest -q --cov --cov-report=term-missing  # Tests with coverage
poetry run ruff format .                  # Auto-fix format
poetry run ruff check . --fix             # Auto-fix lint
poetry run pytest tests/test_models.py::TestPosition::test_market_value -v  # Single test
```

### uv

```bash
uv sync --extra dev
uv run bash ./scripts/ci-check
uv run ruff format --check .
uv run ruff check .
uv run mypy
uv run pytest -q --cov --cov-report=term-missing
uv run ruff format .
uv run ruff check . --fix
uv run pytest tests/test_models.py::TestPosition::test_market_value -v
```

## Architecture

Entry point: `stonks_cli.main:main` (Click CLI group)

```
main.py (Click CLI: add, remove, add-cash, remove-cash, show, dashboard, list)
  ├── storage.py  →  PortfolioStore: load/save YAML portfolio files
  │                   Uses models: Portfolio, Position, CashPosition
  ├── fetcher.py  →  PriceFetcher (used directly by show command)
  └── app.py      →  PortfolioApp (Textual TUI, live-refreshing DataTable)
      └── fetcher.py  →  PriceFetcher: yfinance prices, forex rates,
                          session detection (pre/regular/post/closed),
                          ~65 exchange definitions with timezone/hours
```

**models.py**: Frozen dataclasses with `__post_init__` validation. `Portfolio` is immutable — mutation methods return new instances.

**fetcher.py**: Largest module (~595 lines). Contains exchange metadata (timezone, trading hours), batch price fetching, extended-hours support, and forex rate lookups. Uses `exchange-calendars` for holiday awareness.

**app.py**: Textual app with background worker that calls PriceFetcher on interval. Renders portfolio as a DataTable with session labels (PRE/CLS/AH).

## Conventions

- **Tooling**: Poetry 2.0+ or uv, Ruff (format + lint, rules E/F/I), mypy (strict_optional), pytest with asyncio
- **Commits**: Conventional Commits with `Signed-off-by` trailer (`git commit -s -m "feat(scope): description"`)
- **Testing**: All yfinance/network calls are mocked. TUI tests use autouse `no_price_refresh` fixture from `conftest.py`. Branch coverage enabled.
- **Portfolio YAML schema**: positions (symbol, quantity, avg_cost, currency) 
and cash (currency, amount) under a `portfolio` key with `name` and 
`base_currency`
