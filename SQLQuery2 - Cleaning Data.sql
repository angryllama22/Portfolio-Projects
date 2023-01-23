--Cleaning data in SQl Queries!!


-- To populate all data: 
Select* 
From PortfolioProject. dbo.[Nashville Housing ]

-- Now standarize the date format and convert: 
Select SaleDateConverted, CONVERT ( date, SaleDate) 
From PortfolioProject. dbo.[Nashville Housing ]

Update PortfolioProject. dbo.[Nashville Housing ]
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE PortfolioProject. dbo.[Nashville Housing ]
Add SaleDateConverted Date;

Update PortfolioProject. dbo.[Nashville Housing ]
SET SaleDateConverted = CONVERT(Date,SaleDate)



-- Populate Property Address Data:
Select *
From PortfolioProject. dbo.[Nashville Housing ]
--Where PropertyAddress is Null 
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject. dbo.[Nashville Housing ] a
join PortfolioProject.dbo.[Nashville Housing ]b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject. dbo.[Nashville Housing ] a
join PortfolioProject.dbo.[Nashville Housing ]b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]


--Breaking out Address into individual columns :

Select PropertyAddress
From PortfolioProject. dbo.[Nashville Housing ] 
--where propertyaddress is null
--on a.ParcelID= b.ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject. dbo.[Nashville Housing ]

-- Here we add new columns for separating the address into the street address and city:
ALTER TABLE PortfolioProject. dbo.[Nashville Housing ]
ADD PropertySplitAddress nvarchar(255);

Update PortfolioProject. dbo.[Nashville Housing ]
Set PropertySplitAddress = substring(PropertyAddress,1, charindex(',', PropertyAddress)-1)
 
ALTER TABLE PortfolioProject. dbo.[Nashville Housing ]
add PropertySplitCity nvarchar (255);

Update PortfolioProject. dbo.[Nashville Housing ]
Set  PropertySplitCity  =substring (PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress))



--Now we see what we have added to the table: 
Select *
From PortfolioProject.dbo.[Nashville Housing ]


-- Separate owner address from one into three different columns and put them in order: 
Select OwnerAddress
From PortfolioProject.dbo.[Nashville Housing ]

Select 
PARSENAME (Replace(OwnerAddress, ',', '.' ), 3)
,PARSENAME (Replace(OwnerAddress, ',', '.' ), 2)
,PARSENAME (Replace(OwnerAddress, ',', '.' ), 1)

From PortfolioProject.dbo.[Nashville Housing ]

--- Give each column a new name:
ALTER TABLE PortfolioProject. dbo.[Nashville Housing ]
ADD OwnerSplitAddress nvarchar(255);

Update PortfolioProject. dbo.[Nashville Housing ]
Set OwnerSplitAddress = PARSENAME (Replace(OwnerAddress, ',', '.' ), 3)
 
ALTER TABLE PortfolioProject. dbo.[Nashville Housing ]
add OwnerSplitCity nvarchar (255);

Update PortfolioProject. dbo.[Nashville Housing ]
Set  OwnerSplitCity  =PARSENAME (Replace(OwnerAddress, ',', '.' ), 2)

ALTER TABLE PortfolioProject. dbo.[Nashville Housing ]
add OwnerSplitState nvarchar (255);

Update PortfolioProject. dbo.[Nashville Housing ]
Set OwnerSplitState =PARSENAME (Replace(OwnerAddress, ',', '.' ), 1)


--Look at table to make sure it was added correctly: 
Select*
From PortfolioProject.dbo.[Nashville Housing ]


--Change Y and N to Yes and NO in "sold as vacant" field

Select Distinct ( SoldAsVacant)
From PortfolioProject.dbo.[Nashville Housing ]

--To find out how many of each you have of each:
Select Distinct ( SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.[Nashville Housing ]
Group by SoldAsVacant
Order by 2


--Change it:
select SoldAsVacant
, Case When SoldAsVacant = 'Y'  then 'Yes'
	   When SoldAsVacant ='N' then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.[Nashville Housing ]

-- Now update the table: 
Update PortfolioProject.dbo.[Nashville Housing ]
Set SoldAsVacant =Case When SoldAsVacant = 'Y'  then 'Yes'
	   When SoldAsVacant ='N' then 'No'
	   Else SoldAsVacant
	   End


--Removing duplicates by writing a CTE:

With RowNumCTE as (
Select*, 
	ROW_NUMBER() Over (
	Partition by ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From PortfolioProject.dbo.[Nashville Housing ]
--order by ParcelID
)

--To show duplicates:
select *
From RowNumCTE
where row_num>1
order by PropertyAddress

--To delete duplicates: 
DELETE
From RowNumCTE
where row_num>1
--order by PropertyAddress


-- Delete unused columns:
Select *
From PortfolioProject.dbo.[Nashville Housing ]

Alter table PortfolioProject.dbo.[Nashville Housing ]
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject.dbo.[Nashville Housing ]
drop column SaleDate