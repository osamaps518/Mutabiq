import os

import pytest


def test_postgres_major_matches_expected(postgres_connection):
    expected = os.environ.get("MUTABIQ_TEST_PG_MAJOR")
    if not expected:
        pytest.skip("MUTABIQ_TEST_PG_MAJOR is not set")

    actual = postgres_connection.info.server_version // 10000
    assert actual == int(expected)
