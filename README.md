## ERD 
![ER Diagram](https://github.com/TongKim/fetch-rewards/assets/97964780/683adbe3-40e5-48ea-9e09-9db00fcba2e5)
_powered by Lucidchart_
## Methodologies 
After creating the tables based on the data model shown in the ERD, upload the Json file to the Snowflake Database's Stage, and then call Load Data.sql to load the data in Json format to the tables.









## Data Quality Findings
### Missing key Fields affects the quality and usefulness of the data analysis.
- users table: missing state, created time, last login time
- brands table: brand name, category, category code, brand_code
- receipts table user_id, total_spent
- item list table has many columns with more than 80% null values  
### Inconsistencies
- The same product has multiple brands
- The statistics on receipts do not match the actual calculations.
- Inactive users with recent login dates
- Inconsistencies in brand codes, where different brand codes actually correspond to the same brand, e.g., Ben and Jerry's and Ben & Jerry's

## Email

**Subject:** Initial Data Quality Assessment Results

Hi [Product/Business Leader's Name],

I hope this email finds you well. I would like to share some initial findings from the data quality assessment I performed on our datasets.

Summary of Findings:
After analyzing the datasets you provided, I've identified several areas where our data quality could be improved:

Missing Data: Key fields such as user_id and total_spent in Receipts, and brandCode in Brands have significant data missing. This could impact our ability to conduct comprehensive analyses and produce accurate reports.
Data Consistency: Some fields, like categoryCode in Brands, are inconsistently filled, which may lead to inaccurate categorization and insights. Additionally, instances like inactive users with recent login dates could affect the efficiency and accuracy of our data analysis.
Questions and Required Information:

Data Collection and Input: What are the current processes for data collection and input? Understanding this can help identify the root causes of missing or inconsistent data.
Business Rules: Are there specific business rules that guide how data should be handled or prioritized? This could impact how we address missing or inconsistent data.
Data Usage: How are these datasets being used by different teams? Knowing their applications will help prioritize data cleaning and preparation efforts.
Data Documentation: Providing a more comprehensive or applicable use-case data documentation would greatly assist us in building a more efficient and reliable data model.
Performance and Scaling Concerns:
As we scale, I anticipate challenges related to data ingestion and query performance, especially:

Data Growth: How will our current database architecture and indexing strategies handle increased loads as data volume grows?
Real-Time Processing: Does our current system support real-time data insights? If not, what changes are needed?
Optimizing Data Assets:
To better enhance our data assets for improved performance and scalability, I suggest:

Implementing Robust Data Validation: At the ingestion phase to catch anomalies early.
Enhancing Data Storage Practices: Such as partitioning and indexing, which could improve query performance.
Regular Data Quality Audits: To ensure the integrity and accuracy of our data over time.
I look forward to discussing these findings and hearing your feedback on how best to proceed.

Best regards,

Tong Jin
