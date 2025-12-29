# Food Delivery Delay & Operations Analysis (SQL | Python | Power BI)

## Project Overview
This project is an end-to-end operations analytics case study focused on understanding delivery delays in a food delivery ecosystem.  
The analysis covers order behavior, delivery partner performance, locality trends, and delay drivers using **synthetically generated data**, SQL analysis, Python EDA, and Power BI dashboards.

---

## Dataset Creation (Synthetic Data)
Since real-world food delivery data is not publicly available, the dataset was **synthetically generated using Python** to closely simulate real operational scenarios.

### Key characteristics of the synthetic dataset:
- City-level food delivery operations (Mumbai)
- Orders with timestamps, distance, delivery time, and delay flags
- Delivery partner attributes (experience, vehicle type)
- Restaurant and locality-level mapping
- Peak hours, weekends, and weather conditions

Synthetic data was designed to maintain:
- Realistic distributions
- Logical correlations (distance vs delay, peak hours vs congestion)
- Operational constraints seen in food-tech companies

---

## Python (Data Generation & EDA)
Python was used for:
- Synthetic dataset creation
- Exploratory Data Analysis (EDA)
- Outlier detection and correlation analysis

### Python tasks included:
- Data simulation using pandas & numpy
- Correlation heatmaps
- Delay distribution analysis
- Outlier detection using boxplots

Files:
- `dataset_creation.ipynb`
- `eda_analysis.ipynb`

---

##  SQL Analysis
SQL was used to perform structured analysis and create analytical views for reporting.

### SQL work includes:
- Data cleaning & transformation
- Delay percentage calculations
- Peak hour and weekday analysis
- Locality-wise and partner-wise performance
- Creation of reusable SQL views

File:
- `food_analysis.sql`

---

## Power BI Dashboard
An interactive Power BI dashboard was created to visualize operational KPIs and insights.

### Dashboard features:
- Total Orders vs Delayed Orders
- Delay Percentage KPI
- Peak vs Non-Peak Delay Analysis
- Locality-wise delay hotspots
- Delivery partner performance

File:
- `delivery_delay_dashboard.pbix`

---

## Key Insights
- Delay rates are significantly higher during peak hours
- Certain localities consistently show higher delays
- Distance and weather contribute moderately to delays
- Delivery partner experience impacts on-time performance

---

## Business Use Case
This project simulates real-world **operations analytics** use cases relevant to:
- BigBasket
- Swiggy
- Zomato
- Blinkit
- E-commerce & last-mile delivery companies

---

## Tools & Technologies
- Python (Pandas, NumPy, Matplotlib, Seaborn)
- SQL
- Power BI
- Excel
