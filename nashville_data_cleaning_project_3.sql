SELECT
	SaleDate
FROM housing
ORDER BY SaleDate;
-- Standize the data-----------------------------------------------------------------------------------------------------------------------------
SELECT
	SaleDate, DATE(SaleDate)
FROM housing
ORDER BY SaleDate;
UPDATE Housing
SET SaleDate = DATE(SaleDate);
	-- to adding new column 
	ALTER TABLE housing
    ADD SaleDateConverted Date;
    UPDATE housing
    SET SaleDateConverted = DATE(SaleDate);
    
-- Populate property address data-------------------------------------------------------------------------------------------------------------------------------------
SELECT
	a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
   COALESCE(a.PropertyAddress,b.PropertyAddress)
FROM housing a
JOIN housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE housing a
JOIN housing  b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

select * from housing
where PropertyAddress IS NULL;

-- Breaking address into Individual Columns (Address,City,State)-----------------------------------------------------------------------------------------------------
SELECT
	SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1) AS Address,
    SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1 ,LENGTH(PropertyAddress)) AS City
FROM housing;

ALTER TABLE housing
ADD PropertySplitAddress NVARCHAR(255);
UPDATE housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1);

ALTER TABLE housing
ADD PropertySplitCity NVARCHAR(255);
UPDATE housing
SET PropertySplitCity = SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1 ,LENGTH(PropertyAddress));

SELECT 
	PropertySplitAddress,
    PropertySplitCity
FROM housing;

-- owner address split------
SELECT
	*
FROM housing;
SELECT
	SUBSTRING_INDEX(OwnerAddress, ',', +1) AS OwnerSplitAddress,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS OwnerSplitCity,
	SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerSplitState
FROM housing;

ALTER TABLE housing
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE housing
SET OwnerSplitAddress =	SUBSTRING_INDEX(OwnerAddress, ',', +1);

ALTER TABLE housing
ADD OwnerSplitCity NVARCHAR(255);
UPDATE housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE housing
ADD OwnerSplitState NVARCHAR(255);
UPDATE housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT
*
FROM housing;

-- Change Y and N to Yes and No in "Sold As Vacant" field ---------------------------------------------------------------------------------------------------------
SELECT
SoldAsVacant,COUNT(SoldAsVacant)
FROM housing
GROUP BY SoldAsVacant;

SELECT
	SoldAsVacant,
    CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacantConverted
FROM housing;

UPDATE housing
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-- Removing duplicates-------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	*,
    ROW_NUMBER() OVER
    (PARTITION BY ParcelID,
				  PropertyAddress,
                  SaleDate,
                  SalePrice,
                  LegalReference
                  ORDER BY UniqueID) AS Row_Num
FROM housing
ORDER BY ParcelID;

WITH Row_Num_CTE AS
(
SELECT
	*,
    ROW_NUMBER() OVER
    (PARTITION BY ParcelID,
				  PropertyAddress,
                  SaleDate,
                  SalePrice,
                  LegalReference
                  ORDER BY UniqueID) AS Row_Num
FROM housing
)
SELECT * FROM Row_Num_CTE
WHERE Row_Num > 1;


WITH Row_Num_CTE AS
(
SELECT
	*,
    ROW_NUMBER() OVER
    (PARTITION BY ParcelID,
				  PropertyAddress,
                  SaleDate,
                  SalePrice,
                  LegalReference
                  ORDER BY UniqueID) AS Row_Num
FROM housing
)
DELETE FROM housing
WHERE UniqueID IN(
	SELECT UniqueID
	FROM Row_Num_CTE
	WHERE Row_Num > 1
);

-- Delete Unused Column ------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	*
FROM housing;

ALTER TABLE housing
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict;









