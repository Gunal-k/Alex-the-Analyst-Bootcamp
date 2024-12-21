-- data cleaning

SELECT * 
FROM layoffs;


-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Colums 


# 1. Remove Duplicates
CREATE TABLE layoffs_staging
LIKE layoffs;


SELECT * 
FROM layoffs_staging;


INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;


SELECT *,ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS 
(
SELECT *,ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num>1;


INSERT INTO layoffs_staging2
SELECT *,ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;


DELETE 
FROM layoffs_staging2
WHERE row_num>1;


SELECT * 
FROM layoffs_staging2
WHERE row_num>1;


# 2. Standardize the Data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company= TRIM(company);


SELECT DISTINCT industry
FROM layoffs_staging2 
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto';


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;


SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';


SELECT DISTINCT country,TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(trailing '.' from country);

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date`=STR_TO_DATE(`date`,'%m/%d/%Y')
;


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date;



# 3. Null Values or Blank Values


SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
and percentage_laid_off IS NULL;


SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL OR industry = '';
    

UPDATE layoffs_staging2
SET industry = NULL
where industry = '';


SELECT *
FROM layoffs_staging2
WHERE company like 'Bally%';


SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
    AND t1.location=t2.location
WHERE (t1.industry is NULL OR t1.industry = '')
AND t2.industry is NOT NULL;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
SET t1.industry = t2.industry
WHERE (t1.industry is NULL)
AND t2.industry is NOT NULL;


# 4. Remove Any Colums 


SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
and percentage_laid_off IS NULL;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
and percentage_laid_off IS NULL;


SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


