@echo off
wmic process where "name='moonshine.exe'" get ExecutablePath /FORMAT:LIST