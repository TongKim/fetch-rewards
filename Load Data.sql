-- Create Tables --

CREATE OR REPLACE TABLE receipts (
  receipt_id STRING,
  bonusPointsEarned INTEGER,
  bonusPointsEarnedReason STRING,
  createDate TIMESTAMP,
  dateScanned TIMESTAMP,
  finishedDate TIMESTAMP,
  modifyDate TIMESTAMP,
  pointsAwardedDate TIMESTAMP,
  pointsEarned INTEGER,
  purchaseDate TIMESTAMP,
  purchasedItemCount INTEGER,
  rewardsReceiptStatus STRING,
  totalSpent NUMBER,
  user_id STRING
);


CREATE OR REPLACE TABLE users (
  user_id STRING,
  state STRING,
  createdDate TIMESTAMP,
  lastLogin TIMESTAMP,
  role STRING,
  active BOOLEAN,
  signUpSource STRING
);


CREATE OR REPLACE TABLE brands (
  brand_id STRING,
  barcode STRING,
  brandCode STRING,
  category STRING,
  categoryCode STRING,
  cpg_id STRING,
  cpg_ref STRING,
  topBrand BOOLEAN,
  name STRING
);


CREATE OR REPLACE TABLE rewards_receipt_item_list (
  receipt_id STRING,
  item_index INTEGER,
  barcode STRING,
  description STRING,
  finalPrice STRING,
  itemPrice STRING,
  needsFetchReview BOOLEAN,
  partnerItemId STRING,
  preventTargetGapPoints BOOLEAN,
  quantityPurchased INTEGER,
  userFlaggedBarcode STRING,
  userFlaggedNewItem BOOLEAN,
  userFlaggedPrice STRING,
  userFlaggedQuantity INTEGER,
  needsFetchReviewReason STRING,
  pointsNotAwardedReason STRING,
  pointsPayerId STRING,
  rewardsGroup STRING,
  rewardsProductPartnerId STRING,
  targetPrice STRING,
  originalFinalPrice STRING,
  originalMetaBriteBarcode STRING,
  originalMetaBriteDescription STRING,
  originalMetaBriteItemPrice STRING,
  originalMetaBriteQuantityPurchased INTEGER,
  userFlaggedDescription STRING,
  competitiveProduct BOOLEAN,
  deleted BOOLEAN,
  originalReceiptItemText STRING,
  brandCode STRING,
  competitorRewardsGroup STRING,
  discountedItemPrice STRING,
  itemNumber STRING,
  pointsEarned STRING,
  department STRING
);



-- Load data into temproary tables --

CREATE OR REPLACE TABLE temp_receipts (
  data VARIANT
);

CREATE OR REPLACE TABLE temp_users (
  data VARIANT
);

CREATE OR REPLACE TABLE temp_brands (
  data VARIANT
);


COPY INTO temp_receipts
FROM @FETCH.PUBLIC.FETCH/Receipts.json
FILE_FORMAT = (TYPE = 'JSON');

COPY INTO temp_users
FROM @FETCH.PUBLIC.FETCH/users.json
FILE_FORMAT = (TYPE = 'JSON');

COPY INTO temp_brands
FROM @FETCH.PUBLIC.FETCH/brands.json
FILE_FORMAT = (TYPE = 'JSON');


-- Transfer data type from temporary table and insert into target data table --

INSERT INTO receipts
SELECT 
  data:_id:"$oid"::STRING AS receipt_id,
  data:bonusPointsEarned::INTEGER,
  data:bonusPointsEarnedReason::STRING,
  TO_TIMESTAMP_NTZ(data:createDate:"$date"::NUMBER / 1000),
  TO_TIMESTAMP_NTZ(data:dateScanned:"$date"::NUMBER / 1000),
  TO_TIMESTAMP_NTZ(data:finishedDate:"$date"::NUMBER / 1000),
  TO_TIMESTAMP_NTZ(data:modifyDate:"$date"::NUMBER / 1000),
  TO_TIMESTAMP_NTZ(data:pointsAwardedDate:"$date"::NUMBER / 1000),
  data:pointsEarned::INTEGER,
  TO_TIMESTAMP_NTZ(data:purchaseDate:"$date"::NUMBER / 1000),
  data:purchasedItemCount::INTEGER,
  data:rewardsReceiptStatus::STRING,
  data:totalSpent::NUMBER,
  data:userId::STRING AS user_id
FROM temp_receipts;


INSERT INTO users
SELECT 
  data:_id:"$oid"::STRING AS user_id,
  data:state::STRING,
  TO_TIMESTAMP_NTZ(data:createdDate:"$date"::NUMBER / 1000),
  TO_TIMESTAMP_NTZ(data:lastLogin:"$date"::NUMBER / 1000),
  data:role::STRING,
  data:active::BOOLEAN,
  data:signUpSource::STRING
FROM temp_users;


INSERT INTO brands
SELECT 
  data:_id:"$oid"::STRING AS brand_id,
  data:barcode::STRING AS barcode,
  data:brandCode::STRING AS brandCode,
  data:category::STRING AS category,
  data:categoryCode::STRING AS categoryCode,
  data:cpg:"$id":"$oid"::STRING AS cpg_id,
  data:cpg:"$ref"::STRING AS cpg_ref,
  data:topBrand::BOOLEAN AS topBrand,
  data:name::STRING AS name
FROM temp_brands;

INSERT INTO rewards_receipt_item_list
WITH flattened AS (
  SELECT
    data:_id:"$oid"::STRING AS receipt_id,
    item.value::VARIANT AS item
  FROM temp_receipts,
  LATERAL FLATTEN(input => data:rewardsReceiptItemList) AS item
)
SELECT
  receipt_id,
  ROW_NUMBER() OVER (PARTITION BY receipt_id ORDER BY (SELECT NULL)) - 1 AS item_index,
  item:barcode::STRING AS barcode,
  item:description::STRING AS description,
  item:finalPrice::STRING AS finalPrice,
  item:itemPrice::STRING AS itemPrice,
  item:needsFetchReview::BOOLEAN AS needsFetchReview,
  item:partnerItemId::STRING AS partnerItemId,
  item:preventTargetGapPoints::BOOLEAN AS preventTargetGapPoints,
  item:quantityPurchased::INTEGER AS quantityPurchased,
  item:userFlaggedBarcode::STRING AS userFlaggedBarcode,
  item:userFlaggedNewItem::BOOLEAN AS userFlaggedNewItem,
  item:userFlaggedPrice::STRING AS userFlaggedPrice,
  item:userFlaggedQuantity::INTEGER AS userFlaggedQuantity,
  item:needsFetchReviewReason::STRING AS needsFetchReviewReason,
  item:pointsNotAwardedReason::STRING AS pointsNotAwardedReason,
  item:pointsPayerId::STRING AS pointsPayerId,
  item:rewardsGroup::STRING AS rewardsGroup,
  item:rewardsProductPartnerId::STRING AS rewardsProductPartnerId,
  item:targetPrice::STRING AS targetPrice,
  item:originalFinalPrice::STRING AS originalFinalPrice,
  item:originalMetaBriteBarcode::STRING AS originalMetaBriteBarcode,
  item:originalMetaBriteDescription::STRING AS originalMetaBriteDescription,
  item:originalMetaBriteItemPrice::STRING AS originalMetaBriteItemPrice,
  item:originalMetaBriteQuantityPurchased::INTEGER AS originalMetaBriteQuantityPurchased,
  item:userFlaggedDescription::STRING AS userFlaggedDescription,
  item:competitiveProduct::BOOLEAN AS competitiveProduct,
  item:deleted::BOOLEAN AS deleted,
  item:originalReceiptItemText::STRING AS originalReceiptItemText,
  item:brandCode::STRING AS brandCode,
  item:competitorRewardsGroup::STRING AS competitorRewardsGroup,
  item:discountedItemPrice::STRING AS discountedItemPrice,
  item:itemNumber::STRING AS itemNumber,
  item:pointsEarned::STRING AS pointsEarned,
  item:department::STRING AS department
FROM flattened;
--------------------------------------------------------------------------------------



