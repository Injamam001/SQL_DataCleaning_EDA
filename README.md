# World Layoff Data: SQL Cleaning and Exploratory Analysis

## Overview
This project focuses on analyzing global layoff data using SQL. It involves data cleaning, preparation, and exploratory data analysis (EDA) to uncover trends, patterns, and insights related to workforce layoffs across different companies and industries. The project demonstrates how SQL can be used for effective data preprocessing and analysis.

## Objectives
- Data Cleaning: Remove inconsistencies and handle missing values to prepare the data for analysis.
- Data Transformation: Standardize and transform the data to ensure consistency across variables like company names, locations, and dates.
- Insight Generation: Provide actionable insights from the data, such as which companies or industries have been impacted the most by layoffs.
- SQL Querying: Leverage advanced SQL queries to perform data manipulation, aggregation, and analysis efficiently.

## Dataset
You can access and download the dataset used for this project. To access and download the dataset click this [LINK](https://github.com/Injamam001/SQL_DataCleaning_EDA/blob/main/layoffs.csv) 

## Data quality improvement steps
- Remove duplicates
- Standardize the data
- Dealing with null values or blank values
- Delete unnecessary column.

## Data Cleaning with SQL. 
Note that all the code is written in MySQL Workbench. To download sql code file click [HERE](https://github.com/Injamam001/SQL_DataCleaning_EDA/blob/main/SQL_Query_DataCleaning.sql)

### Removing duplicates

```sql
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
```
### Standardizing data
```sql
-- removing leading and trailing spaces

UPDATE layoffs_copy1
SET
  company = TRIM(company),
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
```
### Dealing with null and blank values
```sql
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
```
### Deleting unnecessary columns
```sql
ALTER TABLE layoffs_copy1
DROP COLUMN row_num;
```

## Exploratory Data Analysis (EDA)
To download sql code file click [HERE](https://github.com/Injamam001/SQL_DataCleaning_EDA/blob/main/SQL_Query_EDA.sql)

###  Which industry has the highest total layoffs?
```sql
SELECT industry, SUM(total_laid_off) AS highest_total_layoff
FROM layoffs_copy1
GROUP BY industry
ORDER BY highest_total_layoff DESC
LIMIT 1;
```

### What is the distribution of layoffs across different countries?
```sql
SELECT country, SUM(total_laid_off) AS layoff_distribution
FROM layoffs_copy1
GROUP BY country
ORDER BY layoff_distribution DESC;
```

### How does the percentage of employees laid off vary by company size (e.g., funds raised or total_laid_off)?
```sql
SELECT company, 
       funds_raised_millions, 
       total_laid_off, 
       percentage_laid_off
FROM layoffs_copy
ORDER BY funds_raised_millions DESC, total_laid_off DESC;
```

### Is there a correlation between funds raised and the total number of layoffs?
```sql
SELECT 
    (SUM((funds_raised_millions - avg_funds) * (total_laid_off - avg_layoffs))) / 
    (SQRT(SUM(POW(funds_raised_millions - avg_funds, 2)) * SUM(POW(total_laid_off - avg_layoffs, 2)))) AS correlation_coefficient
FROM 
    (SELECT 
        funds_raised_millions,
        total_laid_off,
        AVG(funds_raised_millions) OVER () AS avg_funds,
        AVG(total_laid_off) OVER () AS avg_layoffs
    FROM layoffs_copy1) AS subquery;
```

### Which locations (cities or regions) have experienced the highest number of layoffs?
```sql
SELECT 
	location, 
   	SUM(total_laid_off) AS total_layoff
FROM layoffs_copy1
GROUP BY location
ORDER BY total_layoff DESC
;
```

### What industries show the highest percentage of workforce layoffs (percentage_laid_off)?
```sql
SELECT 
    industry, 
    MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_copy
GROUP BY industry
ORDER BY max_percentage_laid_off DESC;
```

###  Which companies have the highest funds raised but are still laying off a significant number of employees?
```sql
SELECT 
    company, 
    funds_raised_millions, 
    total_laid_off
FROM 
    layoffs_copy
WHERE 
    total_laid_off > 0
ORDER BY 
    funds_raised_millions DESC, 
    total_laid_off DESC;
```
