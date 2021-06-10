@echo off
SETLOCAL EnableDelayedExpansion

:: loop directory and set hash and path object
SET /A x=0
FOR /F "tokens=*" %%i IN ('where /R %cd% *.*') DO (
	SET obj[!x!].path=%%i
	FOR /F tokens^=^* %%G IN ('certutil -hashfile "%%i" SHA1 ^| findstr /V ":"') DO (
		::CALL :Trim %%G
		SET _hash=%%G
	)
	SET obj[!x!].hash=!_hash!
	SET /a x+=1
)

:: get length of object of files
set /a A=0
:SymLoop
if defined obj[%A%].hash (
   set /a "A+=1"
   GOTO :SymLoop 
)
SET /a A-=1

:: output all paths and hashes to console
FOR /L %%i IN (0 1 %A%) DO (
   ECHO path = !obj[%%i].path!
   ECHO hash = !obj[%%i].hash!
)
echo.

:: output hashes to txt
IF NOT EXIST hashes.txt (
	FOR /L %%p IN (0 1 %A%) DO (
		ECHO !obj[%%p].hash! >> hashes.txt
	)
)

SET prev=
FOR /f "tokens=* delims=" %%a in ('sort hashes.txt') DO CALL :unique %%a

:unique
IF "%1"=="%prev%" (
	ECHO Duplicate: %1
	FOR /L %%r IN (0 1 %A%) DO (
		IF "!obj[%%r].hash!"=="%1" ECHO !obj[%%r].path! 
	)
)
SET prev=%1
GOTO :EOF

:Trim
SetLocal EnableDelayedExpansion
set Params=%*
for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
exit /b