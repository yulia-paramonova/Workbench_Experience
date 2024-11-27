To successfully connect to AWS:
1) Ensure that you have access to the SAS owned AWS account, available at: https://sasinst.awsapps.com/start/#/?tab=accounts , note: if you do not have access, follow these instructions: https://gitlab.sas.com/GEL/workshops/PSGEL289-sas-viya-4-data-management-on-amazon-web-services/-/blob/main/01_Introduction/01_011_Starting_Workshop_Environment.md?ref_type=heads 

2) Navigate to the IAM

3) Under Users, create a new user

4) As username provide your SAS Username

5) Attach the AdministratorAccess Policy

6) Create the user

7) Navigate to its security credentials 

8) Create an Access Key

9) Copy both the AWS Access key ID and the secret

10) You are now set to use both aws_python.ipynb and aws_python.sasnb