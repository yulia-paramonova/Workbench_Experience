/************************************************************************/
/* Explore the data and plot missing values                             */
/************************************************************************/
%let class_inputs    = reason job;
%let interval_inputs = clage clno debtinc loan mortdue value yoj derog delinq ninq;
%let target          = bad;
%let outdir = /workspaces/myfolder/Workbench_Experience/Demo_AWS_S3/sas9_code;

%let im_class_inputs    = reason job;
%let im_interval_inputs = im_clage im_clno im_debtinc im_loan im_mortdue im_value im_yoj im_ninq im_derog im_delinq;
%let cluster_inputs     = im_clage im_debtinc value;

proc import datafile="&outdir/hmeq.csv" dbms=csv out=work.hmeq replace;

proc cardinality data=work.hmeq outcard=work.data_card;
run;

proc print data=work.data_card(where=(_nmiss_>0));
  title "Data Summary";
run;

data data_missing;
  set work.data_card (where=(_nmiss_>0) keep=_varname_ _nmiss_ _nobs_);
  _percentmiss_ = (_nmiss_/_nobs_)*100;
  label _percentmiss_ = 'Percent Missing';
run;

proc sgplot data=data_missing;
  title "Percentage of Missing Values";
  vbar _varname_ / response=_percentmiss_ datalabel categoryorder=respdesc;
run;
title;

/************************************************************************/
/* Impute missing values                                                */
/************************************************************************/
proc varimpute data=work.hmeq;
  input clage /ctech=mean;
  input delinq /ctech=median;
  input clno /ctech=median;
  input loan /ctech=median;
  input mortdue /ctech=median;
  input value /ctech=median;
  input derog /ctech=median;
  input ninq /ctech=random;
  input debtinc yoj /ctech=value cvalues=50,100;
  output out=work.hmeq_prepped copyvars=(_ALL_);
run;

proc print data=work.hmeq_prepped(obs=5);
run;

/************************************************************************/
/* Identify variables that explain variance in the target               */
/************************************************************************/
/* Discriminant analysis for class target */
proc varreduce data=work.hmeq_prepped technique=discriminantanalysis;
  class &target &im_class_inputs.;
  reduce supervised &target=&im_class_inputs. &im_interval_inputs. / maxeffects=8;
  ods output selectionsummary=summary;
run;

data out_iter (keep=Iteration VarExp Base Increment Parameter);
  set summary;
  Increment=dif(VarExp);
  if Increment=. then Increment=0;
  Base=VarExp - Increment;
run;

proc transpose data=out_iter out=out_iter_trans;
  by Iteration VarExp Parameter;
run;

proc sort data=out_iter_trans;
  label _NAME_='Group';
  by _NAME_;
run;

/* Variance explained by Iteration plot */
proc sgplot data=out_iter_trans;
  title "Variance Explained by Iteration";
  yaxis label="Variance Explained";
  vbar Iteration / response=COL1 group=_NAME_;
run;
title;


/************************************************************************/
/* Perform a cluster analysis based on demographic inputs               */
/************************************************************************/
proc kclus data=work.hmeq_prepped standardize=std distance=euclidean maxclusters=6;
  input &cluster_inputs. / level=interval;
run;


/************************************************************************/
/* Perform a principal components analysis on the interval valued       */
/* input variables                                                      */
/************************************************************************/
proc pca data=work.hmeq_prepped plots=(scree);
  var &im_interval_inputs;
run;