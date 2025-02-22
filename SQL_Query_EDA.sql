-- Which industry has the highest total layoffs?
SELECT industry, SUM(total_laid_off) AS highest_total_layoff
FROM layoffs_copy1
GROUP BY industry
ORDER BY highest_total_layoff DESC
LIMIT 1;

-- What is the distribution of layoffs across different countries?

SELECT country, SUM(total_laid_off) AS layoff_distribution
FROM layoffs_copy1
GROUP BY country
ORDER BY layoff_distribution DESC;

-- How does the percentage of employees laid off vary by company size (e.g., funds raised or total_laid_off)?

SELECT company, 
       funds_raised_millions, 
       total_laid_off, 
       percentage_laid_off
FROM layoffs_copy
ORDER BY funds_raised_millions DESC, total_laid_off DESC;

-- Is there a correlation between funds raised and the total number of layoffs?

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

SELECT 
        funds_raised_millions,
        total_laid_off,
        AVG(funds_raised_millions) OVER () AS avg_funds,
        AVG(total_laid_off) OVER () AS avg_layoffs
    FROM layoffs_copy1;
    

-- Which locations (cities or regions) have experienced the highest number of layoffs?

SELECT 
	location, 
    SUM(total_laid_off) AS total_layoff
FROM layoffs_copy1
GROUP BY location
ORDER BY total_layoff DESC
;

-- What industries show the highest percentage of workforce layoffs (percentage_laid_off)?

SELECT 
    industry, 
    MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_copy
GROUP BY industry
ORDER BY max_percentage_laid_off DESC;

-- Which companies have the highest funds raised but are still laying off a significant number of employees?

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


