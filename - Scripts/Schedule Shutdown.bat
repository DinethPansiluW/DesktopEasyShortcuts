@echo off
:: Loop to allow repeated input until exit
:LOOP
:: Step 1: Attempt to cancel any previously scheduled shutdown
shutdown.exe /a >nul 2>&1
if %errorlevel%==0 (
    echo Previous shutdown schedule has been canceled.
) else (
    echo No shutdown was scheduled.
)

:: Step 2: Prompt user for a new target time in HHMM format (e.g., 1530 for 3:30 PM)
set /p target_time="Enter target shutdown time (HHMM): "

:: Step 3: Validate the input format (must be four digits)
if "%target_time%"=="" (
    echo You must provide a time in HHMM format.
    goto LOOP
)

:: Step 4: Ensure the time is valid (HH should be 00-23 and MM should be 00-59)
set /a target_hour=%target_time:~0,2%
set /a target_minute=%target_time:~2,2%

if %target_hour% lss 0 (
    echo Invalid hour. Hours should be between 00 and 23.
    goto LOOP
)

if %target_hour% gtr 23 (
    echo Invalid hour. Hours should be between 00 and 23.
    goto LOOP
)

if %target_minute% lss 0 (
    echo Invalid minute. Minutes should be between 00 and 59.
    goto LOOP
)

if %target_minute% gtr 59 (
    echo Invalid minute. Minutes should be between 00 and 59.
    goto LOOP
)

:: Step 5: Get the current time in HHMM format
for /f "tokens=2 delims==" %%I in ('"wmic OS Get localdatetime /value"') do set datetime=%%I
set current_time=%datetime:~8,4%

:: Step 6: Calculate the time difference in minutes
set /a current_hour=%current_time:~0,2%
set /a current_minute=%current_time:~2,2%
set /a target_total_minutes=(%target_hour% * 60) + %target_minute%
set /a current_total_minutes=(%current_hour% * 60) + %current_minute%

:: Step 7: Ensure that the target time is in the future (if target time is earlier in the day, adjust it)
if %target_total_minutes% lss %current_total_minutes% (
    set /a target_total_minutes+=1440
)

set /a time_diff_minutes=%target_total_minutes% - %current_total_minutes%

:: Convert the time difference to seconds
set /a time_diff_seconds=%time_diff_minutes% * 60

:: Step 8: Ensure the calculated time difference is positive
if %time_diff_seconds% lss 0 (
    echo Target time is in the past. Please set a future time.
    goto LOOP
)

:: Step 9: Create the shutdown.bat file with the calculated time difference in seconds
echo @echo off > shutdown.bat
echo shutdown.exe /s /t %time_diff_seconds% >> shutdown.bat

:: Step 10: Run the shutdown.bat file
call shutdown.bat

:: Step 11: Convert time_diff_seconds to hours and minutes
set /a hours=%time_diff_seconds% / 3600
set /a remaining_minutes=(%time_diff_seconds% %% 3600) / 60

:: Step 12: Calculate the shutdown time in 12-hour format with AM/PM
set /a shutdown_hour=%target_hour%
set /a shutdown_minute=%target_minute%
set AMPM=AM

:: Convert to 12-hour format
if %shutdown_hour% gtr 12 (
    set /a shutdown_hour-=12
    set AMPM=PM
)

:: Display the time in HH:MM AM/PM format
if %shutdown_hour% lss 10 (
    set shutdown_hour=0%shutdown_hour%
)
if %shutdown_minute% lss 10 (
    set shutdown_minute=0%shutdown_minute%
)

echo Shutdown will occur at %shutdown_hour%:%shutdown_minute% %AMPM%.

:: Step 13: Delete the shutdown.bat file after execution
del shutdown.bat

:: Step 14: Ask user if they want to set another time
set /p user_choice="Do you want to set another shutdown time? (Y/N): "
if /i "%user_choice%"=="Y" goto LOOP

exit
