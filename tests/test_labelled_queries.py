"""The published labels remain usable for search-quality measurements."""

import csv
from pathlib import Path

import pytest

CATALOG = Path(__file__).resolve().parents[1] / "catalog"
FIELDS = ["query", "relevant_ids", "wrong_ids", "kind"]
KINDS = {"spelling", "dialect", "short", "english"}


def read_rows(path):
    """Read one published CSV while checking its documented columns."""
    with path.open(encoding="utf-8", newline="") as file:
        reader = csv.DictReader(file)
        assert reader.fieldnames == FIELDS
        return list(reader)


def validate_labels(tuning, grading, catalog_ids):
    """Check the labels that could silently corrupt evaluation results."""
    seen_queries = set()
    for rows in (tuning, grading):
        assert rows
        assert {row["kind"] for row in rows} == KINDS
        for row in rows:
            query = row["query"].strip()
            assert query
            assert query not in seen_queries, query
            seen_queries.add(query)

            relevant = row["relevant_ids"].split("|")
            wrong = row["wrong_ids"].split("|") if row["wrong_ids"] else []
            assert all(relevant)
            assert all(wrong)
            assert len(relevant) == len(set(relevant))
            assert len(wrong) == len(set(wrong))
            assert set(relevant + wrong) <= catalog_ids, query
            assert not set(relevant) & set(wrong), query


def test_published_queries_reference_catalog_without_conflicting_labels():
    """Every public query has a real target and usable comparison labels."""
    with (CATALOG / "foods.csv").open(encoding="utf-8", newline="") as file:
        catalog_ids = {row["id"] for row in csv.DictReader(file)}

    validate_labels(
        read_rows(CATALOG / "queries-tuning.csv"),
        read_rows(CATALOG / "queries-grading.csv"),
        catalog_ids,
    )


@pytest.mark.parametrize(
    "change",
    [
        ("relevant_ids", "missing-food"),
        ("wrong_ids", "missing-food"),
        ("wrong_ids", "cherry"),
        ("relevant_ids", ""),
        ("query", "same query"),
    ],
)
def test_invalid_labels_are_rejected(change):
    """Missing IDs, conflicting IDs and unusable queries fail validation."""
    field, value = change
    tuning = [
        {
            "query": f"tuning {kind}",
            "relevant_ids": "rice",
            "wrong_ids": "cherry",
            "kind": kind,
        }
        for kind in sorted(KINDS)
    ]
    grading = [
        {
            "query": f"grading {kind}",
            "relevant_ids": "cherry",
            "wrong_ids": "",
            "kind": kind,
        }
        for kind in sorted(KINDS)
    ]
    validate_labels(tuning, grading, {"rice", "cherry"})
    if field == "query":
        value = tuning[0]["query"]
    grading[0][field] = value
    with pytest.raises(AssertionError):
        validate_labels(tuning, grading, {"rice", "cherry"})
