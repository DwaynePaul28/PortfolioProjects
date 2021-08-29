

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing


SELECT SaleDateConverted, CONVERT(Date,SaleDate) as SaleDate2
FROM PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)


--Populate Property ADDRESS Data

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
 order by ParcelID

 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null



--Breaking out Address into individual Columns (ADDRESS, CITY, STATE)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--order by PropertyAddress asc

SELECT 
SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN (PropertyAddress))as Address
FROM PortfolioProject.dbo.NashvilleHousing




--Creating New Columns to Separate Data



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN (PropertyAddress))


SELECT *
FROM  PortfolioProject.dbo.NashvilleHousing


--Separate out address info into three Parts

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProject.dbo.NashvilleHousing


--Allter table by creating the columns then updating table with the columns
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,2)
 

 ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



--Dropped unnecessary Column from Table

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerPropertySplitCity


-- Change Y and N to Yes and No

SELECT Distinct (SoldAsVacant), COUNT (SoldAsVacant) ResponseCount
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order by 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN  SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing


--Update the Database with the Yes No Changes

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN  SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing






--Removing Duplicates (Stage 1: Identifying the duplicates)

WITH RowNumCTE AS (
SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--Removing Duplicates (Stage 2: Deleting the duplicates)

WITH RowNumCTE AS (
SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress




--DELETING Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate