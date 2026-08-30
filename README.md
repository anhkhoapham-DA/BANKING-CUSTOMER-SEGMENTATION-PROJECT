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
* **Data Transformation (ELT):** **dbt (Data Build Tool)** & **SQL**. Transitioned from a monolithic SQL script to a modular Medallion architecture (Silver and Gold layers) to process complex customer segmentation logic, improving code maintainability, query performance, and data lineage tracking.
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

<img width="2244" height="1262" alt="Ảnh chụp màn hình 2026-08-25 213826" src="https://github.com/user-attachments/assets/83a46446-8c55-4f59-b8e5-4994bcc08723" />

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

<img width="2239" height="1259" alt="Ảnh chụp màn hình 2026-08-25 213908" src="https://github.com/user-attachments/assets/ba03283a-c2b3-473f-95e8-4a5a22ec1623" />

* **Tab 2: Customer Retention**
  * **Key Features:** Horizontal bar chart ranking customers by balance decline %, alongside a dynamic account maturity tracker.
  * **💡 Snapshot Insight:** Highlights immediate churn risks by pinpointing high-value accounts experiencing sharp balance drops (up to **-11.76%** in deposits). RMs can cross-reference this with impending maturity dates (e.g., spikes in July/August 2026) to intervene preemptively.

<img width="2244" height="1257" alt="Ảnh chụp màn hình 2026-08-25 214121" src="https://github.com/user-attachments/assets/2d5a670c-4385-4c53-94db-876a1de510ec" />

<img width="2247" height="1259" alt="Ảnh chụp màn hình 2026-08-25 214054" src="https://github.com/user-attachments/assets/1bda2f98-09fb-49ad-b54f-b7546fbb2846" />

* **Tab 3: Customer Activation**
  * **Key Features:** Box-and-whisker plot for Activation Priority Score and workload distribution by department.
  * **💡 Snapshot Insight:** The activation workload is heavily unbalanced, with the **Retail Department (Phòng Bán lẻ)** bearing the brunt of the backlog (596 accounts requiring immediate activation), indicating a need for prioritized resource allocation.

<img width="2247" height="1263" alt="Ảnh chụp màn hình 2026-08-25 213931" src="https://github.com/user-attachments/assets/4dd0231a-3331-48d4-8032-5cc62765dd44" />

---

## 🔗 Live Demo
Click here to interact with the dashboard: 
(https://report.onhandbi.com/public/report?token=eyJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfbGlua19pZCI6NzE1LCJoYXNfcGFzc2NvZGUiOmZhbHNlLCJ0aW1lIjoxNzg2MDA3Mjg0fQ.M4cbgQ6xn6y_zWycfSIzMAW2LBwD19wTxxRUeMWqWAU)
or
(https://admin.onhandbi.com/user/report/TVRjME1BPT0=?tenant=ohbi_tenant)
