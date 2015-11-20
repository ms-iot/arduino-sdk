@if "%echo_on%" == "" @echo off
setlocal enableextensions disabledelayedexpansion

:: Parse options
:GETOPTS
 if /I "%~1" == "/?" goto USAGE
 if /I "%~1" == "/Help" goto USAGE
 if /I "%~1" == "/clean" set CLEAN=1
 if /I "%~1" == "/nopack" set NOPACK=1
 shift
if not (%1)==() goto GETOPTS

echo Cleaning outputs
del Microsoft.IoT.SDKFromArduino*.nupkg 2> NUL
rmdir /s /q nupkg 2> NUL

:: if a clean was requested, exit here
if "%CLEAN%"=="1" goto end

echo.
echo Creating nupkg directory structure
md nupkg
md nupkg\build
md nupkg\build\native
md nupkg\build\native\include
md nupkg\build\native\source
md nupkg\build\native\lib

set arduinoSDKSources=..\Arduino\hardware\arduino\avr\cores\arduino
set arduinoLibrarySources=..\Arduino\libraries

if not exist %arduinoSDKSources%\Print.h (
	echo The Arduino sources are not checked out. checking them out
	pushd ..
	git submodule init
	git submodule update
	popd
)

if not exist %arduinoSDKSources%\Print.h (
	echo The Arduino sources could not be checked out
)

echo.
echo Copying files into nuget package structure
copy Microsoft.IoT.SDKFromArduino.nuspec nupkg /y || goto err
copy Microsoft.IoT.SDKFromArduino.targets nupkg\build\native /y || goto err

if exist *.h (copy *.h nupkg\build\native\include /y) || goto err
copy %arduinoSDKSources%\binary.h nupkg\build\native\include /y || goto err
copy %arduinoSDKSources%\Client.h nupkg\build\native\include /y || goto err
copy %arduinoSDKSources%\IPAddress.h nupkg\build\native\include /y || goto err
copy %arduinoSDKSources%\Print.h nupkg\build\native\include /y || goto err
copy %arduinoSDKSources%\Printable.h nupkg\build\native\include /y || goto err
copy %arduinoSDKSources%\Server.h nupkg\build\native\include /y || goto err
copy %arduinoSDKSources%\Stream.h nupkg\build\native\include /y || goto err
copy %arduinoSDKSources%\WCharacter.h nupkg\build\native\include /y || goto err
copy %arduinoSDKSources%\WString.h nupkg\build\native\include /y || goto err
copy %arduinoSDKSources%\Udp.h nupkg\build\native\include /y || goto err
copy %arduinoLibrarySources%\LiquidCrystal\src\LiquidCrystal.h nupkg\build\native\include /y || goto err
copy %arduinoLibrarySources%\Stepper\src\Stepper.h nupkg\build\native\include /y || goto err

if exist *.cpp (copy *.cpp nupkg\build\native\source /y) || goto err
copy %arduinoSDKSources%\IPAddress.cpp nupkg\build\native\source /y || goto err
copy %arduinoSDKSources%\Print.cpp nupkg\build\native\source /y || goto err
copy %arduinoSDKSources%\Stream.cpp nupkg\build\native\source /y || goto err
copy %arduinoSDKSources%\WString.cpp nupkg\build\native\source /y || goto err
copy %arduinoLibrarySources%\LiquidCrystal\src\LiquidCrystal.cpp nupkg\build\native\source /y || goto err
copy %arduinoLibrarySources%\Stepper\src\Stepper.cpp nupkg\build\native\source /y || goto err

copy ..\license.txt nupkg /y || goto err
copy ..\notices.txt nupkg /y || goto err

:: skip packaging step if requested
if "%NOPACK%"=="1" goto end

echo Creating NuGet Package
nuget help > NUL
IF ERRORLEVEL 1 (
    echo Please install nuget.exe from http://nuget.org
    goto err
)
nuget pack nupkg\Microsoft.IoT.SDKFromArduino.nuspec || goto err


:end

echo Success
exit /b 0

:err
  echo Script failed!
  exit /b 1
