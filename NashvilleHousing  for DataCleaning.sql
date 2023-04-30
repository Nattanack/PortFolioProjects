

select *
from PortfolioProject..[NashvilleHousing ]
order by SaleDate desc


/*
Cleaning Data in SQL Queries
*/


-----------------------------------------------------------------------------------------------

-- Standardize Date Format

--select SaleDate
--from PortfolioProject..[NashvilleHousing ]



------------------------------------------------------------------------------------------------

--Populate Property Adress Data

-- The result came out with the duplicated PercalID and PropertyAddress
select *
from PortfolioProject..[NashvilleHousing ]
--where PropertyAddress is null
order by ParcelID


--Join PercerIID and PropertyAdress where both are not duplicated 
--Meanwhile, just to seperate UniqueID 


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..[NashvilleHousing ] a
join PortfolioProject..[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..[NashvilleHousing ] a
join PortfolioProject..[NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null




------------------------------------------------------------------------------------------------

--Breaking out Address into individual column (Address, City, State)

select PropertyAddress
from PortfolioProject..[NashvilleHousing ]
--order by PropertyAddress desc



select 
SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress)) as Address
from PortfolioProject..[NashvilleHousing ]

-- 1 refer to position 1, in this case we are looking at specific part in PropertyAddress

/* SUBSTRING Syntax = SUBSTRING(string, start, length)*/

-- CHARINDEX = The CHARINDEX() function searches for a substring in a string, and returns the position.

/* CHARINDEX Syntax = CHARINDEX(substring, string, start)*/

-- TEST
select 
SUBSTRING(PropertyAddress, 1, 10)
from PortfolioProject..[NashvilleHousing ]

-- Get rid of commas at the Adress by using - 1

select 
SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1 ) as Address
from PortfolioProject..[NashvilleHousing ]


-- By now we can seperate the Address Number and Street Address, hence the city is still missing so we will continue to fix the city


select 
SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..[NashvilleHousing ]


/* Adding LEN Syntax is to return the city address, also +1 just get rid of commas before city address*/



-- Create new column for Address


alter table  PortfolioProject..[NashvilleHousing ]
add PropertySplitAddress nvarchar (255);


update PortfolioProject..[NashvilleHousing ]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1 ) 



alter table  PortfolioProject..[NashvilleHousing ]
add PropertySplitCity nvarchar (255);

update PortfolioProject..[NashvilleHousing ]
set PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- In this case, we can not crate 2 columns so that we need to seperate into 2 updates 


select *
from PortfolioProject..[NashvilleHousing ]


------------------------------------------------------------------------------------------------


select OwnerAddress
from PortfolioProject..[NashvilleHousing ]

-- Try to do split everything out(Address number, Street, City and State)


-- By using PARSENAME

-- Meaning, PARSENAME = PARSENAME just returns the specified part of the specified object name.

-- Syntax = PARSENAME ('object_name' , object_piece )


select 
Parsename(OwnerAddress, 1)
from PortfolioProject..[NashvilleHousing ]

/* Nothing changes in this statement*/

-- Beacuse PARSENAME Statement just retrives the specific objact name

select 
Parsename(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..[NashvilleHousing ]


-- Using REPLACE Fucntion to replace substring, in this case is to replcae ',' in the address with '.'(Space)
-- But the result will return backward


select 
Parsename(Replace(OwnerAddress, ',', '.'), 3)
,Parsename(Replace(OwnerAddress, ',', '.'), 2)
,Parsename(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..[NashvilleHousing ]

/* The result indicate seperated columns without commas, also in order to return with accurate value in the column we need to order the object names backward(3,2,1)*/

-- UPDATE COLUMN

alter table  PortfolioProject..[NashvilleHousing ]
add OwnerSplitAddress nvarchar (255);


update PortfolioProject..[NashvilleHousing ]
set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)



alter table  PortfolioProject..[NashvilleHousing ]
add OwnerSplitCity nvarchar (255);

update PortfolioProject..[NashvilleHousing ]
set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

alter table  PortfolioProject..[NashvilleHousing ]
add OwnerSplitState nvarchar (255);

update PortfolioProject..[NashvilleHousing ]
set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

-- CHECK


select *
from PortfolioProject..[NashvilleHousing ]



------------------------------------------------------------------------------------------------

-- Change Y and N to YES and Noin "SOLD as Vacant" field


select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..[NashvilleHousing ]
group by SoldAsVacant


-- SELECT DISTINCT Fucntion = The SELECT DISTINCT statement is used to return only distinct (different) values.

-- Syntax - SELECT DISTINCT column1, column2, ...FROM table_name;



/*Using CASE STATEMENT */




select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..[NashvilleHousing ]

-- CASE STATEMENT = The CASE expression goes through conditions and returns a value when the first condition is met
-- IF CLAUSE



update PortfolioProject..[NashvilleHousing ]
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- CHECK

 
select *
from PortfolioProject..[NashvilleHousing ]



------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Using ROW_NUMBER Statement to run the duplicate value
-- AND Partition by


/* Simply define the duplicate value in the table and we want to get rid of it*/

select *
from PortfolioProject..[NashvilleHousing ]

select *,
ROW_NUMBER  () over (
	Partition BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from PortfolioProject..[NashvilleHousing ]
order by ParcelID


-- Adding CTE to find out the value that have duplicated data 


with RowNumCTE as(
select *,
ROW_NUMBER  () over (
	Partition BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from PortfolioProject..[NashvilleHousing ]
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- Now with new CTE table, we can delete the duplicated data, which has 104 rows by using DELETE Fucntion

with RowNumCTE as(
select *,
ROW_NUMBER  () over (
	Partition BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from PortfolioProject..[NashvilleHousing ]
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num > 1
--order by PropertyAddress


--CHECK

select *
from PortfolioProject..[NashvilleHousing ]



------------------------------------------------------------------------------------------------

-- Delete unused column

select *
from PortfolioProject..[NashvilleHousing ]



Alter table PortfolioProject..[NashvilleHousing ]
drop column OwnerAddress, TaxDistrict, PropertyAddress

