"""The published catalog remains usable as a stable search test bed."""

import csv
from pathlib import Path

CATALOG = Path(__file__).resolve().parents[1] / "catalog" / "foods.csv"
REQUIRED_FIELDS = ("id", "arabic_name", "english_name", "source")
ALLOWED_SOURCES = {"own", "usda"}


def test_catalog_rows_have_stable_ids_names_and_allowed_sources():
    """Reject catalog edits that would break references or provenance."""
    with CATALOG.open(encoding="utf-8", newline="") as file:
        reader = csv.DictReader(file)
        assert reader.fieldnames == list(REQUIRED_FIELDS)
        rows = list(reader)

    assert rows
    ids = [row["id"] for row in rows]
    assert len(ids) == len(set(ids)), "catalog IDs must be unique"
    for row in rows:
        assert all(row[field] and row[field].strip() for field in REQUIRED_FIELDS), row
        assert row["source"] in ALLOWED_SOURCES, row
