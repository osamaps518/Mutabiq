# Catalog sources

The open test catalog is published as CC0, so every row must be our own text or come from data published as CC0 or public domain. Each row has an Arabic name and, in its `source` column, the short name of its source. Before adding a row from an outside source, check that the source record is the same food as the row's names.

## Sources

| Source | Licence | What we take | `source` |
|---|---|---|---|
| Names written by Mutabiq contributors | Our own text, released as CC0 with the catalog ([decision 10](../docs/decisions.md#10-licences-mit-for-code-cc0-for-data)) | Arabic and English food names, including Arabic names we write for USDA foods | `own` |
| [USDA FoodData Central](https://fdc.nal.usda.gov/) | [CC0 1.0 / public domain](https://fdc.nal.usda.gov/api-guide#bkmk-6) | English food descriptions and FDC IDs; we write the Arabic name for each such row | `usda` |

USDA has no Arabic names: its [field descriptions](https://fdc.nal.usda.gov/docs/Download_Field_Descriptions_Oct2020.pdf) list a food description and no field for Arabic or any other language. We write the Arabic name for each USDA row, and the row's `source` stays `usda`.

## Checked and rejected

| Source | Licence | Reason |
|---|---|---|
| Wiktionary | [CC BY-SA 4.0 and GFDL](https://en.wiktionary.org/wiki/Wiktionary:Copyrights) | Attribution and share-alike conditions conflict with the CC0 catalog. |
| Open Food Facts | [ODbL for its database; DbCL for individual contents](https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/tutorials/license-be-on-the-legal-side/) | Attribution and share-alike conditions on the database. |
| FAO AGROVOC Arabic terms | [CC BY 4.0](https://www.fao.org/agrovoc/ar/%D8%A7%D9%84%D8%B5%D9%8A%D8%A7%D9%86%D8%A9) | Its Arabic terms require attribution. |
| Wikidata | [CC0 for structured data](https://www.wikidata.org/wiki/Wikidata:Licensing) | The licence fits, but decision 11 limits the catalog to our own names and USDA data. Revisit if decision 11 changes. |
