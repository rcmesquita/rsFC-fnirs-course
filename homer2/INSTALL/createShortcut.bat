
@set dirnameSrc=%cd%

@IF EXIST "%userprofile%"\desktop\%2.lnk (del /Q "%userprofile%"\desktop\%2.lnk)

@cscript "%dirnameSrc%"\createShortcut.vbs "%1\%2"

@IF EXIST "%1\%2.lnk" (move "%1\%2.lnk" "%userprofile%"\desktop\%2.lnk)

@echo DONE WITH SHORTCUT %2
