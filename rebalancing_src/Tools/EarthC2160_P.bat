@echo off
set DEL_PARAM=
if "%OS%" == "Windows_NT" set DEL_PARAM=/F
Echo Compiling...
Rem cl.exe is a compiler from VC++, you can replace it with cpp from gcc
cl.exe /nologo /E %CL_PARAM% %1 > %1-preprocessed
Rem \Games\Earth2160_SDK\Tools\gcc\bin\cpp.exe %1 > %1-preprocessed
if not errorlevel 1 \Games\Earth2160_SDK\Tools\EarthC2160.exe -w- -nologo -noresult %3 %4 %1-preprocessed %2
del %DEL_PARAM% %1-preprocessed
