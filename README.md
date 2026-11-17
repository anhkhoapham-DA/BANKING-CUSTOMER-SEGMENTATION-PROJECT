# Banking Customer Segmentation Project

> **Disclaimer:** Data used in this project is simulated for demonstration purposes and does not represent real customer or account information.

A comprehensive Power BI solution for banking customer segmentation, combining SQL-based data preparation with an interactive 4-page reporting experience. This dashboard provides a 360-degree view of the customer portfolio, enabling stakeholders to monitor risk, evaluate individual profiles, and drive actionable customer care solutions.

## Business Objective
In the retail and corporate banking sector, understanding customer behavior and lifecycle stages is critical. This dashboard addresses key business needs by:
* **Holistic Portfolio Management:** Providing a macro-view of customer distribution across 20 final segments.
* **Proactive Risk Mitigation:** Tracking at-risk accounts, monitoring debt groups, and forecasting NPL (Non-Performing Loan) provisioning needs.
* **Targeted Customer Care:** Empowering Relationship Managers (RMs) with data-driven triggers for Cross-Selling, Retention, and Activation.

## Tech Stack & Data Architecture
* **Data Transformation :** **dbt (Data Build Tool)** & **SQL**. Transitioned from a monolithic SQL script to a modular Medallion architecture (Bronze, Silver, and Gold layers) to standardize source data, process complex customer segmentation logic, and improve code maintainability and data lineage tracking.
* **Version Control:** **Git & GitHub** for tracking dbt models and ensuring robust version control for the data transformation pipeline.
* **Business Intelligence:** **Power BI** (Interactive report design, UI/UX optimization).
* **Data Modeling:** Optimized Star Schema architecture connecting Fact tables with Dimension tables (Customers, Branches, Products). 
* **Advanced Analytics:** **DAX** (Custom measures for risk scoring, trend ratios, cross-sell matrix logic, and dynamic maturity tracking).
---
## Project Structure
```
customer_segmentation/
├── dbt_project.yml                       
├── models/
│   ├── sources.yml                       
│   ├── schema.yml                        
│   │
│   ├── bronze/                           
│   │   ├── bronze_customer.sql         
│   │   ├── bronze_customer_segment.sql   
│   │   ├── bronze_department.sql       
│   │   ├── bronze_deposit_account.sql  
│   │   ├── bronze_deposit_balance.sql 
│   │   ├── bronze_loan_account.sql   
│   │   ├── bronze_loan_balance.sql 
│   │   ├── bronze_product.sql
│   │   ├── bronze_region.sql
│   │   └── bronze_staff.sql       
│   │
│   ├── silver/                           # Data processing layer and customer-level business metrics
│   │   ├── silver_account_metrics.sql
│   │   ├── silver_as_of_date.sql
│   │   ├── silver_customer.sql
│   │   ├── silver_customer_segment.sql
│   │   ├── silver_department.sql
│   │   ├── silver_deposit_account.sql
│   │   ├── silver_deposit_balance.sql
│   │   ├── silver_deposit_metrics.sql
│   │   ├── silver_fact_du_no_asof.sql
│   │   ├── silver_fact_tien_gui_asof.sql
│   │   ├── silver_loan_account.sql
│   │   ├── silver_loan_balance.sql
│   │   ├── silver_loan_metrics.sql
│   │   ├── silver_product.sql
│   │   ├── silver_product_metrics.sql
│   │   ├── silver_region.sql
│   │   ├── silver_staff.sql
│   │   ├── silver_tenure_metrics.sql          
│   │
│   └── gold/                             # Segmentation and reporting tables for Power BI
│       ├── gold_customer_base.sql                # One row per customer combining all Silver metrics
│       ├── gold_customer_sub_segments.sql        # Value, relationship, life cycle, product, risk flags
│       ├── gold_customer_final_segmentation.sql  # Combines 5 dimensions into 20 customer segments
│       ├── gold_customer_360.sql                 # Customer-level table for the Customer 360 page
│       └── gold_cross_sell_matrix.sql            # Product affinity matrix for cross-sell opportunities
│
├── macros/
│   └── translate_term_type.sql           # Reusable macro for term type labels
├── seeds/
│   └── product_mapping.csv               # Product mapping reference (115 products)
└── analyses/
│   └── risk_score_eda.ipynb              # EDA and find the cutoff using Youden's J method
├──snapshots
├──tests
```
## 📊 Dashboard Overview & Key Insights

### 0. dbt docs
<img width="1848" height="627" alt="image" src="https://github.com/user-attachments/assets/627c5803-fab5-464c-82bd-d0795ddcf388" />

### 1. Data Model 
<img width="1694" height="936" alt="Ảnh chụp màn hình 2026-10-19 160848" src="https://github.com/user-attachments/assets/ee9f6f88-7967-49f9-b74c-c73253a6ae7d" />

### 2. Cover Page
Landing page introducing the four report sections with a consistent. Features clickable navigation cards for a seamless user experience.

<img width="1440" height="808" alt="Ảnh chụp màn hình 2026-10-13 115412" src="https://github.com/user-attachments/assets/01706b51-b081-44dd-871f-ea70a1326635" />

### 3. Customer 360
Portfolio-level overview of the entire customer base tracking total customers, balances, and macro-trends.
* **Key Features:** Total customers and balance KPIs, Final Customer Segment Distribution (19 segments), Dual-line trend chart for Loan vs. Deposit, and Product/Activity donut charts.
* **💡 Snapshot Insight:** The portfolio shows a significant concentration of **Dormant Customers (26.61%)** and customers with **No Product (67.01%)**. Additionally, the macro trend highlights a shift from Q1-2025, where total deposits surged and stabilized above loan balances.

<img width="1442" height="807" alt="Ảnh chụp màn hình 2026-11-17 133700" src="https://github.com/user-attachments/assets/1fd10baf-919d-4428-845b-4640972f3eef" />

### 4. Customer Individual Profile
A full 360° view of a single selected customer (searchable by CIF & Name) designed for Relationship Managers.
* **Key Features:** Customer demographics, RM details, balance/trend gauges, and an account-level breakdown table.
* **💡 Snapshot Insight:** The dynamic Radar Chart and Trend Ratios quickly profile users. For example, CIF 3000001721 is immediately identifiable as a high-value "Deposit-Leaning Customer" (Diamond Plus) with a healthy Deposit Trend Ratio (1.17), providing the RM with clear context before engagement.

<img width="1442" height="808" alt="image" src="https://github.com/user-attachments/assets/1c2cc224-5557-4fd2-9046-4234667d44b5" />

### 5. Customer Risk Management
Monitoring and analysis of at-risk customers to support credit risk departments.
* **Key Features:** At-risk KPIs (requiring NPL provision, with collateral), Worst Debt Group Trend, and a Box-and-Whisker plot for Risk Score Range by Segment.
* **💡 Snapshot Insight:** A massive **72.02%** of at-risk customers fall into the "Potential Risk - No Product Relationship" bucket. The Box-and-Whisker plot clearly flags corporate segments, particularly **"Large Enterprise" (highlighted in red)**, as having a significantly skewed risk distribution compared to retail segments.

<img width="1439" height="809" alt="image" src="https://github.com/user-attachments/assets/bace533b-39fe-458c-b764-7734b27f20e2" />

<img width="1441" height="809" alt="image" src="https://github.com/user-attachments/assets/4ba42fb8-683f-4c57-9c9f-9892f75a93cb" />

### 6. Customer Care Solutions
An actionable, three-tab section supporting CRM activities with a persistent left-hand KPI panel.

* **Tab 1: Customer Expansion**
  * **Key Features:** Interactive Cross-Sell Matrix mapping row-product vs. column-product ownership.
  * **💡 Snapshot Insight:** The matrix reveals highly siloed product ownership. Cross-selling success is currently concentrated in specific niches (e.g., 100% overlap between document discounting and corporate business loan), leaving vast white space for broader retail expansion campaigns.

<img width="1441" height="807" alt="image" src="https://github.com/user-attachments/assets/5ac02542-de84-4cae-91b4-482ec0761e03" />

* **Tab 2: Customer Retention**
  * **Key Features:** Horizontal bar chart ranking customers by balance decline %, alongside a dynamic account maturity tracker.
  * **💡 Snapshot Insight:** Highlights immediate churn risks by pinpointing high-value accounts experiencing sharp balance drops (up to **-6.59%** in deposits and **-8.64%** in loans). RMs can cross-reference this with impending maturity dates (e.g., spikes in July/August 2026) to intervene preemptively.

<img width="1442" height="808" alt="image" src="https://github.com/user-attachments/assets/1f183932-fbe2-4f33-8b24-7c2b4309bae7" />

<img width="1440" height="811" alt="image" src="https://github.com/user-attachments/assets/d0919f00-a9f3-4112-b387-b93c2847eab4" />

* **Tab 3: Customer Activation**
  * **Key Features:** Box-and-whisker plot for Activation Priority Score and workload distribution by department.
  * **💡 Snapshot Insight:** The activation workload is heavily unbalanced, with the **Retail Department** bearing the brunt of the backlog (666 accounts requiring immediate activation), indicating a need for prioritized resource allocation.
 
<img width="1443" height="811" alt="image" src="https://github.com/user-attachments/assets/143c435a-a030-4f9f-bc27-5b1671e506a4" />

---
## 🔗 Live Dashboard
Click here to interact with the dashboard: 
(https://report.onhandbi.com/public/report?token=eyJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfbGlua19pZCI6NzE1LCJoYXNfcGFzc2NvZGUiOmZhbHNlLCJ0aW1lIjoxNzg2MDA3Mjg0fQ.M4cbgQ6xn6y_zWycfSIzMAW2LBwD19wTxxRUeMWqWAU)
or
(https://admin.onhandbi.com/user/report/TVRjME1BPT0=?tenant=ohbi_tenant)
