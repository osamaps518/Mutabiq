# Catalog sources

The open test catalog is published as CC0. Every row needs an Arabic name and a short source name in its `source` column. Use only our own text or data published as CC0 or public domain. Review that a source's name describes the same food before adding a row.

## Sources

| Source | Licence | What we take | `source` |
|---|---|---|---|
| Names written by Mutabiq contributors | Our own text, released as CC0 with the catalog ([decision 10](../docs/decisions.md#10-licences-mit-for-code-cc0-for-data)) | Arabic and English food names, including Arabic names we write for USDA foods | `own` |
| [USDA FoodData Central](https://fdc.nal.usda.gov/) | [CC0 1.0 / public domain](https://fdc.nal.usda.gov/api-guide#bkmk-6) | English food descriptions and FDC IDs; we write the Arabic name for each such row | `usda` |

USDA's [published field descriptions](https://fdc.nal.usda.gov/docs/Download_Field_Descriptions_Oct2020.pdf) describe a food description field, but no Arabic name or language-specific name field. It is not a source of Arabic translations for this catalog. A USDA row's Arabic name is our own text. The `source` value names the source of the row's external food record; our own Arabic wording on a USDA row does not change `usda` to `own`.

## Checked and rejected

| Source | Licence | Reason |
|---|---|---|
| Wiktionary | [CC BY-SA 4.0 and GFDL](https://en.wiktionary.org/wiki/Wiktionary:Copyrights) | Attribution and share-alike conditions conflict with the CC0 catalog. |
| Open Food Facts | [ODbL for its database; DbCL for individual contents](https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/tutorials/license-be-on-the-legal-side/) | The database has attribution and share-alike conditions; it is not a condition-free catalog source. |
| FAO AGROVOC Arabic terms | [CC BY 4.0](https://www.fao.org/agrovoc/ar/%D8%A7%D9%84%D8%B5%D9%8A%D8%A7%D9%86%D8%A9) | Its Arabic terms require attribution. |
| Wikidata | [CC0 for structured data](https://www.wikidata.org/wiki/Wikidata:Licensing) | The licence fits, but decision 11 limits the catalog to our own names and USDA data. Revisit if decision 11 changes. |
