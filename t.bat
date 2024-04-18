@echo off

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo Node.js is not installed. Please install Node.js to continue.
    echo Official page: https://nodejs.org/
    echo Ask chatgpt on how to install it on your system smth
    exit /b 1
)

node t\index.js %*
