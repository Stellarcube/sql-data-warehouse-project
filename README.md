# 🏗️ SQL Data Warehouse Project
Building a modern data warehouse with SQL server, including ETL processes, data modeling, and analytics.

## 📌 Project Overview
This project demonstrates the end-to-end development of a modern SQL-based data warehouse solution. It consolidates sales data from ERP and CRM systems to enable analytical reporting and informed decision-making. The architecture follows best practices in data engineering, modeling, and transformation using the Medallion architecture.

## 🎯 Goals

- 🧱 Design a scalable and modern data architecture.
- 🛠️ Implement robust ETL pipelines to clean, transform, and load data.
- 📊 Create an analytical data model optimized for reporting and insights.

---

## 🗂️ Project Structure

### 1. Data Sources

- **ERP System** – CSV format
- **CRM System** – CSV format

### 2. ETL Pipeline

#### 🔍 Extraction
- Methods: Pull & Push
- Types: Full & Incremental
- Techniques: File parsing, API calls, CDC, event-based streaming

#### 🔄 Transformation
- Data cleaning: deduplication, filtering, type casting, outlier detection
- Data enrichment & normalization
- Business logic implementation
- Derived columns

#### 📥 Load
- Processing: Batch
- Methods: Full load (Truncate & Insert), Upsert

---

## 🧱 Architecture

### 🏛️ Medallion Architecture

| Layer   | Purpose                        | Object Type | Load Method       | Audience               |
|---------|--------------------------------|-------------|-------------------|------------------------|
| Bronze  | Raw & unprocessed data         | Table       | Full (Truncate)   | Data Engineers         |
| Silver  | Cleaned & standardized data    | Table       | Full (Truncate)   | Analysts, Engineers    |
| Gold    | Business-ready data            | View        | N/A               | Analysts, Business     |

---

## 🧮 Data Modeling

- **Modeling Approach**: Star schema with flat tables
- **Scope**: Latest dataset only (no historization)
- **SCD Type**: SCD1 (overwrite)

---

## 🧰 Tools & Technologies

- SQL Server
- CSV (source files)
- ETL scripting (SQL-based)
- Views for reporting

---

## 📄 Documentation

- Clear documentation of schema, transformations, and business logic
- Designed for both technical and non-technical stakeholders

---

## 🧠 Design Principles

- **Separation of Concerns**: Each layer and component has a distinct responsibility
- **Naming Conventions**: Consistent and descriptive naming across tables, views, and scripts

---

## 📈 Future Enhancements

- Implement historization using SCD2
- Introduce incremental loading via CDC
- Extend to real-time streaming architecture

---

## 🤝 Contributing

Contributions are welcome! Please fork the repo and submit a pull request with your improvements or suggestions.

---

## 📬 Contact

For questions or collaboration inquiries, reach out via GitHub Issues or connect with the project lead.
