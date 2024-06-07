-- What are the top 5 brands by receipts scanned for most recent month?
-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
WITH current_month AS (
    SELECT
        brandcode,
        COUNT(DISTINCT(receipt_id)) AS total_receipts,
        RANK() OVER (ORDER BY COUNT(DISTINCT(receipt_id)) DESC) AS rank
    FROM
        rewards_receipt_item_list
    WHERE
        receipt_id IN (
            SELECT
                receipt_id
            FROM
                receipts
            WHERE
                dateScanned >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
                AND dateScanned < DATE_TRUNC('month', CURRENT_DATE)
        )
        AND brandcode IS NOT NULL
        AND brandcode <> 'BRAND'
    GROUP BY
        brandcode
),
previous_month AS (
    SELECT
        brandcode,
        COUNT(DISTINCT(receipt_id)) AS total_receipts,
        RANK() OVER (ORDER BY COUNT(DISTINCT(receipt_id)) DESC) AS rank
    FROM
        rewards_receipt_item_list
    WHERE
        receipt_id IN (
            SELECT
                receipt_id
            FROM
                receipts
            WHERE
                dateScanned >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '2 month'
                AND dateScanned < DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
        )
        AND brandcode IS NOT NULL
        AND brandcode <> 'BRAND'
    GROUP BY
        brandcode
)
SELECT
    cm.brandcode,
    cm.total_receipts AS current_receipt_count,
    pm.total_receipts AS previous_receipt_count,
    cm.rank AS current_month_rank,
    pm.rank AS previous_month_rank
FROM
    current_month cm
LEFT JOIN
    previous_month pm ON cm.brandcode = pm.brandcode
ORDER BY
    cm.rank;

-- When considering average spend and total number of items purchased from receipts with 'rewardsReceiptStatus' of 'Accepted' or 'Rejected', which is greater?
SELECT
    CASE
        WHEN AVG(CASE WHEN rewardsReceiptStatus = 'FINISHED' THEN totalSpent END) >
             AVG(CASE WHEN rewardsReceiptStatus = 'REJECTED' THEN totalSpent END) THEN 'FINISHED'
        ELSE 'REJECTED'
    END AS greater_avg_spend_status,
    CASE
        WHEN SUM(CASE WHEN rewardsReceiptStatus = 'FINISHED' THEN purchasedItemCount END) >
             SUM(CASE WHEN rewardsReceiptStatus = 'REJECTED' THEN purchasedItemCount END) THEN 'FINISHED'
        ELSE 'REJECTED'
    END AS greater_total_items_status
FROM
    receipts
WHERE
    rewardsReceiptStatus IN ('FINISHED', 'REJECTED');

-- Which brand has the most spend and most transactions among users who were created within the past 6 months?
SELECT
    spend.brand_name AS brand_with_most_spend,
    spend.total_spend,
    transactions.brand_name AS brand_with_most_transactions,
    transactions.transaction_count
FROM
    (
        SELECT
            b.name AS brand_name,
            SUM(r.totalSpent) AS total_spend,
            RANK() OVER (ORDER BY SUM(r.totalSpent) DESC) AS spend_rank
        FROM
            receipts r
        JOIN
            rewards_receipt_item_list rri ON r.receipt_id = rri.receipt_id
        JOIN
            brands b ON rri.brandCode = b.brandCode
        JOIN
            users u ON r.user_id = u.user_id
        WHERE
            u.createdDate >= DATEADD(month, -6, CURRENT_DATE)
        GROUP BY
            b.name
    ) spend
JOIN
    (
        SELECT
            b.name AS brand_name,
            COUNT(r.receipt_id) AS transaction_count,
            RANK() OVER (ORDER BY COUNT(r.receipt_id) DESC) AS transaction_rank
        FROM
            receipts r
        JOIN
            rewards_receipt_item_list rri ON r.receipt_id = rri.receipt_id
        JOIN
            brands b ON rri.brandCode = b.brandCode
        JOIN
            users u ON r.user_id = u.user_id
        WHERE
            u.createdDate >= DATEADD(month, -6, CURRENT_DATE)
        GROUP BY
            b.name
    ) transactions
ON
    spend.brand_name = transactions.brand_name
WHERE
    spend.spend_rank = 1 AND transactions.transaction_rank = 1;
