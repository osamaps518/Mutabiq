import os

import psycopg
import pytest


@pytest.fixture
def postgres_connection():
    url = os.environ.get("MUTABIQ_TEST_DATABASE_URL")
    if not url:
        if os.environ.get("MUTABIQ_TEST_PG_MAJOR"):
            pytest.fail(
                "MUTABIQ_TEST_DATABASE_URL is required when a Postgres major is expected"
            )
        pytest.skip("MUTABIQ_TEST_DATABASE_URL is not set")

    with psycopg.connect(url) as connection:
        yield connection
