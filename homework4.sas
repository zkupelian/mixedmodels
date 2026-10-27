/* 1. Load in the data*/
DATA exercise_raw;
SET "C:\Users\zkupelian\Documents\exercise.sas7bdat";
RUN;

* PART 2: Times 0, 4, 8, 12 ;
DATA w4;
SET exercise_raw;
KEEP ID GROUP Y0 Y4 Y8 Y12;
RUN;

/* Make into long format and pick only 0, 4, 8, and 12 */
PROC TRANSPOSE DATA=w4 OUT=l4 NAME=tv;
BY ID GROUP;
VAR Y0 Y4 Y8 Y12;
RUN;

DATA c4;
SET l4;
t = input(substr(tv,2),8.);
y = COL1;
IF NOT MISSING(y);
KEEP ID GROUP t y;
RUN;

/* a. Compound symmetry - AIC of 559.4 */
PROC MIXED DATA=c4 IC;
CLASS ID;
MODEL y=t;
REPEATED/SUBJECT=ID TYPE=CS;
TITLE "A. Compound Symmetry - 0,4,8,12";
ODS OUTPUT FitStatistics=f_cs4;
RUN;

/* b. Heterogenous compound symmetry - AIC of 559.3 */
PROC MIXED DATA=c4 IC;
CLASS ID;
MODEL y=t;
REPEATED/SUBJECT=ID TYPE=CSH;
TITLE "B. Heterogeneous CS - 0,4,8,12";
ODS OUTPUT FitStatistics=f_csh4;
RUN;

/* c. Exponential - AIC of 535.5 */
PROC MIXED DATA=c4 IC;
    CLASS ID;
    MODEL y=t;
    REPEATED / SUBJECT=ID TYPE=AR(1); /* had to look this up*/
    TITLE "C. Autoregressive - 0,4,6,8,10,12";
    ODS OUTPUT FitStatistics=f_ar6;
RUN;

/* d. Heterogeneous autoregressive - AIC of 536.5 */
PROC MIXED DATA=c4 IC;
CLASS ID;
MODEL y=t;
REPEATED/SUBJECT=ID TYPE=ARH(1);
TITLE "D. Heterogeneous AR - 0,4,8,12";
ODS OUTPUT FitStatistics=f_arhe4;
RUN;

/* e. Unstructured - AIC of 543.4*/
PROC MIXED DATA=c4 IC;
CLASS ID;
MODEL y=t;
REPEATED/SUBJECT=ID TYPE=UN;
TITLE "E. Unstructured - 0,4,8,12";
ODS OUTPUT FitStatistics=f_un4;
RUN;

* PART 3: Times 0, 4, 6, 8, 10, 12 ;
DATA w6;
SET exercise_raw;
KEEP ID GROUP Y0 Y4 Y6 Y8 Y10 Y12;
RUN;

/* picking all of them this time */
PROC TRANSPOSE DATA=w6 OUT=l6 NAME=tv;
BY ID GROUP;
VAR Y0 Y4 Y6 Y8 Y10 Y12;
RUN;

/*filtering out the missing data, just like last time*/
DATA c6;
SET l6;
t = input(substr(tv,2),8.);
y = COL1;
IF NOT MISSING(y);
KEEP ID GROUP t y;
RUN;

/*same covariance structures as last time, just with c6 instead*/
PROC MIXED DATA=c6 IC;
CLASS ID;
MODEL y=t;
REPEATED/SUBJECT=ID TYPE=CS;
TITLE "A. Compound Symmetry - 0,4,6,8,10,12";
ODS OUTPUT FitStatistics=f_cs6;
RUN;
/* AIC of 758.4 */

PROC MIXED DATA=c6 IC;
CLASS ID;
MODEL y=t;
REPEATED/SUBJECT=ID TYPE=CSH;
TITLE "B. Heterogeneous CS - 0,4,6,8,10,12";
ODS OUTPUT FitStatistics=f_csh6;
RUN;
/* AIC of 764.1 */


PROC MIXED DATA=c6 IC;
CLASS ID;
MODEL y=t;
REPEATED/SUBJECT=ID TYPE=AR(1);
TITLE "C. Exponential - 0,4,6,8,10,12";
ODS OUTPUT FitStatistics=f_exp6;
RUN;
/* AIC of 733.5 */

PROC MIXED DATA=c6 IC;
CLASS ID;
MODEL y=t;
REPEATED/SUBJECT=ID TYPE=ARH(1);
TITLE "D. Heterogeneous AR - 0,4,6,8,10,12";
ODS OUTPUT FitStatistics=f_arhe6;
RUN;
/* AIC of 739.5 */

PROC MIXED DATA=c6 IC;
CLASS ID;
MODEL y=t;
REPEATED/SUBJECT=ID TYPE=UN;
TITLE "E. Unstructured - 0,4,6,8,10,12";
ODS OUTPUT FitStatistics=f_un6;
RUN;
/* AIC of 745.6 */

/* 4. The result for question 2 has the exponential covariance matrix 
with the smallest AIC, and question 3 sees the same result. AR(1)
is the was the call I could find to represent the exponential covariance
matrix, and resulted in the lowest AICs for both subsets. It's likely
the right choice for both groups because that the underlying correlation
is actually exponential, and occurs in both the 0, 4, 8, 12 and 
0, 4, 6, 8, 10, 12 set. */