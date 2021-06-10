@ECHO OFF
SETLOCAL EnableDelayedExpansion

:: loop directory and set hash/path object
SET /A x=0
FOR /F "tokens=*" %%i IN ('where /R %cd% *.*') DO (
	SET obj[!x!].path=%%i
	FOR /F "tokens=*" %%G IN ('certutil -hashfile "%%i" SHA1 ^| findstr /V ":"') DO (
		REM CALL :Trim %%G
		REM ECHO G "%%G"
		SET _hash=%%G
	)
	SET obj[!x!].hash=!_hash!
	SET /a x+=1
)

:: get length of complete object of files
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
   ECHO hash = "!obj[%%i].hash!"
)
echo.

:: output all hashes to txt
IF NOT EXIST hashes.txt (
	FOR /L %%p IN (0 1 %A%) DO (
		ECHO !obj[%%p].hash! >> hashes.txt
	)
)

:: output all duplicate hashes to txt
IF NOT EXIST duplicates.txt (
	SET prev=
	FOR /F "tokens=* delims=" %%a IN ('sort hashes.txt') DO (
		IF "%%a"=="!prev!" (
			ECHO %%a >> duplicates.txt
		)
		SET prev=%%a
	)
	IF NOT EXIST duplicates.txt (
		ECHO No duplicates^^!
		GOTO :EOF
	)
)

:: output unique hashes to txt
IF NOT EXIST unq_duplicates.txt (
	FOR /F "tokens=* delims=" %%a IN ('sort duplicates.txt') DO (
		IF NOT "%%a"=="!prev!" (
			ECHO %%a >> unq_duplicates.txt
		)
		SET prev=%%a
	)
)

:: output all paths and shas of duplicate files to console
IF EXIST unq_duplicates.txt (
	FOR /F "tokens=* delims=" %%a IN ('sort unq_duplicates.txt') DO CALL :checkduplicate %%a

	:checkduplicate
	IF "%1" NEQ "" (
		ECHO Duplicate file SHA1: "%1"
		ECHO Paths:
		FOR /L %%r IN (0 1 %A%) DO (
			REM ECHO r: %%r
			IF "!obj[%%r].hash!"=="%1" ECHO !obj[%%r].path!
		)
		SET prev=%1		
		ECHO.
	)
)

:Trim
SetLocal EnableDelayedExpansion
set Params=%*
for /f "tokens=1*" %%a IN ("!Params!") DO EndLocal & SET %1=%%b
exit /b