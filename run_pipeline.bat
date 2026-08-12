@echo off
echo =========================================
echo Starting MLB Data Pipeline
echo =========================================

:: 1. Navigate to the main project directory
cd /d "C:\Users\bbann\portfolio\MLB Database"

:: 2. Activate your virtual environment
call .venv\Scripts\activate.bat

:: 3. Run Python ingestion scripts
echo [1/3] Running Python extract and load scripts...

echo Executing Statcast Extract...
python extract_load/daily_statcast_extract.py
if %ERRORLEVEL% NEQ 0 (
    echo Statcast extraction failed! Aborting pipeline.
    pause
    exit /b %ERRORLEVEL%
)

echo Executing Statcast Load...
python extract_load/daily_statcast_load.py
if %ERRORLEVEL% NEQ 0 (
    echo Statcast load failed! Aborting pipeline.
    pause
    exit /b %ERRORLEVEL%
)

echo Executing Player Names Extract...
python extract_load/player_names_extract.py
if %ERRORLEVEL% NEQ 0 (
    echo Player names extract failed! Aborting pipeline.
    pause
    exit /b %ERRORLEVEL%
)

:: 4. Navigate to dbt project folder and run models
echo [2/3] Running dbt transformations...
cd transform
dbt build
if %ERRORLEVEL% NEQ 0 (
    echo dbt build failed!
    pause
    exit /b %ERRORLEVEL%
)

echo =========================================
echo Pipeline completed successfully!
echo =========================================
pause