@echo off
echo %1
powershell set-executionpolicy remotesigned
powershell ./dependency.ps1 -slnpath "%1"
"D:\Program Files\Graphviz2.38\bin\dot.exe" -Tpng "%1.txt" > "%1.png"