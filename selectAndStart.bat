@echo off
REM Copyright 2025 Mehmet ERGULCU
REM SPDX-License-Identifier: Apache-2.0
REM
REM Lists the folders, starts the chosen one with "docker compose up" and stops it with Ctrl+C.
REM A missing .env is copied from .env.example first.
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "index=0"
for /d %%D in (*) do (
    if exist "%%D\compose.yml" (
        set /a index+=1
        set "folder!index!=%%D"
        echo !index!: %%D
    )
)

set "selection="
set /p selection=Number of the folder to start:
if not defined selection goto invalid
set "selectedFolder=!folder%selection%!"
if not defined selectedFolder goto invalid

cd "%selectedFolder%"
if exist .env.example if not exist .env (
    copy .env.example .env >nul
    echo Created %selectedFolder%\.env from .env.example; change the passwords there if needed.
)
docker compose up
cd ..
endlocal
exit /b 0

:invalid
echo Invalid selection.
endlocal
exit /b 1
