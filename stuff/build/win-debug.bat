@echo off
cls
color 04
title Build Tool - v. 1.4

rem Display a welcome message
echo Welcome:
hostname

rem Wait for 1 second
timeout /t 1 >nul

rem Set build mode to Windows (Debug)

rem Navigate two directories up to reach the project folder
cd..
cd..

color 0a
echo Building...

rem Run Lime to test the game in Windows debug mode
lime test windows -debug

echo Game has been closed.
echo Exiting...

rem Wait for 3 seconds before closing
timeout /t 3 /nobreak >nul

rem Pause to keep the window open
pause
exit