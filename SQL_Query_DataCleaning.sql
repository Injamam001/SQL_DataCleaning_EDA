/*
we will follow the steps below to clean the data:

1. Remove duplicates
2. Standardize the data
3. Null values or blank values
4. Delete unnecessary column. 
*/

-- 1. Remove duplicates
/*
As here in this table, there is no unique id, therefore To remove duplicates
following steps have followed: 
	step - 1: duplicating table so that raw data remains intact.
    step - 2: identifying Duplicate Rows Based on suitable columns Using ROW_NUMBER().
	step - 3: creating anatoher table and inserting Data into that table with Row Numbers for Duplicate Identification.
    step - 4: deleting duplicate rows. 
*/
-- step - 1: duplicating table so that raw data remains intact.
CREATE TABLE layoffs_copy
LIKE layoffs;

INSERT layoffs_copy
SELECT *
FROM layoffs;

-- step - 2: identifying Duplicate Rows Based on suitable columns Using ROW_NUMBER().
SELECT *
FROM (
SELECT *,
	ROW_NUMBER() OVER
		(PARTITION BY company, location, industry, total_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy
) as subquery
WHERE row_num > 1;

-- step - 3: creating another table and inserting data into this with duplicate values. 
-- to do this right click on the table then go to copy to clipboard > Create Statement and paste into editor.

CREATE TABLE `layoffs_copy1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_copy1
SELECT *,
	ROW_NUMBER() OVER
		(PARTITION BY company, location, industry, total_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy;

--  step - 4: deleting duplicate rows. 
DELETE 
FROM layoffs_copy1
WHERE row_num >1;

-- 2. Standardizing data

-- removing leading and trailing spaces

UPDATE layoffs_copy1
SET company = TRIM(company),
	industry = TRIM(industry),
    location = TRIM(location),
    stage = TRIM(stage),
    country = TRIM(country);

-- Term and Spelling Standardization

UPDATE layoffs_copy1
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

UPDATE layoffs_copy1
SET country = 'United States'
WHERE country = 'United States.';

-- standardizing date format

UPDATE layoffs_copy1
SET date = STR_TO_DATE(date,'%m/%d/%Y');

ALTER TABLE layoffs_copy1
MODIFY COLUMN date DATE;

-- dealing with null and blank values

UPDATE layoffs_copy1
SET industry = 'Travel' 
WHERE company LIKE 'Airbnb';

UPDATE layoffs_copy1
SET industry = 'Transportation' 
WHERE company LIKE 'Carvana';

UPDATE layoffs_copy1
SET industry = 'Consumer' 
WHERE company LIKE 'Juul';

DELETE
FROM layoffs_copy1
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
AND funds_raised_millions IS NULL;

DELETE
FROM layoffs_copy1
WHERE total_laid_off IS NULL
AND funds_raised_millions IS NULL;

-- Deleting unnecessary columns

ALTER TABLE layoffs_copy1
DROP COLUMN row_num;





