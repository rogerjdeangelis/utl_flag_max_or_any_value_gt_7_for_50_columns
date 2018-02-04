Flag max or any value gt 7 for 50 columns

   Two Solutions
        1. SAS
        2. WPS/PROC R or SAS/IML/R

https://stackoverflow.com/questions/48560769/compare-value-to-max-of-variable

For each line and each variable, I want to know if the value is equal to
the max for this variable or more than or equal to 7.


INPUT  (real data has 50 variables)
===================================

 WORK.HAVE total          + RULES
                          |
    ID    V1    V2    V3  |   V1B      V2B      V2B
                          |
     1     7     7     2  |    0        0        0
     2     9     9     7  |    1 max    1 max    0
     3     5     5     6  |    0        0        0
     4     8     0     8  |    0        0        1 max


PROCESS  (all the code)
=======================

  1. SAS (to tired to set up macros for WPS)

    * SAS/WPS we need a '%do'  in open code;

    proc sql;
      create
          table want as
      select
          id,
          %array(vs,values=1-50)
          %do_over(vs,phrase=%nrstr(v?,(v?=max(v?) or v?>7) as v?b),between=comma)
      from
         sd1.have
    ;quit;

  2. WPS/PROC R or SAS/IML/R (working code ful solution below)

     want<-apply(have,2,function(x) (x==max(x) | x>7) );


OUTPUT
======

    Middle Observation(2 ) of want - Total Obs 4
                              FROM R
     -- NUMERIC --
    ID      N8    2
    V1      N8    4
    V1B     N8    0   V1     N8    0   ok
    V2      N8    1
    V2B     N8    0   V2     N8    0   ok
    V3      N8    0
    V3B     N8    0
    V4      N8    2
    V4B     N8    0
    V5      N8    0
    V5B     N8    0
    V6      N8    4
    V6B     N8    0
    V7      N8    5
    V7B     N8    0
    V8      N8    7
    V8B     N8    0
    V9      N8    4
    V9B     N8    1
    V10     N8    9
    V10B    N8    1

    ...............

    V48     N8    4
    V48B    N8    1  V48    N8    1   ok
    V49     N8    0
    V49B    N8    0
    V50     N8    1  V49    N8    0   ok
    V50B    N8    0  V50    N8    0   ok


*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  retain id;
  call streaminit(1234);
  array vs[50] v1-v50 ;
  do id=1 to 4;
    do idx=1 to 50;
      vs[idx]=int(10*rand('uniform'));
    end;
    output;
  end;
  keep id v:;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

1. SAS
======

proc sql;
  create
      table want as
  select
      id,
      %array(vs,values=1-50)
      %do_over(vs,phrase=%nrstr(v?,(v?=max(v?) or v?>7) as v?b),between=comma)
  from
     have
;quit;



2. WPS/PROC R or SAS/IML/R
==========================

%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
have<-read_sas("d:/sd1/have.sas7bdat")[,2:51];
want<-apply(have,2,function(x) (x==max(x) | x>7) );
endsubmit;
import r=want data=wrk.want;
run;quit;
');
