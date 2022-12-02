--DATA CLEANING

Select * from ProjectPortfolio..HousingData

--Format SalesDate column - remove time

Select SaleDate, CONVERT(Date,saledate) 
from ProjectPortfolio..HousingData

Update HousingData
set SaleDateConverted = CONVERT(Date,saledate)
--OR
ALTER TABLE HousingData
Add SaleDateConverted Date

--Confirm new column was added and populated
Select SaleDateConverted 
from ProjectPortfolio..HousingData

--Format PropertyAddress column
Select *
from ProjectPortfolio..HousingData
--where PropertyAddress is null
order by ParcelID
--The parcelIDs correspond with the respective propertyaddresses, so based on ParcelIDs, 
--I populated all null propertyaddress with the address found in records that have the same parcelID

--Editing Query
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.propertyAddress,b.PropertyAddress)
from ProjectPortfolio..HousingData a
JOIN ProjectPortfolio..HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

--Updating the table
Update a
SET propertyaddress = isnull(a.propertyAddress,b.PropertyAddress)
from ProjectPortfolio..HousingData a
JOIN ProjectPortfolio..HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

--Breaking Property address into Address & City

Select *
from ProjectPortfolio..HousingData

--QueryTesting
Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,CHARINDEX(',',propertyaddress)-1) as City --OR SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress))
from ProjectPortfolio..HousingData

--TableUpdate
Alter Table HousingData
Add PropertySplitAddress Nvarchar(255), PropertySplitCity Nvarchar(255)

Update HousingData
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1),
	PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress))


--Breaking Owner address into Address, City & State

Select  *
from ProjectPortfolio..HousingData

--QueryTesting
Select
PARSENAME(replace(owneraddress,',','.'),3), ---parsename only works with periods so we need to replace all commas with period
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from ProjectPortfolio..HousingData

--TableUpdate
ALTER TABLE HousingData
ADD OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

Update HousingData
Set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3),
	OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2),
	OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1)


--Update Soldasvacant column

--confirming column state
Select  distinct(SoldAsVacant), COUNT(soldasvacant)
from ProjectPortfolio..HousingData
group by soldasvacant
order by 2

--Normalizing and Updating the Data
--QueryTesting
Select  SoldAsVacant,
	CASE WHEN Soldasvacant = 'Y' then 'Yes'
		WHEN Soldasvacant = 'N' then 'No'
		ELSE Soldasvacant
		END
from ProjectPortfolio..HousingData

--TableUpdate
Update HousingData
SET SoldAsVacant = CASE WHEN Soldasvacant = 'Y' then 'Yes'
						WHEN Soldasvacant = 'N' then 'No'
						ELSE Soldasvacant
						END

---Remove Duplicates

WITH RowNumCTE as (
Select  *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, --partition should be done based on things that are unique to each record
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					uniqueID
					) row_num
from ProjectPortfolio..HousingData
--order by ParcelID --to add a criteria on row_num add a CTE
)
--Select * from RowNumCTE
--where row_num > 1  --this helps to identify and confirm that dupes are indeed dupes
--order by PropertyAddress
Delete from RowNumCTE
where row_num > 1


---Delete Unused columns (only used in views)
ALTER TABLE ProjectPortfolio..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProjectPortfolio..HousingData
DROP COLUMN SaleDate

---Checking Data
Select * from ProjectPortfolio..HousingData
