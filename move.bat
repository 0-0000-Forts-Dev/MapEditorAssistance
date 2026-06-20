@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ========== Configuration ==========
set "AppID=410900"
set "ModSubPath=data\mods\MapEditorAssistance"
:: ===================================

:: Get script directory and name, strip trailing backslash to fix robocopy quote bug
set "ScriptDir=%~dp0"
if "!ScriptDir:~-1!"=="\" set "ScriptDir=!ScriptDir:~0,-1!"
set "ScriptName=%~nx0"
set "GamePath="

echo Move Map Editor Assistance to Forts Local Mods Folder...

:: Read Steam installation path from registry
for /f "tokens=2,*" %%i in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul') do set "SteamPath=%%j"

if not defined SteamPath (
    echo ERROR: Steam installation not found in registry.
    echo Deployment failed.
    goto :end
)

echo Steam installation detected: !SteamPath!
echo Scanning Steam libraries for Forts...

:: Parse Steam library configuration
set "LibraryFile=!SteamPath!\config\libraryfolders.vdf"

if not exist "!LibraryFile!" (
    echo ERROR: Steam library configuration file not found.
    echo Deployment failed.
    goto :end
)

:: Iterate all library folders to locate Forts
for /f tokens^=4^ delims^=^" %%p in ('type "!LibraryFile!" ^| findstr /i /c:"\"path\""') do (
    set "LibPath=%%p"
    set "LibPath=!LibPath:\\=\!"
    set "Manifest=!LibPath!\steamapps\appmanifest_%AppID%.acf"

    if exist "!Manifest!" (
        for /f tokens^=4^ delims^=^" %%a in ('type "!Manifest!" ^| findstr /i /c:"\"installdir\""') do (
            set "GamePath=!LibPath!\steamapps\common\%%a"
            goto :game_found
        )
    )
)

:: Game not found - exit directly
echo.
echo ERROR: Forts installation not found in any Steam library.
echo Deployment failed.
goto :end

:game_found
echo.
echo Game directory located: !GamePath!

:: Build target directory path
set "TargetDir=!GamePath!\%ModSubPath%"
echo Target directory: !TargetDir!
echo.

:: ---------- Pre-check: abort if target has existing files ----------
if exist "!TargetDir!" (
    echo Target directory already exists. Checking for existing files...
    :: Scan all files recursively; returns 0 if any file exists
    dir /s /b /a-d "!TargetDir!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo ERROR: Target directory contains existing files.
        echo Deployment aborted to prevent overwriting existing content.
        goto :end
    )
    echo Target directory is empty. Proceeding with deployment.
) else (
    echo Target directory does not exist. Creating directory...
    md "!TargetDir!"
    echo Directory created successfully.
)
:: -------------------------------------------------------------------

echo.
echo Copying files (script file excluded)...
echo Source: !ScriptDir!
echo.

:: Robocopy execution
:: /E = copy all subdirectories including empty ones
:: /XF = exclude this batch file itself
:: /IS = overwrite same files (safe here as target is empty/new)
:: /NFL /NDL /NJH /NJS = minimal output
robocopy "!ScriptDir!" "!TargetDir!" /E /XF "!ScriptName!" /IS /NFL /NDL /NJH /NJS

set "ExitCode=%errorlevel%"
echo.

if %ExitCode% lss 8 (
    echo SUCCESS: Mod files deployed successfully.
) else (
    echo ERROR: Copy operation failed with exit code %ExitCode%
    echo Please check file permissions and ensure no files are locked.
)

:end
echo.
pause
endlocal
exit /b
