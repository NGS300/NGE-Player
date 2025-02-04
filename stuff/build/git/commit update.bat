@echo off
cls
title Github Commit - 1.0
timeout /t 1 >nul
echo Wellcome:
hostname
timeout /t 1 >nul
cd..
cd..
cd..
git add *
echo git *
color 0a
timeout /t 1 >nul
title Github Commit - Updating items
git commit -m "updated items"
echo Finished.
timeout /t 3 /nobreak >nul
@echo on