# KPIM Customer Segmentation Dashboard 🏦📊

> **Disclaimer:** Data used in this project is simulated for demonstration purposes and does not represent real customer or account information.

A comprehensive Power BI solution for banking customer segmentation, combining SQL-based data preparation with an interactive 4-page reporting experience. This dashboard provides a 360-degree view of the customer portfolio, enabling stakeholders to monitor risk, evaluate individual profiles, and drive actionable customer care solutions.

## Business Objective
In the retail and corporate banking sector, understanding customer behavior and lifecycle stages is critical. This dashboard addresses key business needs by:
* **Holistic Portfolio Management:** Providing a macro-view of customer distribution across 19 lifecycle and risk segments.
* **Proactive Risk Mitigation:** Tracking at-risk accounts, monitoring debt groups, and forecasting NPL (Non-Performing Loan) provisioning needs.
* **Targeted Customer Care:** Empowering Relationship Managers (RMs) with data-driven triggers for Cross-Selling, Retention, and Activation.
* 
## Tech Stack & Data Architecture
* **Data Transformation :** **dbt (Data Build Tool)** & **SQL**. Transitioned from a monolithic SQL script to a modular Medallion architecture (Bronze, Silver, and Gold layers) to standardize source data, process complex customer segmentation logic, and improve code maintainability and data lineage tracking.
* **Version Control:** **Git & GitHub** for tracking dbt models and ensuring robust version control for the data transformation pipeline.
* **Business Intelligence:** **Power BI** (Interactive report design, UI/UX optimization).
* **Data Modeling:** Optimized Star Schema architecture connecting Fact tables with Dimension tables (Customers, Branches, Products). 
* **Advanced Analytics:** **DAX** (Custom measures for risk scoring, trend ratios, cross-sell matrix logic, and dynamic maturity tracking).
---
## Project Structure
```
├───dbt_project.yml           
├───models
│   │   schema.yml
│   │   sources.yml
│   │   
│   ├───bronze
│   │       bronze_customer.sql
│   │       bronze_customer_segment.sql
│   │       bronze_department.sql
│   │       bronze_deposit_account.sql
│   │       bronze_deposit_balance.sql
│   │       bronze_loan_account.sql
│   │       bronze_loan_balance.sql
│   │       bronze_product.sql
│   │       bronze_region.sql
│   │       bronze_staff.sql
│   │       
│   ├───gold
│   │       gold_cross_sell_matrix.sql
│   │       gold_customer_360.sql
│   │       gold_customer_base.sql
│   │       gold_customer_final_segmentation.sql
│   │       gold_customer_sub_segments.sql
│   │       
│   └───silver
│           silver_account_metrics.sql
│           silver_as_of_date.sql
│           silver_customer.sql
│           silver_deposit_metrics.sql
│           silver_fact_du_no_asof.sql
│           silver_fact_tien_gui_asof.sql
│           silver_loan_metrics.sql
│           silver_product_metrics.sql
│           silver_tenure_metrics.sql
├── macros/
│   └── translate_term_type.sql
├── seeds/
│   └── product_mapping.csv
└── analysis/
    └── risk_score_eda.ipynb    
```
## 📊 Dashboard Overview & Key Insights

### 0. dbt docs
<img width="1843" height="663" alt="image" src="https://github.com/user-attachments/assets/f625efeb-0ad2-465d-9d02-4d29ec0bb5ee" />

### 1. Data Model 
<img width="1315" height="787" alt="image" src="https://github.com/user-attachments/assets/763754bb-7c4d-45da-aa06-6d453bd1fd07" />

### 2. Cover Page
Landing page introducing the four report sections with a consistent, professional navy/gold theme. Features clickable navigation cards for a seamless user experience.

<img width="1440" height="808" alt="Ảnh chụp màn hình 2026-10-13 115412" src="https://github.com/user-attachments/assets/01706b51-b081-44dd-871f-ea70a1326635" />

### 3. Customer 360
Portfolio-level overview of the entire customer base tracking total customers, balances, and macro-trends.
* **Key Features:** Total customers and balance KPIs, Final Customer Segment Distribution (19 segments), Dual-line trend chart for Loan vs. Deposit, and Product/Activity donut charts.
* **💡 Snapshot Insight:** The portfolio shows a significant concentration of **Dormant Customers (24.01%)** and customers with **No Product (67.01%)**. Additionally, the macro trend highlights a shift from Q1-2025, where total deposits surged and stabilized above loan balances.

<img width="1439" height="807" alt="image" src="https://github.com/user-attachments/assets/d63435da-fdf7-4057-a0df-96cf8bdc6424" />


### 4. Customer Individual Profile
A full 360° view of a single selected customer (searchable by CIF & Name) designed for Relationship Managers.
* **Key Features:** Customer demographics, RM details, balance/trend gauges, and an account-level breakdown table.
* **💡 Snapshot Insight:** The dynamic Radar Chart and Trend Ratios quickly profile users. For example, CIF 3000001721 is immediately identifiable as a high-value "Deposit-Leaning Customer" (Diamond Plus) with a healthy Deposit Trend Ratio (1.17), providing the RM with clear context before engagement.

<img width="1441" height="810" alt="image" src="https://github.com/user-attachments/assets/bf4bc51a-7882-4e00-a9a3-afcc7494eb31" />

### 5. Customer Risk Management
Monitoring and analysis of at-risk customers to support credit risk departments.
* **Key Features:** At-risk KPIs (requiring NPL provision, with collateral), Worst Debt Group Trend, and a Box-and-Whisker plot for Risk Score Range by Segment.
* **💡 Snapshot Insight:** A massive **73.03%** of at-risk customers fall into the "Potential Risk - No Product Relationship" bucket. The Box-and-Whisker plot clearly flags corporate segments, particularly **"KHDN LỚN" (highlighted in red)**, as having a significantly skewed risk distribution compared to retail segments.
* 
<img width="1441" height="806" alt="image" src="https://github.com/user-attachments/assets/f35397cc-cc84-4a61-bbd3-4d41b9e1922f" />

<img width="1299" height="729" alt="image" src="https://github.com/user-attachments/assets/b79702ce-24d9-488c-b790-f10518c0bb4a" />


### 6. Customer Care Solutions
An actionable, three-tab section supporting CRM activities with a persistent left-hand KPI panel.

* **Tab 1: Customer Expansion**
  * **Key Features:** Interactive Cross-Sell Matrix mapping row-product vs. column-product ownership.
  * **💡 Snapshot Insight:** The matrix reveals highly siloed product ownership. Cross-selling success is currently concentrated in specific niches (e.g., 100% overlap between mixed real estate loans and corporate real estate projects), leaving vast white space for broader retail expansion campaigns.

<img width="1442" height="806" alt="image" src="https://github.com/user-attachments/assets/0eee1f22-dc6c-4709-9b65-1e1a983e1d94" />

* **Tab 2: Customer Retention**
  * **Key Features:** Horizontal bar chart ranking customers by balance decline %, alongside a dynamic account maturity tracker.
  * **💡 Snapshot Insight:** Highlights immediate churn risks by pinpointing high-value accounts experiencing sharp balance drops (up to **-11.76%** in deposits). RMs can cross-reference this with impending maturity dates (e.g., spikes in July/August 2026) to intervene preemptively.

<img width="1439" height="807" alt="image" src="https://github.com/user-attachments/assets/0a8a1681-def5-4ec4-8a88-052bebec19ba" />

<img width="1441" height="810" alt="image" src="https://github.com/user-attachments/assets/30920b30-798d-487e-88f9-9d496c1f2c52" />

* **Tab 3: Customer Activation**
  * **Key Features:** Box-and-whisker plot for Activation Priority Score and workload distribution by department.
  * **💡 Snapshot Insight:** The activation workload is heavily unbalanced, with the **Retail Department (Phòng Bán lẻ)** bearing the brunt of the backlog (596 accounts requiring immediate activation), indicating a need for prioritized resource allocation.
  * 
<img width="1442" height="806" alt="image" src="https://github.com/user-attachments/assets/25db21e9-fe15-4eea-a470-58d163998bcd" />

---
## 🔗 Live Dashboard
Click here to interact with the dashboard: 
(https://report.onhandbi.com/public/report?token=eyJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfbGlua19pZCI6NzE1LCJoYXNfcGFzc2NvZGUiOmZhbHNlLCJ0aW1lIjoxNzg2MDA3Mjg0fQ.M4cbgQ6xn6y_zWycfSIzMAW2LBwD19wTxxRUeMWqWAU)
or
(https://admin.onhandbi.com/user/report/TVRjME1BPT0=?tenant=ohbi_tenant)
