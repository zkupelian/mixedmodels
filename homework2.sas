data tlc;
    set "C:\Users\zkupelian\Documents\tlc.sas7bdat";
run;

/* Subset to placebo group only */
data tlc_placebo;
    set tlc;
    where trt = "P";
run;

/* Transpose from wide to long format for processing*/
proc transpose data = tlc_placebo 
    out = tlclong2 (rename = (_name_ = time COL1 = y));
    by id trt;
    var y0 y1 y4 y6;  /* Adjust variable names to match your data */
run;

/* Optional: Clean up the time variable if needed */
data tlclong2;
    set tlclong2;
    time = input(substr(time, 2), 8.);  /* Removes 'y' prefix and converts to numeric */
run;

/* Question 3: Incorrect General Linear Model */
proc mixed data = tlclong2 method=ml;
    class id time;
    model y = time / s;
run;

/* Question 4: Correct Generalized Linear Model */
proc mixed data = tlclong2 method=ml;
    class id time;
    model y = time / s;
    repeated / type=un subject=id R Rcorr;
run;

/* Question 5. I've written in the R script.*/

/* Question 6. */

proc transpose data = tlc 
    out = tlclonger (rename = (_name_ = time COL1 = y));
    by id trt;
    var y0 y1 y4 y6;  /* Adjust variable names to match your data */
run;

/*Question 7. Fit a model to the whole dataset*/

proc mixed data = tlclonger method=ml;
    class id time trt;
    model y = time trt time*trt / s;
    repeated / type=un subject=id R Rcorr;
run;

/* Hey look at that! Significance! Now to assess the relationship over time.*/

/* 1. Get the parameter estimates from the interaction model */
proc mixed data = tlclonger method=ml;
    class id time trt;
    model y = time trt time*trt / s solution cl;
    repeated / type=un subject=id R Rcorr;
run;

/* The SOLUTION option prints the parameter estimates (coefficients)
   The CL option gives confidence limits */

/* 2. Get predicted means for each group at each time point */
proc mixed data = tlclonger method=ml;
    class id time trt;
    model y = time trt time*trt;
    repeated / type=un subject=id;
    /* Create output dataset with predicted values */
    ods output SolutionF = estimates;
run;

/* 3. Visualize - use PROC SGPLOT for a line plot */
proc sort data = tlclonger;
    by time trt;
run;

proc means data = tlclonger mean;
    class time trt;
    var y;
    output out = means_by_group mean = mean_y;
run;

/* Visualize the trajectories */
proc sgplot data = means_by_group;
    series x = time y = mean_y / group = trt markers lineattrs = (thickness = 2);
    title "Response Profiles by Treatment Group";
    xaxis label = "Time Point";
    yaxis label = "Mean Response";
run;