Rem @echo off
Echo Compiling...
Rem Copy %1 %1_%2-preprocessed
..\Tools\EarthC2160.exe -w- -nologo -noresult %3 %4 %1 %1_%2.eco
