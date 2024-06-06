## Q3 Data Quality Findings
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

