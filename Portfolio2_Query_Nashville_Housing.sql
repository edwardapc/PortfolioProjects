--cleaning Data in SQL Queries

select * 
from Nashville_Housing

--standarize date format

select SaleDateConverted, CONVERT (date,SaleDate)
from Nashville_Housing

update Nashville_Housing
SET SaleDate = CONVERT (date,SaleDate)

ALTER TABLE Nashville_Housing
Add SaleDateConverted Date;

update Nashville_Housing
SET SaleDateConverted = CONVERT (date,SaleDate)


--Populate Property Address Data

select *
from Nashville_Housing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing a
	join Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing a
	join Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual Columns (Address, City, State)


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS State

from Nashville_Housing

ALTER TABLE Nashville_Housing
Add PropertySplitAddress nvarchar(255);

update Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville_Housing
Add PropertySplitCity nvarchar(255);

update Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


select 
parsename(replace(OwnerAddress, ',', '.'),3)
,parsename(replace(OwnerAddress, ',', '.'),2)
,parsename(replace(OwnerAddress, ',', '.'),1)
from Nashville_Housing

ALTER TABLE Nashville_Housing
Add OwnerSplitAddress nvarchar(255);

update Nashville_Housing
SET OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'),3)

ALTER TABLE Nashville_Housing
Add OwnerySplitCity nvarchar(255);

update Nashville_Housing
SET OwnerySplitCity = parsename(replace(OwnerAddress, ',', '.'),2)

ALTER TABLE Nashville_Housing
Add OwnerySplitState nvarchar(255);

update Nashville_Housing
SET OwnerySplitState = parsename(replace(OwnerAddress, ',', '.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from Nashville_Housing
group by SoldAsVacant
order by 2 desc

select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	End
from Nashville_Housing

update Nashville_Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	End

--remove duplicates
WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
					UniqueID
					) Row_Num
				
from Nashville_Housing
)
Delete
from RowNumCTE
where Row_Num > 1


--Delete unused Columns

Select * 
From Nashville_Housing

alter table Nashville_Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Nashville_Housing
drop column SaleDate