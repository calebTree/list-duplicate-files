@if (@CodeSection == @Batch) @then
@ECHO OFF
SETLOCAL EnableDelayedExpansion
ECHO Counting files ...
CALL :ProgressMeter 0
SET /A "_sizeA=0"
FOR /F "tokens=*" %%i IN ('where /R "%cd%" *.*') DO (
	SET /A "_sizeA+=1"
)
ECHO                                    [41m---WARNING---[0m
ECHO [36mReady to SHA1 hash [47m[30m%_sizeA%[0m[36m files? (y/n)[0m
SET /P "_input=[36mEnter Yes or No:[0m "
IF /I "%_input%"=="y" GOTO :yes
GOTO :EOF

:yes
:: loop directory and set hash/path object
SET /A "_size=0"
CALL :ProgressMeter 10
FOR /F "tokens=*" %%i IN ('where /R "%cd%" *.*') DO (
	CALL :drawProgressBar / !_sizeA!
	SET "obj[!_size!].path=%%i"
	FOR /F "tokens=*" %%j IN ('certutil -hashfile "%%i" SHA1 ^| findstr /V ":"') DO (
		SET "_hash=%%j"
		CALL :drawProgressBar - !_sizeA!
	)
	SET "obj[!_size!].hash=!_hash!"
	SET /A "_size+=1"
	CALL :drawProgressBar \ !_sizeA!
	SET /A "_sizeA-=1"
)
SET /A "_size-=1"
REM ECHO.
REM SET obj
ECHO.
ECHO [36mSearching for duplicates ...[0m
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
	FOR /F "tokens=*" %%a IN ('sort "hashes.txt"') DO (
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
ECHO.
ECHO [31m%_count% duplicates found.[0m
ECHO.
ECHO %_count% duplicates found in "%cd%".!LF! > %userprofile%\Desktop\%_count%_duplicates.txt
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

:pause <ms>
cscript /nologo /e:JScript "%~f0" "%~1"
GOTO :EOF

:drawProgressBar
for /f %%a in ('copy "%~f0" nul /z') do set "pb.cr=%%a"
<nul set /p "=[32mComputing [ %2 ] SHA1 file hashes in: "%cd%". Please Wait [ %1 ] ...!pb.cr![0m"
call :pause 0
GOTO :EOF

@end // end batch / begin JScript hybrid code
WSH.Sleep(WSH.Arguments(0));
