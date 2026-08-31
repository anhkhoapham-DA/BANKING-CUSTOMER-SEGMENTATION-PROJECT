# KPIM Customer Segmentation Dashboard 🏦📊

> **Disclaimer:** Data used in this project is simulated for demonstration purposes and does not represent real customer or account information.

A comprehensive Power BI solution for banking customer segmentation, combining SQL-based data preparation with an interactive 4-page reporting experience. This dashboard provides a 360-degree view of the customer portfolio, enabling stakeholders to monitor risk, evaluate individual profiles, and drive actionable customer care solutions.

## 🎯 Business Objective
In the retail and corporate banking sector, understanding customer behavior and lifecycle stages is critical. This dashboard addresses key business needs by:
* **Holistic Portfolio Management:** Providing a macro-view of customer distribution across 19 lifecycle and risk segments.
* **Proactive Risk Mitigation:** Tracking at-risk accounts, monitoring debt groups, and forecasting NPL (Non-Performing Loan) provisioning needs.
* **Targeted Customer Care:** Empowering Relationship Managers (RMs) with data-driven triggers for Cross-Selling, Retention, and Activation.
* 
## 🛠 Tech Stack & Data Architecture
* **Data Transformation :** **dbt (Data Build Tool)** & **SQL**. Transitioned from a monolithic SQL script to a modular Medallion architecture (Silver and Gold layers) to process complex customer segmentation logic, improving code maintainability, query performance, and data lineage tracking.
* **Version Control:** **Git & GitHub** for tracking dbt models and ensuring robust version control for the data transformation pipeline.
* **Business Intelligence:** **Power BI** (Interactive report design, UI/UX optimization).
* **Data Modeling:** Optimized Star Schema architecture connecting Fact tables with Dimension tables (Customers, Branches, Products). 
* **Advanced Analytics:** **DAX** (Custom measures for risk scoring, trend ratios, cross-sell matrix logic, and dynamic maturity tracking).
---

## 📊 Dashboard Overview & Key Insights

### 0. Data Model 
<img width="1706" height="971" alt="Ảnh chụp màn hình 2026-08-06 154119" src="https://github.com/user-attachments/assets/b55e4f61-8065-46b6-aaaa-c3502cf4fa34" />

### 1. Cover Page
Landing page introducing the four report sections with a consistent, professional navy/gold theme. Features clickable navigation cards for a seamless user experience.

<img width="2242" height="1258" alt="Ảnh chụp màn hình 2026-08-25 213804" src="https://github.com/user-attachments/assets/7a945a9a-38e2-451c-a642-9896a41ee4c5" />

### 2. Customer 360
Portfolio-level overview of the entire customer base tracking total customers, balances, and macro-trends.
* **Key Features:** Total customers and balance KPIs, Final Customer Segment Distribution (19 segments), Dual-line trend chart for Loan vs. Deposit, and Product/Activity donut charts.
* **💡 Snapshot Insight:** The portfolio shows a significant concentration of **Dormant Customers (24.01%)** and customers with **No Product (67.01%)**. Additionally, the macro trend highlights a shift from Q1-2025, where total deposits surged and stabilized above loan balances.

<img width="2240" height="1261" alt="Ảnh chụp màn hình 2026-08-25 213814" src="https://github.com/user-attachments/assets/18922ac4-db2a-47ea-bdb8-af52e64d339e" />

### 3. Customer Individual Profile
A full 360° view of a single selected customer (searchable by CIF & Name) designed for Relationship Managers.
* **Key Features:** Customer demographics, RM details, balance/trend gauges, and an account-level breakdown table.
* **💡 Snapshot Insight:** The dynamic Radar Chart and Trend Ratios quickly profile users. For example, CIF 3000001721 is immediately identifiable as a high-value "Deposit-Leaning Customer" (Diamond Plus) with a healthy Deposit Trend Ratio (1.17), providing the RM with clear context before engagement.

<img width="1441" height="808" alt="image" src="https://github.com/user-attachments/assets/d563b959-ca79-4040-a917-1fbf558e02f6" />

### 4. Customer Risk Management
Monitoring and analysis of at-risk customers to support credit risk departments.
* **Key Features:** At-risk KPIs (requiring NPL provision, with collateral), Worst Debt Group Trend, and a Box-and-Whisker plot for Risk Score Range by Segment.
* **💡 Snapshot Insight:** A massive **73.03%** of at-risk customers fall into the "Potential Risk - No Product Relationship" bucket. The Box-and-Whisker plot clearly flags corporate segments, particularly **"KHDN LỚN" (highlighted in red)**, as having a significantly skewed risk distribution compared to retail segments.


<img width="2238" height="1258" alt="Ảnh chụp màn hình 2026-08-25 213837" src="https://github.com/user-attachments/assets/ae5c6b3f-34de-49a9-a8f1-abe7f34fd70e" />

<img width="2245" height="1260" alt="Ảnh chụp màn hình 2026-08-25 213849" src="https://github.com/user-attachments/assets/dc9eddad-4914-4905-bbe8-afec36ad1cd2" />

### 5. Customer Care Solutions
An actionable, three-tab section supporting CRM activities with a persistent left-hand KPI panel.

* **Tab 1: Customer Expansion**
  * **Key Features:** Interactive Cross-Sell Matrix mapping row-product vs. column-product ownership.
  * **💡 Snapshot Insight:** The matrix reveals highly siloed product ownership. Cross-selling success is currently concentrated in specific niches (e.g., 100% overlap between mixed real estate loans and corporate real estate projects), leaving vast white space for broader retail expansion campaigns.

<img width="1442" height="808" alt="image" src="https://github.com/user-attachments/assets/5dc194cf-7f36-4f51-aa9e-85032129e579" />

* **Tab 2: Customer Retention**
  * **Key Features:** Horizontal bar chart ranking customers by balance decline %, alongside a dynamic account maturity tracker.
  * **💡 Snapshot Insight:** Highlights immediate churn risks by pinpointing high-value accounts experiencing sharp balance drops (up to **-11.76%** in deposits). RMs can cross-reference this with impending maturity dates (e.g., spikes in July/August 2026) to intervene preemptively.

<img width="1444" height="810" alt="image" src="https://github.com/user-attachments/assets/1bfbe536-4bab-45bf-bf9b-6a62e91bcbe6" />

<img width="1441" height="809" alt="image" src="https://github.com/user-attachments/assets/ae80752a-57dd-4356-ab0a-712dbe7aa4d8" />

* **Tab 3: Customer Activation**
  * **Key Features:** Box-and-whisker plot for Activation Priority Score and workload distribution by department.
  * **💡 Snapshot Insight:** The activation workload is heavily unbalanced, with the **Retail Department (Phòng Bán lẻ)** bearing the brunt of the backlog (596 accounts requiring immediate activation), indicating a need for prioritized resource allocation.

<img width="1441" height="810" alt="image" src="https://github.com/user-attachments/assets/5b2c56ae-aa04-406b-9199-708f9acb6c04" />

---

## 🔗 Live Demo
Click here to interact with the dashboard: 
(https://report.onhandbi.com/public/report?token=eyJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfbGlua19pZCI6NzE1LCJoYXNfcGFzc2NvZGUiOmZhbHNlLCJ0aW1lIjoxNzg2MDA3Mjg0fQ.M4cbgQ6xn6y_zWycfSIzMAW2LBwD19wTxxRUeMWqWAU)
or
(https://admin.onhandbi.com/user/report/TVRjME1BPT0=?tenant=ohbi_tenant)
