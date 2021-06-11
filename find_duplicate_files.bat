@ECHO OFF
SETLOCAL EnableDelayedExpansion
ECHO.
ECHO [36mSearching: "%cd%" for duplicate files ...[0m
:: loop directory and set hash/path object
CALL :ProgressMeter 0
SET /A "_size=0"
FOR /F "tokens=*" %%i IN ('where /R %cd% *.*') DO (
	SET "obj[!_size!].path=%%i"
	FOR /F "tokens=*" %%j IN ('certutil -hashfile "%%i" SHA1 ^| findstr /V ":"') DO (
		SET "_hash=%%j"
	)
	SET "obj[!_size!].hash=!_hash!"
	SET /A "_size+=1"
)
SET /A "_size-=1"
REM ECHO.
REM SET obj

CALL :ProgressMeter 20
:: output all hashes to txt
IF NOT EXIST hashes.txt (
	FOR /L %%p IN (0 1 %_size%) DO (
		ECHO !obj[%%p].hash! >> hashes.txt
	)
)

CALL :ProgressMeter 40
:: output all duplicate hashes to txt
IF NOT EXIST duplicates.txt (
	SET "prev="
	FOR /F "tokens=* delims=" %%a IN ('sort hashes.txt') DO (
		IF "%%a"=="!prev!" (
			ECHO %%a >> duplicates.txt
		)
		SET "prev=%%a"
	)
	DEL hashes.txt
	IF NOT EXIST duplicates.txt (
		ECHO No duplicates^^!
		GOTO :EOF
	)
)

CALL :ProgressMeter 60
:: output only unique hashes to txt
IF NOT EXIST unq_duplicates.txt (
	FOR /F "tokens=* delims=" %%a IN ('sort duplicates.txt') DO (
		IF NOT "%%a"=="!prev!" (
			ECHO %%a >> unq_duplicates.txt
			SET /A "_count+=1"
		)
		SET "prev=%%a"
	)
	DEL duplicates.txt
)
(SET LF=^

)

ECHO %_count% duplicates found.
ECHO.
ECHO %_count% duplicates found.!LF! > %userprofile%\Desktop\%_count%_duplicates.txt
ECHO [33mThe SHA1 and file paths are in "%userprofile%\Desktop\%_count%_duplicates.txt".[0m

CALL :ProgressMeter 80
:: output all paths and shas of duplicate files to console
IF EXIST unq_duplicates.txt (
	FOR /F "tokens=*" %%a IN (unq_duplicates.txt) DO (
		CALL :checkduplicate %%a >> %userprofile%\Desktop\%_count%_duplicates.txt
	)
	DEL unq_duplicates.txt
)

:checkduplicate
IF "%1" NEQ "" (
	ECHO Duplicate file SHA1: %1
	ECHO Paths:
	FOR /L %%r IN (0 1 %_size%) DO (
		IF "!obj[%%r].hash!"=="%1" ECHO !obj[%%r].path!
	)
	ECHO.
)

CALL :ProgressMeter 100
EXIT /B

:ProgressMeter
SETLOCAL ENABLEDELAYEDEXPANSION
SET ProgressPercent=%1
SET /A NumBars=%ProgressPercent%/2
SET /A NumSpaces=50-%NumBars%

SET Meter=

FOR /L %%A IN (%NumBars%,-1,1) DO SET Meter=!Meter!I
FOR /L %%A IN (%NumSpaces%,-1,1) DO SET Meter=!Meter!

TITLE Overall Progress:  [%Meter%]  %ProgressPercent%%%
ENDLOCAL
GOTO :EOF
