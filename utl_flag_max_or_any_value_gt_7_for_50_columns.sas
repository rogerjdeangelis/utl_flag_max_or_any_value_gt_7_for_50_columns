Flag max or any value gt 7 for 50 columns

   Two Solutions
        1. SAS
        2. WPS/PROC R or SAS/IML/R
        
  Benchmarks (no parallelization I have slow ddr2 memory)
  could be cache data I did run twice on each)

   4.77  PROC SQL with data in memory (sasfile)
   6.21  PROC SQL disk
   5.40  MEANS - DATASTEP with sasfile
   6.18  MEANS - DATASTEP (common solution) means(2.75) datastep (3.42)
 * 8.00  R Suprising?


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


*_                     _                          _
| |__   ___ _ __   ___| |__  _ __ ___   __ _ _ __| | _____
| '_ \ / _ \ '_ \ / __| '_ \| '_ ` _ \ / _` | '__| |/ / __|
| |_) |  __/ | | | (__| | | | | | | | | (_| | |  |   <\__ \
|_.__/ \___|_| |_|\___|_| |_|_| |_| |_|\__,_|_|  |_|\_\___/

;

Not scientific

Small data so maybe it does not matter, which algorithm you use.

Not enough data to be conclusive but I
don't have the time for reasonable data (1 billion obs)

I have 8 codes, 64gb , twin 3gz XEONS and slow DDR2 memory.

50 vars 1,000,000 obs
Benchmarks (no parallelization I have slow ddr2 memory)
  could be cache data I did run twice on each)

   4.77  PROC SQL with data in memory (sasfile)
   6.21  PROC SQL disk
   5.40  MEANS - DATASTEP with sasfile
   6.18  MEANS - DATASTEP (common solution) means(2.75) datastep (3.42)
 * 8.00  R Suprising?

 Surprising

I suspect proc sql and your method could be an
order of magnitude faster on the grid(with a billion obs) with
partitioned data.
SQL passthru to exadata or teradata with 500 avaible cores
may be faster than gridded proc means

*          _
 ___  __ _| |
/ __|/ _` | |
\__ \ (_| | |
|___/\__, |_|
        |_|
;

sasfile sd1.have load;

%utlnopts;
%let beg= %sysfunc(time());
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
%utlopts;
%put %sysevalf((%sysfunc(time()) - &beg));

sasfile sd1.have close;

With SASFILE
1511  %put %sysevalf((%sysfunc(time()) - &beg));
SYMBOLGEN:  Macro variable BEG resolves to 43159.9089999198
4.77800011640647

WITHOUT SASFILE
1556  %put %sysevalf((%sysfunc(time()) - &beg));
SYMBOLGEN:  Macro variable BEG resolves to 43285.5659999847
6.2109999657041

*____
|  _ \
| |_) |
|  _ <
|_| \_\

;

%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
have<-read_sas("d:/sd1/have.sas7bdat")[,2:51];
system.time(want<-apply(have,2,function(x) (x==max(x) | x>7) ));
endsubmit;
run;quit;
');

*                                     _       _            _
 _ __ ___   ___  __ _ _ __  ___    __| | __ _| |_ __ _ ___| |_ ___ _ __
| '_ ` _ \ / _ \/ _` | '_ \/ __|  / _` |/ _` | __/ _` / __| __/ _ \ '_ \
| | | | | |  __/ (_| | | | \__ \ | (_| | (_| | || (_| \__ \ ||  __/ |_) |
|_| |_| |_|\___|\__,_|_| |_|___/  \__,_|\__,_|\__\__,_|___/\__\___| .__/
                                                                  |_|
;

sasfile sd1.have load;

%let beg= %sysfunc(time());
proc means noprint data = sd1.have ;
  var v: ;
  output out = vmax (drop=_:) max= / autoname ;
run ;

data want (keep = id bv:) ;
  if _n_ = 1 then set vmax ;
  array vm v: ;
  set have ;
  array v   v1- v&Nvar ;
  array bv bv1-bv&Nvar ;
  do over v ;
    bv = (v = vm or v > 7) ;
  end ;
run ;
%put %sysevalf((%sysfunc(time()) - &beg));

sasfile sd1.have close;


1713  %let beg= %sysfunc(time());
1714  proc means noprint data = sd1.have ;
1715    var v: ;
1716    output out = vmax (drop=_:) max= / autoname ;
1717  run ;

NOTE: There were 1000000 observations read from the data set SD1.HAVE.
NOTE: The data set WORK.VMAX has 1 observations and 50 variables.
NOTE: PROCEDURE MEANS used (Total process time):
      real time           1.75 seconds
      user cpu time       5.52 seconds
      system cpu time     0.04 seconds
      memory              5808.90k
      OS Memory           425128.00k
      Timestamp           02/04/2018 12:49:25 PM
      Step Count                        393  Switch Count  0


1718  data want (keep = id bv:) ;
1719    if _n_ = 1 then set vmax ;
1720    array vm v: ;
1721    set have ;
1722    array v
1722! v1- v&Nvar ;
SYMBOLGEN:  Macro variable NVAR resolves to 50
1723    array bv
1723! bv1-bv&Nvar ;
SYMBOLGEN:  Macro variable NVAR resolves to 50
1724    do over v ;
1725      bv = (v = vm or v > 7) ;
1726    end ;
1727  run ;

NOTE: There were 1 observations read from the data set WORK.VMAX.
NOTE: There were 1000000 observations read from the data set WORK.HAVE.
NOTE: The data set WORK.WANT has 1000000 observations and 51 variables.
NOTE: DATA statement used (Total process time):
      real time           3.63 seconds
      user cpu time       1.57 seconds
      system cpu time     2.05 seconds
      memory              3144.81k
      OS Memory           421792.00k
      Timestamp           02/04/2018 12:49:29 PM
      Step Count                        394  Switch Count  0


SYMBOLGEN:  Macro variable BEG resolves to 46163.6349999904
1728  %put %sysevalf((%sysfunc(time()) - &beg));
5.40199995040166




