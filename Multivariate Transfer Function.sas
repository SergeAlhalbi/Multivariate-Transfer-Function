/* Step 1: Importing the data and naming it as "Data" */
proc import file="C:\Users\serge\OneDrive\Desktop\Education\UD\Math Classes\Thesis\Project\Training Data\Training Data.xlsx"
OUT= Data
DBMS=xlsx
REPLACE;
run;
quit;

/* Step 2: Testing if differencing is needed for each series: */
proc arima data=Data;
identify var=y stationarity=(adf=1);
run;
identify var=y stationarity=(pp=1);
run;
quit;
proc arima data=Data;
identify var=y(1) stationarity=(adf=1);
run;
identify var=y(1) stationarity=(pp=1);
run;
quit;
proc arima data=Data;
identify var=x1 stationarity=(adf=1);
run;
identify var=x1 stationarity=(pp=1);
run;
quit;
proc arima data=Data;
identify var=x1(1) stationarity=(adf=1);
run;
identify var=x1(1) stationarity=(pp=1);
run;
quit;
proc arima data=Data;
identify var=x2 stationarity=(adf=1);
run;
identify var=x2 stationarity=(pp=1);
run;
quit;
proc arima data=Data;
identify var=x2(1) stationarity=(adf=1);
run;
identify var=x2(1) stationarity=(pp=1);
run;
quit;


/* Step 3: Estimation for the x1-model; */
proc arima data=Data;
identify var=x1(1) nlag = 30; /* esacf scan minic; Uncomment for Auto-ARIMA */
estimate q=(2) p=(1 6 7 9) noint;
run;
quit;

/* Step 4: Cross-correlation between the pre-whitened x1 and the pre-whitened y; */
proc arima data=Data;
identify var=x1(1) nlag = 30;
estimate q=(2) p=(1 6 7 9) noint;
identify var=y(1) crosscorr=(x1(1)) nlag=30;
run;
quit;

/* Step 5: Preliminary transfer function and diagnostic with input x1: */
proc arima data=Data;
identify var=x1(1) nlag = 30;
estimate q=(2) p=(1 6 7 9) noint;
identify var=y(1) crosscorr=(x1(1)) nlag=30;
estimate input=(0$(1,2)/(2)x1) noint; /* Simple noise */
run;
quit;

/* Step 6: Estimation for the x2-model; */
proc arima data=Data;
identify var=x2(1) nlag = 30; /* esacf scan minic; Uncomment for Auto-ARIMA */
estimate q=(1 3 15 18) p=(1 6) noint;
run;
quit;

/* Step 7: Cross-correlation between the pre-whitened x2 and the pre-whitened y; */
proc arima data=Data;
identify var=x2(1);
estimate q=(1 3 15 18) p=(1 6) noint;
identify var=y(1) crosscorr=(x2(1)) nlag=30;
run;
quit;

/* Step 8: Preliminary transfer function and diagnostic with input x2: */
proc arima data=Data;
identify var=x2(1);
estimate q=(1 3 15 18) p=(1 6) noint;
identify var=y(1) crosscorr=(x2(1)) nlag=30;
estimate input=(0$(0)/(2)x2) noint; /* Simple noise */
run;
quit;

/* Step 9: Diagnostics and modeling the yt's residuals according to the preliminary transfer function's residuals; */
proc arima data=Data;
identify var=x1(1) nlag = 70;
estimate q=(2) p=(1 6 7 9) noint;
identify var=x2(1);
estimate q=(1 3 15 18) p=(1 6) noint;
identify var=y(1) crosscorr=(x1(1) x2(1)) nlag=70;
*estimate input=(0$(1,2)/(2)x1, 0$(0)/(2)x2) noint; /* simple noise */
*estimate q=(2) p=(2) input=(0$(1,2)/(2)x1, 0$(0)/(2)x2) noint; /* Alternative modeled noise model 1 */
*estimate q=(0) p=(3) input=(0$(1,2)/(2)x1, 0$(0)/(2)x2) noint; /* Alternative modeled noise model 2 */
estimate q=(3) p=(0) input=(0$(1,2)/(2)x1, 0$(0)/(2)x2) noint; /* Modeled noise model */
run;
quit;

/* Step 10: Forecasting past and future values, then checking the confidence intervals; */
proc arima data=Data;
identify var=x1(1) nlag = 70;
estimate q=(2) p=(1 6 7 9) noint;
identify var=x2(1);
estimate q=(1 3 15 18) p=(1 6) noint;
identify var=y(1) crosscorr=(x1(1) x2(1)) nlag=70;
estimate input=(0$(1,2)/(2)x1, 0$(0)/(2)x2) noint; /* Simple noise */
estimate q=(3) p=(0) input=(0$(1,2)/(2)x1, 0$(0)/(2)x2) noint; /* Modeled noise model */
outlier type=(ao ls) alpha=0.05 sigma=robust maxnum=10;
forecast lead=62 out=Result alpha=0.01 printall;
run;
quit;
