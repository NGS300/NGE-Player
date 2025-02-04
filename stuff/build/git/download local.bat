@echo off
cls
title Github Pull - 1.0
timeout /t 1 >nul
echo Wellcome:
hostname
timeout /t 1 >nul
cd..
cd..
cd..
color 0a
timeout /t 1 >nul
title Github Pull - Downloading items
git pull origin main
echo Finished.
timeout /t 3 /nobreak >nul
@echo on