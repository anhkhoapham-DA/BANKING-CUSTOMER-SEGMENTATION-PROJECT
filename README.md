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
* **Data Transformation :** **dbt (Data Build Tool)** & **SQL**. Transitioned from a monolithic SQL script to a modular Medallion architecture (Bronze, Silver, and Gold layers) to standardize source data, process complex customer segmentation logic, and improve code maintainability and data lineage tracking.
* **Version Control:** **Git & GitHub** for tracking dbt models and ensuring robust version control for the data transformation pipeline.
* **Business Intelligence:** **Power BI** (Interactive report design, UI/UX optimization).
* **Data Modeling:** Optimized Star Schema architecture connecting Fact tables with Dimension tables (Customers, Branches, Products). 
* **Advanced Analytics:** **DAX** (Custom measures for risk scoring, trend ratios, cross-sell matrix logic, and dynamic maturity tracking).
---

## 📊 Dashboard Overview & Key Insights

### 0. dbt docs
<img width="1835" height="692" alt="image" src="https://github.com/user-attachments/assets/37a8154d-1a7a-4a07-8490-52276aa9c6fb" />

### 1. Data Model 
<img width="1315" height="787" alt="image" src="https://github.com/user-attachments/assets/763754bb-7c4d-45da-aa06-6d453bd1fd07" />


### 2. Cover Page
Landing page introducing the four report sections with a consistent, professional navy/gold theme. Features clickable navigation cards for a seamless user experience.

<img width="1440" height="808" alt="Ảnh chụp màn hình 2026-10-13 115412" src="https://github.com/user-attachments/assets/01706b51-b081-44dd-871f-ea70a1326635" />


### 3. Customer 360
Portfolio-level overview of the entire customer base tracking total customers, balances, and macro-trends.
* **Key Features:** Total customers and balance KPIs, Final Customer Segment Distribution (19 segments), Dual-line trend chart for Loan vs. Deposit, and Product/Activity donut charts.
* **💡 Snapshot Insight:** The portfolio shows a significant concentration of **Dormant Customers (24.01%)** and customers with **No Product (67.01%)**. Additionally, the macro trend highlights a shift from Q1-2025, where total deposits surged and stabilized above loan balances.

<img width="1440" height="806" alt="Ảnh chụp màn hình 2026-10-13 115423" src="https://github.com/user-attachments/assets/c5fb6f46-61a1-4dc3-8038-e8279146083c" />


### 4. Customer Individual Profile
A full 360° view of a single selected customer (searchable by CIF & Name) designed for Relationship Managers.
* **Key Features:** Customer demographics, RM details, balance/trend gauges, and an account-level breakdown table.
* **💡 Snapshot Insight:** The dynamic Radar Chart and Trend Ratios quickly profile users. For example, CIF 3000001721 is immediately identifiable as a high-value "Deposit-Leaning Customer" (Diamond Plus) with a healthy Deposit Trend Ratio (1.17), providing the RM with clear context before engagement.

<img width="1440" height="809" alt="Ảnh chụp màn hình 2026-10-13 115432" src="https://github.com/user-attachments/assets/cc062205-7ba0-4a66-a10e-15cb58d9907d" />


### 5. Customer Risk Management
Monitoring and analysis of at-risk customers to support credit risk departments.
* **Key Features:** At-risk KPIs (requiring NPL provision, with collateral), Worst Debt Group Trend, and a Box-and-Whisker plot for Risk Score Range by Segment.
* **💡 Snapshot Insight:** A massive **73.03%** of at-risk customers fall into the "Potential Risk - No Product Relationship" bucket. The Box-and-Whisker plot clearly flags corporate segments, particularly **"KHDN LỚN" (highlighted in red)**, as having a significantly skewed risk distribution compared to retail segments.


<img width="1441" height="809" alt="Ảnh chụp màn hình 2026-10-13 115441" src="https://github.com/user-attachments/assets/efd792e5-d96c-4cf0-8fd1-5881da0b9ec7" />


<img width="1442" height="805" alt="Ảnh chụp màn hình 2026-10-13 115451" src="https://github.com/user-attachments/assets/b0602fb0-7909-49c6-be89-1d1a1ad86fbb" />


### 6. Customer Care Solutions
An actionable, three-tab section supporting CRM activities with a persistent left-hand KPI panel.

* **Tab 1: Customer Expansion**
  * **Key Features:** Interactive Cross-Sell Matrix mapping row-product vs. column-product ownership.
  * **💡 Snapshot Insight:** The matrix reveals highly siloed product ownership. Cross-selling success is currently concentrated in specific niches (e.g., 100% overlap between mixed real estate loans and corporate real estate projects), leaving vast white space for broader retail expansion campaigns.

<img width="1439" height="809" alt="image" src="https://github.com/user-attachments/assets/5c734fb4-78b0-473c-942b-61aaeccd272b" />


* **Tab 2: Customer Retention**
  * **Key Features:** Horizontal bar chart ranking customers by balance decline %, alongside a dynamic account maturity tracker.
  * **💡 Snapshot Insight:** Highlights immediate churn risks by pinpointing high-value accounts experiencing sharp balance drops (up to **-11.76%** in deposits). RMs can cross-reference this with impending maturity dates (e.g., spikes in July/August 2026) to intervene preemptively.

<img width="1438" height="808" alt="image" src="https://github.com/user-attachments/assets/3c84e53f-2cb7-473b-94e5-d36e62433d99" />


<img width="1442" height="806" alt="image" src="https://github.com/user-attachments/assets/135f15b3-c695-4e41-8785-20a365407844" />


* **Tab 3: Customer Activation**
  * **Key Features:** Box-and-whisker plot for Activation Priority Score and workload distribution by department.
  * **💡 Snapshot Insight:** The activation workload is heavily unbalanced, with the **Retail Department (Phòng Bán lẻ)** bearing the brunt of the backlog (596 accounts requiring immediate activation), indicating a need for prioritized resource allocation.

<img width="1441" height="808" alt="image" src="https://github.com/user-attachments/assets/2da8c577-dd3f-412a-b6e2-16292239a539" />


---
## 🔗 Live Dashboard
Click here to interact with the dashboard: 
(https://report.onhandbi.com/public/report?token=eyJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfbGlua19pZCI6NzE1LCJoYXNfcGFzc2NvZGUiOmZhbHNlLCJ0aW1lIjoxNzg2MDA3Mjg0fQ.M4cbgQ6xn6y_zWycfSIzMAW2LBwD19wTxxRUeMWqWAU)
or
(https://admin.onhandbi.com/user/report/TVRjME1BPT0=?tenant=ohbi_tenant)
