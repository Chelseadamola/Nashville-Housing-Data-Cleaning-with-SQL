--cleaning data in SQL queries
select *
from [Data Cleaning Project]..nashvillehousing



--standardize date format
select saledateconverted, convert(date,saledate)
from [Data Cleaning Projeuct]..nashvillehousing

--update NashvilleHousing
--set SaleDate = convert(date,saledate)

alter table nashvillehousing
add saledateconverted date;

update NashvilleHousing
set SaleDateConverted = convert(date,saledate)



--populate the property address
select *
from ..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress)
FROM [Data Cleaning Project]..NashvilleHousing as a
join [Data Cleaning Project]..NashvilleHousing as b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
 where a.PropertyAddress is null


 update a
 set a.PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
 FROM [Data Cleaning Project]..NashvilleHousing as a
join [Data Cleaning Project]..NashvilleHousing as b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
 where a.PropertyAddress is null



 -- Breaking out address into individual columns (Address, Ciy, State)
--PropertyAddress
 select propertyaddress
 from [Data Cleaning Project].dbo.NashvilleHousing
 
 select 
 substring(propertyaddress, 1, charindex(',', PropertyAddress) -1) as Address,
 substring(propertyaddress, charindex(',', PropertyAddress) +1, len(propertyaddress)) AS Address
 from [Data Cleaning Project]..NashvilleHousing

 alter table nashvillehousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(propertyaddress, 1, charindex(',', PropertyAddress) -1) 

alter table nashvillehousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(propertyaddress, charindex(',', PropertyAddress) +1, len(propertyaddress))


--OwnerAddress
select owneraddress
from ..NashvilleHousing

select
parsename(replace(owneraddress,',','.'), 1),
parsename(replace(owneraddress,',','.'), 2),
parsename(replace(owneraddress,',','.'), 3)
from ..NashvilleHousing


alter table nashvillehousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(owneraddress,',','.'), 3)

alter table nashvillehousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(owneraddress,',','.'), 2) 

alter table nashvillehousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(owneraddress,',','.'), 1) 



--Change Y and N to Yes and No in 'Sold as Vacant' Field
select distinct(SoldAsVacant), count(SoldAsVacant)
from ..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant ='Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from ..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant ='Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end



--Remove Duplicates
with RownumCTE as(
select *, 
   ROW_NUMBER() over (
   partition by parcelid,
                propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by
				  uniqueid
				  ) row_num
from [Data Cleaning Project]..NashvilleHousing
)
select *
from RownumCTE
where row_num >1



--Delete Unused Columns
select *
from [Data Cleaning Project]..nashvillehousing

alter table [Data Cleaning Project]..nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress

alter table [Data Cleaning Project]..nashvillehousing
drop column saledate







