--*/
--Data cleaning with SQL/*

SELECT *
FROM NashvilleData

--Standardize Date Format

SELECT SalesDate --CONVERT(Date, SaleDate) AS SalesDate
FROM NashvilleData

UPDATE NashvilleData
SET SaleDate = CONVERT(Date, SaleDate)

--The above query did not mee expectation so we try alter table

ALTER TABLE NashvilleData
ADD SalesDate Date

UPDATE NashvilleData
SET SalesDate = CONVERT(Date, SaleDate)


--Lets take a quick view the property address field

SELECT PropertyAddress
FROM NashvilleData
WHERE PropertyAddress IS NULL

SELECT *
FROM NashvilleData
WHERE PropertyAddress IS NULL

--Populate Property Address Data by joining the table on itself

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) AS UpdatedAddress
FROM NashvilleData AS a
JOIN NashvilleData AS b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleData AS a
JOIN NashvilleData AS b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into individual columns(Address & City)
--Lets use the SUBSTRING , CHARINDEX AND LEN function to split the field

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As City
FROM NashvilleData
--WHERE PropertyAddress IS NULL

ALTER TABLE NashvilleData
ADD UpdatedAddress nvarchar(255)

UPDATE NashvilleData
SET UpdatedAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleData
ADD UpdatedCity nvarchar(255)

UPDATE NashvilleData
SET UpdatedCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Breaking out OWnersAddress into individual column(Address, city & State)
--Lets use the PARSENAME and REPLACE function to split the OwnerAddress column

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM NashvilleData


ALTER TABLE NashvilleData
ADD Updated_Owner_Address nvarchar(255)

UPDATE NashvilleData
SET Updated_Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleData
ADD Updated_Owner_City nvarchar(255)

UPDATE NashvilleData
SET Updated_Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleData
ADD Updated_Owner_State nvarchar(255)

UPDATE NashvilleData
SET Updated_Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)



--Change Y and N to Yes and No in SoldAsVacant field

SELECT
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleData


UPDATE NashvilleData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleData


--Remove Duplicate Rows

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
ORDER BY UniqueID) row_num
FROM NashvilleData
order by ParcelID

-- To be able to use the where clause to know the number of row_num greater than 1 we will convert the above query to CTE

WITH Duplicaterows As(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
ORDER BY UniqueID) row_num
FROM NashvilleData
)
--order by ParcelID

DELETE
FROM Duplicaterows
WHERE row_num > 1


--Delete Unused Columns

ALTER TABLE NashvilleData
DROP COLUMN PropertyAddress,
			SaleDate,
			OwnerAddress,
			TaxDistrict

