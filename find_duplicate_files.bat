@echo off
SETLOCAL EnableDelayedExpansion

:: loop directory and set hash and path object
SET /A x=0
FOR /F tokens^=* %%i IN ('where /R %cd% *.*') DO (
	SET obj[!x!].path=%%i
	FOR /F tokens^=* %%G IN ('certutil -hashfile "%%i" SHA1 ^| findstr /V ":"') DO SET _hash=%%G	
	
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

:: output all paths and hashes
FOR /L %%i IN (0 1 %A%) DO (
   call echo path = %%obj[%%i].path%%
   call echo hash = %%obj[%%i].hash%%
)
echo.
FOR /L %%p IN (0 1 %A%) DO (
	FOR /L %%q IN (1 1 %A%) DO (
		IF %%obj[%%p].hash%%==%%obj[%%q].hash%% (
			SET _match=!obj[%%p].hash!
			ECHO Duplicate file SHA1: !_match!
			GOTO :Output
		) ELSE ( 
			ECHO No Matches^^!
			GOTO :EOF
		)
	)
)

:Output
ECHO Paths:
FOR /L %%r IN (0 1 %A%) DO (
	IF !obj[%%r].hash!==!_match! (
		ECHO !obj[%%r].path!
	)
)
ECHO.