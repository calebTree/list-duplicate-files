@echo off
SETLOCAL EnableDelayedExpansion
SET "x = 0" 

FOR /F tokens^=* %%i IN ('where /R %cd% *.*') DO (
	CALL ECHO path = "%%i"
	FOR /F tokens^=* %%G IN ('certutil -hashfile "%%i" SHA1 ^| findstr /V ":"') DO SET _hash=%%G
	SET obj[%x%].hash=!_hash!
	CALL ECHO hash = %%obj[%x%].hash%%
	SET /a "x+=1"
)