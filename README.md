# Mutabiq

Arabic search normalization, aliases and an evaluation harness

## Checks

Run these before a PR:

```bash
uv run ruff check
uv run ruff format --check
uv run pytest
```

To run database tests locally, start Postgres 15–18. For example:

```bash
docker run -d --name mutabiq-db -p 5433:5432 -e POSTGRES_PASSWORD=postgres postgres:18
```

Then run the tests with its connection URL:

```bash
MUTABIQ_TEST_DATABASE_URL=postgresql://postgres:postgres@localhost:5433/postgres uv run pytest
```
