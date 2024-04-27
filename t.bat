@echo off

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo Node.js is not installed. Please install Node.js to continue.
    echo Download page: https://nodejs.org/en/download
    exit /b 1
)

node t\index.js %*
