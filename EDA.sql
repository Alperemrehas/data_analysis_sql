-- Exploatary Data Analysis

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY industry
ORDER BY 2 desc;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT company, total_laid_off, MAX(percentage_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, total_laid_off
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`,1,7) AS Month_Year, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY Month_Year
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS Month_Year, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY Month_Year
ORDER BY 1 ASC
)
SELECT Month_Year, total_off, SUM(total_off) OVER(ORDER BY Month_Year)
FROM Rolling_Total;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


 