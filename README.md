The **Global Product Pricing & Inventory Intelligence System** is an end-to-end ETL and data analytics project that integrates product information from CSV files with currency exchange rates retrieved through an external REST API.

The project uses **NPR (Nepalese Rupee) as the base currency** and converts product prices into **EUR (Euro) and CAD (Canadian Dollar)** using API-provided exchange rates.

The transformed data is loaded into a MySQL database, where SQL queries can be used to analyze product pricing, unit costs, indicative profit margins, inventory replenishment requirements, and supplier lead times.

The project demonstrates how ETL automation, API integration, database management, and SQL analytics can work together to support business decision-making.

## Project Objectives

- Build an end-to-end ETL workflow using Pentaho Data Integration.
- Extract product information from CSV files.
- Retrieve currency exchange rates through a REST API.
- Use NPR as the base currency for international price conversion.
- Calculate product prices in EUR and CAD.
- Store the transformed dataset in MySQL.
- Perform SQL-based product pricing and inventory analysis.
- Identify products that may require inventory replenishment review.
- Explore the relationship between product margins, shelf life, and supplier lead times.

## Technologies Used

| Technology | Purpose |
|---|---|
| Pentaho Data Integration (Spoon) | ETL workflow development and data transformation |
| MySQL | Relational database storage and management |
| REST API | Retrieving currency exchange rates |
| CSV | Source product dataset |
| SQL | Data querying and business analysis |

## Data Sources

### 1. Product Dataset

The product information is extracted from a CSV file containing product and inventory-related attributes.

Important columns include:

| Column | Description |
|---|---|
| product_id | Unique product identifier |
| product_name | Name of the product |
| category | Product category |
| brand | Product brand |
| base_price_npr | Original product price in NPR |
| unit_cost_npr | Cost of one product unit in NPR |
| shelf_life_days | Number of days the product can be stored |
| supplier_lead_time_days | Estimated supplier delivery time |
| reorder_point | Inventory level at which replenishment should be considered |
| reorder_qty | Suggested quantity to reorder |
| base_daily_demand_units | Estimated daily product demand |

### 2. Currency Exchange Rate API

An external REST API provides exchange rate information used to convert product prices from NPR into EUR and CAD.

The exchange rate data includes:

- Base currency: NPR
- Target currency: EUR
- Target currency: CAD
- Corresponding exchange rates

## ETL Process

The project uses Pentaho Data Integration (Spoon) to perform the extraction, transformation, and loading process.

### 1. Extract

- Read product information from the CSV source file.
- Connect to an external REST API to retrieve currency exchange rates.
- Extract the required exchange rate values for EUR and CAD.
- Prepare the extracted data for transformation.

### 2. Transform

- Process the product information and exchange rate data.
- Use NPR as the base currency.
- Calculate converted product prices in EUR and CAD.

### 3. Load

- Load the transformed product dataset into MySQL.
- Store the original product information and converted currency values.
- Store the exchange rate information used for conversion.
- Include a database load timestamp using the `data_pulled_date` column.

## Currency Conversion Logic

```text
Price_EUR = base_price_npr * NPR_to_EUR_rate

Price_CAD = base_price_npr * NPR_to_CAD_rate

Unit Margin = base_price_npr - unit_cost_npr

Unit Margin Percentage =
((base_price_npr - unit_cost_npr) / base_price_npr) * 100
```
