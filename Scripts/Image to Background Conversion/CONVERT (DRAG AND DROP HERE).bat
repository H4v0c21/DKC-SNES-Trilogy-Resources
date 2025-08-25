@echo off
setlocal enabledelayedexpansion

echo %~1

::Ensure that a file was dropped onto the script
if "%~1"=="" (
    echo ERROR: No image was dropped. Please drag and drop your indexed .png image file onto this script.
    pause
    exit /b
)

::Set the input path as the dropped file
set "inputFilePath=%~1"

::Get file and folder path
for %%F in ("%inputFilePath%") do (
	set "filename=%%~nF"
	set "folderPath=%%~dpF"
)

::Set current directory to the script itself instead of the dropped file
cd /d "%~dp0"

::Define a suffix to append to the output file directory
set "suffix=_converted"

::Define and create the output directory based on the input file name
set "outputDir=%folderPath%%filename%%suffix%"
mkdir "%outputDir%"

::Make a copy of the input file in the output directory
copy "%inputFilePath%" "%outputDir%\"

::Convert the image to SNES format
superfamiconv -i "%inputFilePath%" -M snes -B 4 -R -p "%outputDir%\palette.bin" -t "%outputDir%\tiledata.bin" -m "%outputDir%\tilemap.bin" --out-tiles-image "%outputDir%\preview_tiledata.png" --out-scaled-image "%outputDir%\preview_output.png"
comp.exe 0 "%outputDir%\compressed_tiledata.bin" "%outputDir%\tiledata.bin"
comp.exe 0 "%outputDir%\compressed_tilemap.bin" "%outputDir%\tilemap.bin"
)