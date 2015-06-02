@echo off
doskey ll=ls -l
doskey cdr=cd %USERPROFILE%\repositories
doskey cdh=cd %USERPROFILE%
doskey clear=cls
doskey subl="C:\Program Files\Sublime Text 3\sublime_text.exe" $*

SET PATH=%PATH%;C:\Program Files (x86)\NUnit 2.6.3\bin;C:\Python27;C:\Python27\Scripts;C:\Program Files\nodejs
SET PYTHONPATH=%PYTHONPATH%;.