@echo off
wmic process where "name='moonshine.exe'" get ExecutablePath /FORMAT:LIST
wmic process where "name='moonshinedevelopment.exe'" get ExecutablePath /FORMAT:LIST