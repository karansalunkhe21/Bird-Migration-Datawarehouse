# Bird Migration Data Warehouse

> End-to-end data warehouse for analyzing bird migration patterns using Snowflake, dbt, and Power BI.

![Architecture](https://img.shields.io/badge/Snowflake-Data%20Warehouse-blue) ![dbt](https://img.shields.io/badge/dbt-Transform-orange) ![Power BI](https://img.shields.io/badge/Power%20BI-Visualize-yellow)

## Overview

A complete data warehouse solution that analyzes 10,000+ bird migration records to identify patterns, success factors, and optimal migration conditions.

**Key Results:**
- 85% average migration success rate
- 50+ species analyzed
- 200+ migration routes mapped
- 8 risk factors identified

## Tech Stack

- **Snowflake** - Cloud data warehouse
- **dbt** - Data transformations (21 models)
- **Power BI** - Interactive dashboards (5 dashboards, 20+ visuals)
- **Python** - Data loading scripts
- **SQL** - Data modeling and queries

## Architecture
```
Kaggle Dataset → Python → Snowflake (RAW) → dbt (Transform) → Analytics Tables → Power BI
```

**Data Model:** Star Schema
- 5 Dimension tables (bird, location, date, weather, tracking)
- 1 Fact table (migration events)
- 8 Analytics tables (pre-built reports)

## Project Structure
```
bird-migration-dw/
├── snowflake/          # Database setup scripts
├── dbt/
│   └── models/
│       ├── staging/    # Data cleaning (1 model)
│       ├── intermediate/ # Business logic (3 models)
│       └── marts/      # Final tables (14 models)
├── scripts/            # Python ETL scripts
├── powerbi/            # Dashboards and DAX measures
└── docs/               # Documentation
```


## Key Features

### Data Pipeline
- Automated ELT Process - Modern Extract-Load-Transform pattern
- Cloud-Native - Fully hosted on Snowflake
- Version Controlled - All transformations in Git
- Tested - 40+ automated data quality tests
- Documented - Auto-generated data lineage

### Analytics Capabilities
- Species Performance Analysis - Rank and compare 50+ species
- Seasonal Pattern Detection - Identify optimal migration timing
- Geographic Route Mapping - Visualize migration corridors
- Risk Factor Analysis - Quantify threats to migration success
- Weather Impact Assessment - Correlate conditions with outcomes
- Device Performance Tracking - Monitor GPS/RFID effectiveness

### Visualizations
- 5 Interactive Dashboards with 20+ visualizations
- Executive Overview - High-level KPIs and trends
- Species Deep Dive - Detailed species analytics
- Geographic Maps - Route and corridor visualization
- Risk Analysis - Threat identification and mitigation
- Temporal Patterns - Time-series analysis

## Architecture

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     DATA SOURCES                            │
│              Kaggle Bird Migration Dataset                  │
│                    (~10,000 records)                        │
└────────────────────────┬────────────────────────────────────┘
                         │ Python ETL Scripts
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  SNOWFLAKE CLOUD DW                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐     │
│  │   RAW    │  │ STAGING  │  │     ANALYTICS        │     │
│  │  Schema  │→ │  Schema  │→ │      Schema          │     │
│  │          │  │ (Views)  │  │ (Tables: Star Schema)│     │
│  └──────────┘  └──────────┘  └──────────────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │ dbt Transformations
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  DBT (Transform Layer)                      │
│  Staging → Intermediate → Marts (Core + Analytics)         │
│  • 10 + Models  • 20+ Tests  • Auto Documentation            │
└────────────────────────┬────────────────────────────────────┘
                         │ ODBC Connection
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              POWER BI (Visualization Layer)                 │
│  3 Dashboards • 12+ Visualizations • 20+ DAX Measures      │
└─────────────────────────────────────────────────────────────┘
```

## Data Model

### Star Schema Design

![Star Schema](Images/Star_Schema.png)

Our dimensional model follows the star schema pattern:
- **Fact Table:** fact_bird_migration (migration events)
- **Dimensions:** dim_bird, dim_location, dim_date, dim_weather, dim_tracking
### Data Flow
```
CSV Files → Python Upload → Snowflake RAW → dbt Staging → 
dbt Intermediate → dbt Marts (Star Schema) → dbt Analytics → 
Power BI Dashboards
```
