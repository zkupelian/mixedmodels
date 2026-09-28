LIBNAME mydata "C:\Users\zkupelian\Documents";

/*1. loading in the dataset*/

PROC CONTENTS DATA=mydata.tlc;
RUN;

/*2. selecting just the placebo*/

DATA just_placebo;
	set mydata.tlc;
	WHERE trt="P";
	RUN;

/*3. finding the means and variance of y0, y1, y4, y6*/

PROC UNIVARIATE data=just_placebo;
	var y0 y1 y4 y6;
	RUN;

/*4. finding the covariance matrix of y0, y1, y4, y6*/

PROC CORR data=just_placebo cov;
	var y0 y1 y4 y6;
	RUN;

/*5. Confidence interval*/
/*a. Assuming covariance is 0*/

	/*y0_l=(24.66 - 26.272) - 1.98*sqrt((29.82 + 25.24)/50)*/
	/*-3.6898*/

	/*y0_u = (24.66 - 26.272) + 1.98*sqrt((29.82 + 25.24)/50)*/
	/*0.4657*/

	/* {-3.6898, 0.4658} */

/*b. Covariance from step 4*/

	/*covariance is 22.749*/

	/*(24.66 - 26.272) - 1.98*sqrt(((29.82 + 25.24) - 2*(22.750))/50)*/
	/*-2.478*/

	/*(24.66 - 26.272) + 1.98*sqrt(((29.82 + 25.24) - 2*(22.750))/50)*/
	/*-0.746*/

	/* {-2.478, -0.746} */

/*6. Two sample t test comparing y1 and y0*/

/*Reshape data from wide to long using PROC TRANSPOSE*/
PROC TRANSPOSE DATA=just_placebo OUT=long_placebo NAME=week;
	BY id trt;
	VAR y0 y1;
RUN;

/*Rename the value column to something more meaningful*/
DATA long_placebo;
	SET long_placebo;
	RENAME COL1 = value;
RUN;

/*Check the structure*/
PROC PRINT DATA=long_placebo (OBS=10);
RUN;

/*6. Two-sample t test comparing y1 and y0*/
/*Create numeric week variable: 1=y0, 2=y1*/
DATA long_placebo;
	SET long_placebo;
	IF week = "y0" THEN week_num = 1;
	IF week = "y1" THEN week_num = 2;
RUN;

PROC TTEST data=long_placebo;
	class week_num;
	var value;
RUN;


/*7. Paired t test of change from week 0 to week 1.*/

proc ttest data=just_placebo;
    paired y1*y0;
run;