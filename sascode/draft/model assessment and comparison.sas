/******************************************************************************
Model Assessment and Comparison:
- The frequency of actual versus predicted events is tabulated for each model.
- ROC curves are plotted to assess the performance of each model in predicting events.
******************************************************************************/

/* Define a reusable function to generate a confusion matrix for each of the models in a loop */
%let models = forest gboost;
%let target = Default;
%macro model_assessment(model, in_data);
    title2 "Model Assessment on Scored Data: &model";
    proc freq data=&in_data.;
       tables &target*I_&target / chisq measures;
    run;
%mend;

/* Loop through each model */
%macro run_model_assessment;
    %do i = 1 %to %sysfunc(countw(&models));
        %let model_name = %scan(&models, &i);
        %put &model_name.;
        %model_assessment(&model_name, &model_name.PREDICTED);
    %end;
%mend;

/* Executes the model_assessment for each model */
%run_model_assessment;

/******************************************************************************
Model Comparison for Tree-Based Models
******************************************************************************/

/* Combine predictions from all the models for ROC plotting */
data roc_data (keep = &target P_&target.1 source);
    set forestPREDICTED (in=_fs) gboostPREDICTED (in=_gb) ;
    if _gb then source = 'Gradient Boost';
    else if _fs then source = 'Forest';
run;

/* Calculates ROC information */
proc assess data = roc_data rocout=roc_data;
    var P_&target.1;
    target &target / event="1" level=nominal;
    by source;
run;

/* Plot ROC curve for all models */
proc sgplot data=roc_data;
    title2 'ROC Curve by Model';
    series x=_FPR_ y=_Sensitivity_ / group=source markers;
    xaxis label='False Positive Rate';
    yaxis label='True Positive Rate';
run;


title "AUC (using validation data)";
proc sql;
  select distinct source, _c_ from roc_data order by _c_ desc;
quit;

proc datasets library=work kill;
run; 