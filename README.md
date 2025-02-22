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
Note that all the code is written in MySQL Workbench.

#### Removing duplicates

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

