# KPIM Customer Segmentation Dashboard 🏦📊

> **Disclaimer:** Data used in this project is simulated for demonstration purposes and does not represent real customer or account information.

A comprehensive Power BI solution for banking customer segmentation, combining SQL-based data preparation with an interactive 4-page reporting experience. This dashboard provides a 360-degree view of the customer portfolio, enabling stakeholders to monitor risk, evaluate individual profiles, and drive actionable customer care solutions.

## 🎯 Business Objective
In the retail and corporate banking sector, understanding customer behavior and lifecycle stages is critical. This dashboard addresses key business needs by:
* **Holistic Portfolio Management:** Providing a macro-view of customer distribution across 19 lifecycle and risk segments.
* **Proactive Risk Mitigation:** Tracking at-risk accounts, monitoring debt groups, and forecasting NPL (Non-Performing Loan) provisioning needs.
* **Targeted Customer Care:** Empowering Relationship Managers (RMs) with data-driven triggers for Cross-Selling, Retention, and Activation.

## 🛠 Tech Stack & Data Architecture
* **Data Preparation & Transformation:** SQL (Customer segmentation logic, data cleansing).
* **Business Intelligence:** Power BI (Interactive report design, UI/UX optimization).
* **Data Modeling:** Optimized Star Schema architecture connecting Fact tables with Dimension tables (Customers, Branches, Products).
* **Advanced Analytics:** DAX (Custom measures for risk scoring, trend ratios, cross-sell matrix logic, and dynamic maturity tracking).

---

## 📊 Dashboard Overview & Key Insights

### 0.Data Model 
<img width="1706" height="971" alt="Ảnh chụp màn hình 2026-08-06 154119" src="https://github.com/user-attachments/assets/b55e4f61-8065-46b6-aaaa-c3502cf4fa34" />

### 1. Cover Page
Landing page introducing the four report sections with a consistent, professional navy/gold theme. Features clickable navigation cards for a seamless user experience.

<img width="2008" height="1125" alt="Ảnh chụp màn hình 2026-08-06 151614" src="https://github.com/user-attachments/assets/6cfc619f-13ed-4141-bd79-de1ffe2ee6e5" />


### 2. Customer 360
Portfolio-level overview of the entire customer base tracking total customers, balances, and macro-trends.
* **Key Features:** Total customers and balance KPIs, Final Customer Segment Distribution (19 segments), Dual-line trend chart for Loan vs. Deposit, and Product/Activity donut charts.
* **💡 Snapshot Insight:** The portfolio shows a significant concentration of **Dormant Customers (24.01%)** and customers with **No Product (67.01%)**. Additionally, the macro trend highlights a shift from Q1-2025, where total deposits surged and stabilized above loan balances.

<img width="2005" height="1130" alt="Ảnh chụp màn hình 2026-08-06 151628" src="https://github.com/user-attachments/assets/cefe313e-ff25-4176-85f7-5d228deac80c" />

### 3. Customer Individual Profile
A full 360° view of a single selected customer (searchable by CIF & Name) designed for Relationship Managers.
* **Key Features:** Customer demographics, RM details, balance/trend gauges, and an account-level breakdown table.
* **💡 Snapshot Insight:** The dynamic Radar Chart and Trend Ratios quickly profile users. For example, CIF 3000001721 is immediately identifiable as a high-value "Deposit-Leaning Customer" (Diamond Plus) with a healthy Deposit Trend Ratio (1.17), providing the RM with clear context before engagement.

<img width="2005" height="1128" alt="Ảnh chụp màn hình 2026-08-06 151643" src="https://github.com/user-attachments/assets/9dfa0be1-e0f7-4773-a3bf-eec09b938192" />

### 4. Customer Risk Management
Monitoring and analysis of at-risk customers to support credit risk departments.
* **Key Features:** At-risk KPIs (requiring NPL provision, with collateral), Worst Debt Group Trend, and a Box-and-Whisker plot for Risk Score Range by Segment.
* **💡 Snapshot Insight:** A massive **73.03%** of at-risk customers fall into the "Potential Risk - No Product Relationship" bucket. The Box-and-Whisker plot clearly flags corporate segments, particularly **"KHDN LỚN" (highlighted in red)**, as having a significantly skewed risk distribution compared to retail segments.

<img width="2000" height="1121" alt="Ảnh chụp màn hình 2026-08-06 151658" src="https://github.com/user-attachments/assets/15883c75-9253-437b-8b12-a9235bfcfb02" />

<img width="2004" height="1129" alt="Ảnh chụp màn hình 2026-08-06 151726" src="https://github.com/user-attachments/assets/462c292a-d1c7-448d-9ffc-28f0a3933613" />



### 5. Customer Care Solutions
An actionable, three-tab section supporting CRM activities with a persistent left-hand KPI panel.

* **Tab 1: Customer Expansion**
  * **Key Features:** Interactive Cross-Sell Matrix mapping row-product vs. column-product ownership.
  * **💡 Snapshot Insight:** The matrix reveals highly siloed product ownership. Cross-selling success is currently concentrated in specific niches (e.g., 100% overlap between mixed real estate loans and corporate real estate projects), leaving vast white space for broader retail expansion campaigns.

<img width="2006" height="1125" alt="Ảnh chụp màn hình 2026-08-06 155238" src="https://github.com/user-attachments/assets/3ffc4072-a3e0-45ac-9213-bba5d000c884" />

* **Tab 2: Customer Retention**
  * **Key Features:** Horizontal bar chart ranking customers by balance decline %, alongside a dynamic account maturity tracker.
  * **💡 Snapshot Insight:** Highlights immediate churn risks by pinpointing high-value accounts experiencing sharp balance drops (up to **-11.76%** in deposits). RMs can cross-reference this with impending maturity dates (e.g., spikes in July/August 2026) to intervene preemptively.

<img width="2005" height="1126" alt="Ảnh chụp màn hình 2026-08-06 155306" src="https://github.com/user-attachments/assets/b41ffb0c-f67a-4f85-861a-888dc581a40a" />

<img width="2001" height="1122" alt="Ảnh chụp màn hình 2026-08-06 155317" src="https://github.com/user-attachments/assets/bd5a0abc-2511-4229-9b9e-b2487d807e56" />

* **Tab 3: Customer Activation**
  * **Key Features:** Box-and-whisker plot for Activation Priority Score and workload distribution by department.
  * **💡 Snapshot Insight:** The activation workload is heavily unbalanced, with the **Retail Department (Phòng Bán lẻ)** bearing the brunt of the backlog (596 accounts requiring immediate activation), indicating a need for prioritized resource allocation.

<img width="2001" height="1127" alt="Ảnh chụp màn hình 2026-08-06 155415" src="https://github.com/user-attachments/assets/a3a22405-bc35-40b2-a5c9-53ff84ec5858" />


### Data Model 
<img width="1706" height="971" alt="Ảnh chụp màn hình 2026-08-06 154119" src="https://github.com/user-attachments/assets/b55e4f61-8065-46b6-aaaa-c3502cf4fa34" />

---

## 🔗 Live Demo
Click here to interact with the dashboard: (https://report.onhandbi.com/public/report?token=eyJhbGciOiJIUzI1NiJ9.eyJwdWJsaWNfbGlua19pZCI6NzEzLCJoYXNfcGFzc2NvZGUiOmZhbHNlLCJ0aW1lIjoxNzg2MDA0MzY3fQ.5IdFl8X7bt9z5E59-3bB6NRVpG_TINkYfUmjAUjbWE4)
