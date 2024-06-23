@echo off
setlocal enabledelayedexpansion

:: Define a list of directories
set "dirs[0]=C:\Users\chris\Documents\DEEButil"
set "dirs[1]=C:\Users\chris\Documents\DEEBpath"
set "dirs[2]=C:\Users\chris\Documents\DEEBcmd"
set "dirs[3]=C:\Users\chris\Documents\DEEBesti"
set "dirs[4]=C:\Users\chris\Documents\DEEBdata"
set "dirs[5]=C:\Users\chris\Documents\DEEBeval"
set "dirs[6]=C:\Users\chris\Documents\DEEBplots"
set "dirs[7]=C:\Users\chris\Documents\DEEBtrajs"
set "dirs[8]=C:\Users\chris\Documents\DEEBextras"
set "dirs[9]=C:\Users\chris\Documents\DEEB_jl"
:: Add more directories as needed

:: Get the number of directories
set "count=9"

:: Iterate through each directory and perform git pull
for /L %%i in (0,1,%count%) do (
    set "dir=!dirs[%%i]!"
    echo Pulling in directory: !dir!
    pushd !dir!
    git pull
    popd
)

echo All git pull operations completed.
pause
