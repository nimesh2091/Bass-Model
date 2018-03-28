
/******************************** Bass-Model ********************************/

data sales;
input week sales;
datalines;
0	0
1	160
2	390
3	800
4	995
5	1250
6	1630
7	1750
8	2000
9	2250
10	2500
;
run;

data sales;
set sales;
retain cum_sales 0;
cum_sales_lag = cum_sales;
cum_sales = cum_sales + sales;
cum_sales_sq = cum_sales_lag*cum_sales_lag;
id=1;
run;

proc print data=sales(drop= cum_sales id);
run;

proc model data=sales;
parms b0 b1 b2;
sales=b0+b1*cum_sales_lag+ b2*cum_sales_sq;
fit sales / outest=beta;
run;

proc print data= beta;
run;

data beta1;
set beta;
M = (-b1 -sqrt( (b1*b1)-(4*b0*b2) ))/(2*b2);
p = b0/M;
q = p + b1;
/*Time to reach peak sales t*/
tpeak = (log(q/p))/(p+q);
/*Peak sales S*/
sales_peak = M*((p+q)*(p+q))/(4*q);
id = 1;
run;


data sales_prediction;
merge sales(in=a)
beta1(in=b keep= M p q id);
by id;
if a;
run;

proc sort data=sales_prediction;
by week;
run;

data sales_prediction;
set sales_prediction;
retain cum_sales_pred 0;
cum_sales_lag_pred = cum_sales_pred;
if week = 0 then sales_predicted = 0;
/*else if week = 1 then */
/*	sales_predicted = (p+((q/M)*cum_sales_lag))*(M-cum_sales_lag);*/

else
	sales_predicted = (p+((q/M)*cum_sales_lag_pred))*(M-cum_sales_lag_pred);

cum_sales_pred = cum_sales_pred + sales_predicted;
run;


symbol1 interpol=join
        value=dot;
symbol2 interpol=join
        value=triangle;
legend1 label=none;
TITLE1 "Actual Sales Vs Predicted Sales"; 

proc gplot data=sales_prediction;
plot sales*week sales_predicted*week/ overlay legend=legend1;
run;

  


