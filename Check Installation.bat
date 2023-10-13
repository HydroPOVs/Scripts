@echo off
setlocal

:: Define ANSI escape codes for colors and reset
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

:: Change the code page to UTF-8
chcp 65001 > nul

set "GREY=%ESC%[90m"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "CYAN=%ESC%[96m"
set "BLUE=%ESC%[94m"
set "RESET=%ESC%[0m"
set "YELLOW=%ESC%[93m"
set "REQUIREMENTS_FILE=requirements.txt"

ping www.google.co.in -n 1 -w 1000 >NUL 2>&1

if errorlevel 1 (
    set IS_ONLINE=0
) else (
    set IS_ONLINE=1
)

ver > os.txt

<os.txt (
  set /P OS_VERSION=
  set OS_VERSION=
  set /P OS_VERSION=
)

del os.txt

if %IS_ONLINE% equ 1 (
    echo %GREY%Network Status:%RESET% %GREEN%• Online%RESET%
) else (
    echo %GREY%Network Status:%RESET% %RED%• Offline%RESET%
)

echo %GREY%OS Version:%RESET% %GREEN%%OS_VERSION%%RESET%

echo.

echo %GREY%► Checking Required Softwares%RESET%
echo.

:: Check for Python installation
echo %GREY%[1/3]%RESET% Checking for Python...
python --version >NUL 2>&1
if %errorlevel% equ 0 (
    echo ✔️ %GREEN%Python is installed.%RESET%
) else (
    echo ❌ %RED%Python is not installed.%RESET%
)

echo.

:: Check for MySQL installation
echo %GREY%[2/3]%RESET% Checking for MySQL...
mysql --version >NUL 2>&1
if %errorlevel% equ 0 (
    echo ✔️ %GREEN%MySQL is installed.%RESET%
) else (
    echo ❌ %RED%MySQL is not installed.%RESET%
)

echo.

:: Check for pip installation
echo %GREY%[3/3]%RESET% Checking for pip...
pip --version >NUL 2>&1
if %errorlevel% equ 0 (
    set IS_PIP_INSTALLED=1
    echo ✔️ %GREEN%pip is installed.%RESET%
) else (
    set IS_PIP_INSTALLED=0
    echo ❌ %RED%pip is not installed.%RESET%
)

echo.

set RAW_PACKAGE_PATH=0

if %IS_PIP_INSTALLED% equ 1 (
    echo %GREY%► Installing Packages%RESET%
    echo.
    echo %GREY%[1/4]%RESET% Getting packages.
    echo.
    if %IS_ONLINE% equ 1 (
        echo %GREY%[2/4]%RESET% Installing Packages from %REQUIREMENTS_FILE%
        echo.
        echo | set /p="%GREY%"
        pip install -r %REQUIREMENTS_FILE%
        echo | set /p="%RESET%"
    ) else (
        set /p "RAW_PACKAGE_PATH=Enter Folder path to install Packages from: %GREY%"
        echo | set /p="%RESET%"
    )
)

if %IS_PIP_INSTALLED% equ 1 (

    if %IS_ONLINE% equ 0 (
        if %RAW_PACKAGE_PATH% neq 0 if exist %RAW_PACKAGE_PATH% (
            echo.
            echo %GREY%[2/4]%RESET% Installing Packages from %CYAN%%RAW_PACKAGE_PATH%%RESET%
            echo.
            echo | set /p="%GREY%"
            pip install --no-index --find-links %RAW_PACKAGE_PATH% -r %REQUIREMENTS_FILE%
            echo | set /p="%RESET%"
        ) else (
            echo %GREY%[2/4]%RESET%❌ %RED%%RAW_PACKAGE_PATH% doesn't exists.%RESET%
        )
    )

    echo.
    echo %GREY%[3/4]%RESET% Verifying Packages Installation
    echo.

    set IS_MODULE_INSTALLED=1

    :: Read the modules from the requirements.txt file and check if they are installed
    for /f "usebackq tokens=*" %%i in (%REQUIREMENTS_FILE%) do (
        :: Extract module and version from the line
        for /f "tokens=1,2 delims==" %%a in ("%%i") do (
            pip show %%a >NUL 2>&1
            if %errorlevel% equ 1 (
                echo %GREY%Module '%%a' is installed.%RESET%
            ) else (
                echo %YELLOW%Module '%%a' is not installed. Installing version '%%b'.%RESET%
                set IS_MODULE_INSTALLED=0
            )
        )
    )
)

if %IS_PIP_INSTALLED% equ 1 (
    if %IS_MODULE_INSTALLED% equ 1 (
        echo.
        echo %GREY%[4/4]%RESET% %GREEN%✔️ Modules Installed Successfully%RESET%
    ) else (
        echo.
        echo %GREY%[4/4]%RESET% %GREEN%❌ Modules Not Installed Properly, Check logs.%RESET%
    )
)

echo.
echo.

echo | set /p="%BLUE%Made with 💖 by @MrHydroCoder%RESET%"

pause > NUL

:: Reset the code page to the default (usually 437)
chcp 437 > nul

endlocal
