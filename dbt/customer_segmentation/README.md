## Customer Segmentation dbt Project

This dbt project transforms the KPIM banking dataset in SQL Server database
`kpimbank`, schema `dbo`, into customer-segmentation models for Power BI.

### Model layers

- **Bronze** reads each raw source through `source()` and exposes consistent
  English column names, normalized data types, and translated descriptive
  categories. Original source tables are not overwritten.
- **Silver** builds account, balance-as-of-date, product, tenure, and customer
  metrics from Bronze models.
- **Gold** creates the customer base, segmentation outputs, and cross-sell
  matrix for reporting. Existing Gold column names are retained where needed
  for compatibility with the Power BI report.

Models default to views in `dbt_project.yml`; models that need persisted
reporting outputs explicitly configure table materialization.

### Useful commands

Run these commands from this directory:

```shell
dbt parse
dbt compile --select path:models
dbt build
```

`dbt build` executes models and tests against the configured SQL Server
database. Confirm the target profile and database before running it.

See the [dbt documentation](https://docs.getdbt.com/docs/introduction) for
details on sources, models, materializations, and tests.
