-- Data Cleaning
	-- 1. REMOVE DUPLICATE
	-- 2. STANDARDIZE THE VALUES
    -- 3. REMOVE NULL OR BLANK VALUES
    -- 4. REMOVE UNNECESSARY COLUMNS AND ROWS
    
SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

SELECT *
FROM  layoffs_staging;

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH dublicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM dublicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT * 
FROM layoffs_staging2
where row_num > 1;

DELETE  
FROM layoffs_staging2
where row_num > 1;

SELECT *
FROM layoffs_staging2;

-- STANDARDIZING THE DATA
SELECT company , TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry  LIKE 'Crypto%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

SELECT company, industry
FROM layoffs_staging2
WHERE industry = '' OR industry IS NULL;

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

SELECT t1.company t1_company, t1.industry t1_industry, t2.company t2_company, t2.industry t2_industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t2.industry IS NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;	

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


