# SQL Data Warehouse Project

## 📌 Overview

This project demonstrates how to design and build a **modern SQL Data Warehouse** from scratch by applying industry best practices in **data architecture, engineering, and modeling**. It follows a structured approach to extract, transform, and load (ETL) data from multiple source systems into a consolidated analytical model for business reporting.

The implementation follows the **Medallion Architecture (Bronze, Silver, Gold layers)**, ensuring clean, well-documented, and analysis-ready data.

---

## 🎯 Project Goals

* **Data Architecture**: Design a modern data warehouse architecture.
* **Data Engineering**: Build ETL pipelines to clean, transform, and load data.
* **Data Modeling**: Create analytical data models (fact and dimension tables) for reporting.

---

## 📂 Repository Structure

```bash
sql-data-warehouse-project/
│
├── datasets/                           # Raw datasets (ERP and CRM CSV files)
│
├── docs/                               # Documentation and diagrams
│   ├── data_architecture.drawio.png    # Project architecture
│   ├── data_flow_diagram.drawio.png    # Data flow diagram
│   ├── data_model.drawio.png           # Data model (Star Schema)
│   ├── integration_model.drawio.png    # Table integration model
│   ├── data_catalog.md                 # Dataset descriptions and metadata
│   ├── naming-conventions.md           # Naming conventions for objects
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Raw data ingestion
│   ├── silver/                         # Data cleaning and standardization
│   ├── gold/                           # Business-ready models
│
├── tests/                              # Data validation and quality checks
│
├── LICENSE                             # License file
└── README.md                           # Project overview (this file)
```

---

## 🏗️ Architecture

The project follows the **Medallion Architecture**:

1. **Bronze Layer**

   * Stores raw, unprocessed data.
   * Objective: Traceability & debugging.
   * Load method: Full load (truncate & insert).

2. **Silver Layer**

   * Stores clean & standardized data.
   * Objective: Prepare data for analysis.
   * Includes data cleansing, normalization, derived columns, and enrichment.

3. **Gold Layer**

   * Stores business-ready, analytical data.
   * Objective: Reporting & dashboards.
   * Includes fact & dimension tables, business rules, and aggregations.

---

## 🔄 ETL Process

1. **Extract**

   * Sources: ERP and CRM CSV files.
   * Methods: File parsing, bulk inserts, API support (future-ready).
   * Types: Full and incremental loads.

2. **Transform**

   * Data cleaning: remove duplicates, fix missing values, standardize formats.
   * Data enrichment: add metadata columns (e.g., load timestamp, source system).
   * Apply business rules and derived fields.

3. **Load**

   * Bronze: Raw ingestion.
   * Silver: Data cleansing & Standardization
   * Gold: Business ready views (star schema).

---

## 📊 Data Modeling

* **Conceptual Model**: Big picture of entities and relationships.
* **Logical Model**: Defines attributes, keys, and relationships.
* **Physical Model**: SQL implementation with data types and constraints.

**Schema Options**:

* **Star Schema**: Central fact table linked to dimension tables.
* **Snowflake Schema**: Normalized dimension tables.

---

## ✅ Tests & Validation

* Record count checks (source vs warehouse).
* Schema validation.
* Data quality checks (duplicates, nulls, invalid values).
* Business rule validation.

---

## 📖 Documentation

All documentation is stored under the `docs/` folder:

* **Data Architecture**
* **Data Flow Diagram**
* **Data Model (Star Schema)**
* **Integration Model**
* **Data Catalog**
* **Naming Conventions**

---

## 🚀 Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/<Stellarcube>/sql-data-warehouse-project.git
   cd sql-data-warehouse-project
   ```
2. Load datasets from `datasets/` into the Bronze layer using scripts in `scripts/bronze/`.
3. Apply Silver layer transformations using `scripts/silver/`.
4. Build analytical models from `scripts/gold/`.
5. Run validation tests from `tests/`.

---

## 📜 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.
