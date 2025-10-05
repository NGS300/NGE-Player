@echo off
cls
color 04
title Build Tool - v1.4 - Release
timeout /t 1 >nul
echo Wellcome:
hostname
timeout /t 1 >nul
echo Build mode: Windows
cd..
cd..
color 0a
echo Building...
lime test windows
echo Game Has Been Closed.
echo Exiting...
timeout /t 3 /nobreak >nul
exit
@echo on