-- Exploratory Data Analysis


SELECT * 
FROM layoffs_staging2;


SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoffs_staging2;


SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;


SELECT company,SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT MIN(`date`),MAX(`date`) 
FROM layoffs_staging2;


SELECT industry,SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT country,SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


SELECT YEAR(`date`),SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;


SELECT stage,SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


SELECT company,AVG(percentage_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT substring(`date`,1,7) as month,SUM(total_laid_off)
FROM layoffs_staging2
where substring(`date`,1,7) is not null
GROUP BY month
ORDER BY 1 desc;


WITH rolling_total AS
(SELECT substring(`date`,1,7) as month,SUM(total_laid_off) as total_off
FROM layoffs_staging2
where substring(`date`,1,7) is not null
GROUP BY month
ORDER BY 1 ASC)
SELECT month,total_off,sum(total_off) over (order by month) as rolling_total1
FROM rolling_total;



SELECT company,SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT company,year(`date`),SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company,year(`date`)
ORDER BY 3 DESC;


WITH company_year(company,years,total_laid_off) as
(
SELECT 
    company, YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company , YEAR(`date`)
),company_year_ranks as
(
SELECT *,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off desc) as ranking
from company_year
where years is not null
)
select *
from company_year_ranks
where ranking<=5;