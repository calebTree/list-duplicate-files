@echo off 

for /f tokens^=* %%i in ('where /R %cd% *.*')do certutil -hashfile "%%~i" SHA1