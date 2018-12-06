@ECHO OFF

FOR /F "usebackq tokens=1,2 delims==" %%i IN (`wmic os get LocalDateTime /VALUE 2^>NUL`) DO IF '.%%i.'=='.LocalDateTime.' SET ldt=%%j
SET ldt=%ldt:~0,4%%ldt:~4,2%%ldt:~6,2%_%ldt:~8,2%%ldt:~10,2%%ldt:~12,2% 

PERL ev.pl separator="|" header=1 folder=c:\Temp\_documents\Profile7_RetailDWH\extracts\ filemask=*.dat > ev_log_%ldt%.txt
