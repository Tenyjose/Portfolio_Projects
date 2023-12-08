-----------------------------------------------------------------------------------------------------------------------------------------

--Cleaning Data in SQL Queries

select * from PortfolioProject..HousingProject

-----------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

select SaleDate,SaleDateConverted from PortfolioProject..HousingProject

select SaleDate,CAST(SaleDate as date) from PortfolioProject..HousingProject  -- we can also use Convert(Date,SaleDate) instead of CAST.

Alter table HousingProject
add SaleDateConverted Date

update HousingProject
set SaleDateConverted=CAST(SaleDate as date)


--------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * from PortfolioProject..HousingProject where PropertyAddress is Null

select * from PortfolioProject..HousingProject order by ParcelID

--since some property addresses are missing we need to fix that.We can search for common Parcel Id and if they exist we could use them to find the property address
--for that we have to join the table

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from PortfolioProject..HousingProject a
join PortfolioProject..HousingProject b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
	where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..HousingProject a
join PortfolioProject..HousingProject b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]


----------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress from PortfolioProject..HousingProject

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from PortfolioProject..HousingProject

ALTER TABLE HousingProject
Add PropertySplitAddress Nvarchar(255);

Update HousingProject
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE HousingProject
Add PropertySplitCity Nvarchar(255);

Update HousingProject
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select PropertyAddress,PropertySplitAddress,PropertySplitCity from PortfolioProject..HousingProject


select OwnerAddress from PortfolioProject..HousingProject

Select
PARSENAME(REPLACE(OwnerAddress,',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)
From PortfolioProject..HousingProject

ALTER TABLE PortfolioProject..HousingProject
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..HousingProject
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject..HousingProject
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..HousingProject
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject..HousingProject
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..HousingProject
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProject.dbo.HousingProject

----------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant),count(SoldAsVacant)
From PortfolioProject.dbo.HousingProject
group By SoldAsVacant
order by 2

select
SoldAsVacant,CASE when SoldAsVacant='Y' then 'Yes'
				  when SoldAsVacant='N' then 'No'
				  else SoldAsVacant
				  END
From PortfolioProject.dbo.HousingProject

update PortfolioProject.dbo.HousingProject
set SoldAsVacant=CASE when SoldAsVacant='Y' then 'Yes'
				  when SoldAsVacant='N' then 'No'
				  else SoldAsVacant
				  END


-------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE PortfolioProject..HousingProject
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject..HousingProject
