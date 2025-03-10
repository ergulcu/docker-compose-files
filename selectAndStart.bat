@echo off
setlocal enabledelayedexpansion

REM Initialize variables
set "index=1"
set "selection="
set "folders="

REM List all subfolders
for /d %%D in (*) do (
    echo !index!: %%D
    set "folders=!folders!%%D|"
    set /a index+=1
)

REM Prompt user for selection
set /p selection=Please enter the number corresponding to the desired folder: 

REM Validate selection
set "selectedFolder="
for /f "tokens=%selection% delims=|" %%F in ("!folders!") do set "selectedFolder=%%F"

if not defined selectedFolder (
    echo Invalid selection. Exiting.
    exit /b 1
)

REM Change to the selected directory
cd "%selectedFolder%"

REM Check if compose.yml exists
if not exist compose.yml (
    echo compose.yml not found in %selectedFolder%. Exiting.
    exit /b 1
)

REM Run docker-compose
docker compose up

REM Return to the original directory
cd ..
endlocal
