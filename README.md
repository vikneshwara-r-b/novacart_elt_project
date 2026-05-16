# NovaCart ELT Project

An end-to-end incremental ELT pipeline that ingests transactional data from an Azure SQL (MSSQL) database into Databricks using Lakehouse Federation, transforms it through a Bronze-Silver-Gold medallion architecture on Delta Lake, and produces analytics-ready Gold tables with SCD Type 2 history tracking.

## Architecture Overview

```
Azure SQL (MSSQL)                  Databricks (Unity Catalog)
+-----------------+                +----------------------------------------------+
| dbo.products    |  Lakehouse     | novacart_catalog                             |
| dbo.orders      | ------------> |   bronze_schema                              |
| dbo.payments    |  Federation    |     orders_raw, products_raw, payments_raw   |
+-----------------+   (Foreign     |     ingestion_control                        |
                       Catalog)    |   silver_schema                              |
                                   |     orders_transformed, products_transformed |
                                   |     payments_transformed                     |
                                   |     *_cleaned, *_quarantine                  |
                                   |     processing_control                       |
                                   |   gold_schema                               |
                                   |     orders_information (current state)       |
                                   |     orders_information_scd2 (SCD Type 2)    |
                                   |     category_performance (aggregation)       |
                                   |     processing_control                       |
                                   |     gold_snapshots_vol (Volume)              |
                                   +----------------------------------------------+
```

## Key Features

- **Lakehouse Federation**: Reads directly from Azure SQL via a Unity Catalog foreign catalog -- no data copying into staging files
- **Watermark-based incremental ingestion**: Bronze layer uses timestamp + primary key watermarks to load only new/changed rows
- **Medallion architecture**: Three-layer processing (Bronze -> Silver -> Gold) with each layer tracked by its own control table
- **Data quality and quarantine**: Silver layer validates business rules and routes bad rows to quarantine tables for manual review
- **Deduplication**: Latest-record-wins logic per business key at every layer using window functions
- **SCD Type 2 history**: Gold layer maintains a slowly changing dimension table (`orders_information_scd2`) that tracks historical changes to order attributes
- **Category-level aggregation**: Gold layer computes per-category business metrics (GMV, payment completion ratio, failure rate)
- **Gold snapshots**: Each run publishes latest and timestamped historical snapshots to a Databricks Volume for audit and rollback
- **Databricks Asset Bundles (DAB)**: Workflow and job definitions are version-controlled YAML deployed via `databricks bundle`
- **Reusable helper functions**: All watermark reads, control table upserts, and merge logic are centralized in `helper_functions.ipynb`

## Project Structure

```
novacart_elt_project/
├── README.md
├── prompt.md                          # Setup and run instructions
├── mssql_scripts/
│   ├── sql_tables_creation.sql        # DDL for products, orders, payments tables
│   ├── initial_load_for_messy_data.sql # Initial load with intentionally messy data
│   ├── incremental_load_1.sql         # First incremental batch (10 rows per table)
│   └── incremental_load_2.sql         # Second incremental batch (10 rows per table)
├── databricks/
│   ├── databricks.yml                 # Databricks Asset Bundle config
│   ├── resources/
│   │   └── novacart_ingest_and_transform_workflow.yml  # Workflow job definition
│   ├── notebooks/
│   │   ├── helper_functions.ipynb     # Shared helper functions (Bronze/Silver/Gold)
│   │   ├── mssql_to_databricks_federation_setup.ipynb  # Federation connection setup
│   │   ├── catalog_creation.ipynb     # Unity Catalog + schema creation
│   │   ├── control_table_setup.ipynb  # Control table DDLs for all layers
│   │   ├── bronze_work.ipynb          # Bronze incremental ingestion
│   │   ├── silver_work.ipynb          # Silver cleaning, validation, quarantine
│   │   └── gold_work.ipynb            # Gold joins, SCD2, aggregation, snapshots
│   ├── scratch/
│   │   └── exploration.ipynb          # Ad-hoc exploration notebook
│   ├── tests/
│   │   └── conftest.py                # Pytest config with Databricks Connect
│   └── fixtures/                      # Test fixtures (placeholder)
```

## Source Data Model (MSSQL)

Three tables in the `dbo` schema of an Azure SQL database:

| Table | PK | Rows (Initial) | Relationships |
|---|---|---|---|
| `products` | `product_id` | 120 | Referenced by `orders` |
| `orders` | `order_id` | 500 | FK to `products`, referenced by `payments` |
| `payments` | `payment_id` | 430 | FK to `orders` |

The initial load script intentionally introduces messy data to exercise the Silver cleaning logic:

| Issue | products | orders | payments |
|---|---|---|---|
| NULL values | `product_name` | `customer_id`, `order_status` | `payment_status` |
| Formatting characters | `$` / `,` in price | `$` / `,` / `N/A` in amount | `$` / `,` / `??` in amount |
| Inconsistent casing | `electronics` / `FITNESS` / `lifestyle` | `shipped` / `PLACED` | `failed` / `SUCCESS` |
| Typos | `ELECTRNICS` | - | - |
| Whitespace | Leading/trailing spaces | - | - |
| Zero / invalid values | `??` as price | `0.00` as amount | `0.00` as amount |

## Pipeline Layers

### Bronze (Ingestion)

**Notebook**: `bronze_work.ipynb`

Reads source tables via the foreign catalog and appends new rows to `*_raw` Delta tables.

- **Watermark strategy**: Composite watermark using `(timestamp_col, primary_key_col)` -- loads rows where the timestamp is strictly greater than the last watermark, OR the timestamp equals the watermark but the PK is greater
- **Audit columns added**: `bronze_ingested_at`, `bronze_run_id`, `bronze_source_table`
- **Control table**: `bronze_schema.ingestion_control` tracks per-table watermarks, row counts, and run status

### Silver (Cleaning + Validation)

**Notebook**: `silver_work.ipynb`

Processes each entity (orders, products, payments) independently:

1. **Incremental read**: Filters Bronze rows by `bronze_ingested_at` > last processed timestamp
2. **Cleaning**: Standardizes casing (`UPPER`), trims whitespace, strips `$` / `,` from amounts, casts to proper types using `try_cast`
3. **Deduplication**: Window function per business key, keeping the latest record
4. **Merge to `*_cleaned`**: MERGE (upsert) into the cleaned current-state table
5. **Validation**: Business rules flag rows with NULL keys, invalid amounts, missing statuses
6. **Split**: Good rows merge into `*_transformed`; bad rows append to `*_quarantine`
7. **Control table**: `silver_schema.processing_control` tracks the last Bronze run processed

### Gold (Business Logic + Aggregation)

**Notebook**: `gold_work.ipynb`

Produces analytics-ready tables at order grain and category grain:

1. **Incremental scope**: Identifies impacted `order_id` values from changed orders, products, or payments
2. **Join**: Orders + Products + Payments joined on foreign keys
3. **Derived columns**: `payment_completion_ratio`, `payment_state` (Unpaid / Paid / Partially_paid / Overpaid)
4. **Merge to `orders_information`**: Current-state Gold table (upsert on `order_id`)
5. **SCD Type 2**: `orders_information_scd2` expires old rows (`is_current = false`, `valid_to_ts` set) and inserts new versions when key attributes change
6. **Category aggregation**: `category_performance` table with `total_orders`, `gross_merchandise_value`, `total_paid_amount`, `avg_payment_completion_ratio`, `payment_failure_rate`
7. **Snapshot publishing**: Writes latest and timestamped historical Parquet snapshots to `gold_snapshots_vol`
8. **Control table**: `gold_schema.processing_control` tracks the last Silver run processed

## Workflow Orchestration

The Databricks workflow `novacart_ingest_and_transform_workflow` is defined in `databricks/resources/novacart_ingest_and_transform_workflow.yml` and executes three sequential tasks:

```
bronze-ingestion --> silver-transformation --> gold-transformation
```

Job-level parameters (shared across all tasks):
| Parameter | Default |
|---|---|
| `catalog_name` | `novacart_catalog` |
| `foreign_catalog_name` | `novacart_external_mssql_oltp_db` |
| `source_schema` | `dbo` |
| `bronze_schema` | `bronze_schema` |
| `silver_schema` | `silver_schema` |
| `gold_schema` | `gold_schema` |

Each task also receives a `job_run_id` (from `{{job.run_id}}`) used as the run ID for control table tracking.

## Prerequisites

- An **Azure SQL Database** (MSSQL) instance
- A **Databricks workspace** with Unity Catalog enabled
- Databricks CLI installed and authenticated
- Permissions to create catalogs, schemas, connections, and foreign catalogs in Unity Catalog

## Setup Instructions

### 1. Prepare the MSSQL Source Database

Execute the following scripts against your Azure SQL database:

```sql
-- Create the source tables (products, orders, payments)
-- File: mssql_scripts/sql_tables_creation.sql

-- Load initial data (120 products, 500 orders, 430 payments with messy data)
-- File: mssql_scripts/initial_load_for_messy_data.sql
```

### 2. Clone the Repository to Databricks Workspace

Clone this repository into your Databricks workspace so the notebooks are accessible.

### 3. Configure Lakehouse Federation

Run the **`mssql_to_databricks_federation_setup.ipynb`** notebook interactively. It will prompt for:

- MSSQL connection details (host, port, database, user, password)
- A connection name and foreign catalog name

This creates a Unity Catalog **Connection** and **Foreign Catalog** that allows Spark SQL to query MSSQL tables directly.

### 4. Create Unity Catalog and Schemas

Run the **`catalog_creation.ipynb`** notebook. It creates:

- `novacart_catalog` (or your chosen catalog name)
- `bronze_schema`, `silver_schema`, `gold_schema`

### 5. Create Control Tables

Run the **`control_table_setup.ipynb`** notebook. It creates the watermark/control tables in each schema:

- `bronze_schema.ingestion_control`
- `silver_schema.processing_control`
- `gold_schema.processing_control`

### 6. Validate and Deploy the Databricks Asset Bundle

From a terminal in the `databricks/` directory:

```bash
# Validate the bundle configuration
databricks bundle validate

# Deploy to the workspace
databricks bundle deploy
```

## Running the Pipeline

### Initial Data Load

Execute the `novacart_ingest_and_transform_workflow` Databricks workflow job. This processes all 1,050 source rows through Bronze -> Silver -> Gold.

### Incremental Load 1

```sql
-- Insert 10 new products, 10 new orders, 10 new payments
-- File: mssql_scripts/incremental_load_1.sql
```

Then re-run the `novacart_ingest_and_transform_workflow` job. Only the 30 new rows will be ingested and transformed.

### Incremental Load 2

```sql
-- Insert another 10 products, 10 orders, 10 payments
-- File: mssql_scripts/incremental_load_2.sql
```

Then re-run the workflow job again.

## Technologies

- **Azure SQL Database** -- OLTP source system
- **Databricks** -- Compute and orchestration platform
- **Unity Catalog** -- Data governance and catalog management
- **Lakehouse Federation** -- Cross-platform query without data movement
- **Delta Lake** -- ACID storage format for all Bronze/Silver/Gold tables
- **PySpark** -- Data transformation and processing
- **Databricks Asset Bundles** -- Infrastructure-as-code for workflow deployment