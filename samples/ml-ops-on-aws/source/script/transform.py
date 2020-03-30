import sys
import pandas as pd
import boto3
import io
from io import StringIO
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv,
                          ['S3_SOURCE',
                           'S3_DEST',
                           'DATA_KEY',
                           'TRAIN_KEY',
                           'TEST_KEY'])

s3_source = args['S3_SOURCE']
s3_dest = args['S3_DEST']
data_key = args['DATA_KEY']
train_key = args['TRAIN_KEY']
test_key = args['TEST_KEY']

#---FUNCTIONS-------------------------------

def write_dataframe_to_csv_on_s3(dataframe, bucket, filename):
    """ Write a dataframe to a CSV on S3 """
    # Create buffer
    csv_buffer = StringIO()
    # Write dataframe to buffer
    dataframe.to_csv(csv_buffer, sep=",")
    # Create S3 object
    s3_resource = boto3.resource("s3")
    # Write buffer to S3 object
    s3_resource.Object(bucket, filename).put(Body=csv_buffer.getvalue())
    print("Writing {} records to {}".format(len(dataframe), filename))

#--------------------------------------------------

s3c = boto3.client('s3')

obj = s3c.get_object(Bucket=s3_source, Key=data_key)

df = pd.read_csv(io.BytesIO(obj['Body'].read()), encoding='utf8')

df = df.set_index('EmployeeNumber')

df['BusinessTravel'].replace(to_replace={'Non-Travel': 0, 'Travel_Rarely':1, 'Travel_Frequently':2}, inplace=True)
df['Gender'].replace(to_replace={'Male': 0, 'Female':1}, inplace=True)
df.replace(to_replace={'No': 0, 'Yes':1}, inplace=True)
df['RatioYearsPerCompany']=df['TotalWorkingYears']/(df['NumCompaniesWorked']+1)

cont_vars=['Age', 'DistanceFromHome',  'MonthlyIncome', 
           'PercentSalaryHike', 'TrainingTimesLastYear', 'RatioYearsPerCompany',
           'YearsAtCompany', 'YearsInCurrentRole', 'YearsSinceLastPromotion', 'YearsWithCurrManager']

ord_vars=['BusinessTravel', 'Education', 'EnvironmentSatisfaction', 'JobInvolvement', 'JobLevel',
          'JobSatisfaction', 'PerformanceRating', 'RelationshipSatisfaction', 'StockOptionLevel', 'WorkLifeBalance']
          
cat_vars=['Department', 'EducationField', 'JobRole', 'MaritalStatus']

bool_vars=['Gender', 'OverTime']

df_dummy=pd.get_dummies(df[cat_vars])
cat_onehot_vars=df_dummy.columns.tolist()
df=df.merge(df_dummy, how='left', left_index=True, right_index=True)

cols = ['Attrition'] + cont_vars + ord_vars + cat_onehot_vars + bool_vars

X=df[cols]
train = X.iloc[:1000]
test = X.iloc[1000:].drop(columns=['Attrition'])

write_dataframe_to_csv_on_s3(train,s3_dest, train_key)

write_dataframe_to_csv_on_s3(test,s3_dest, test_key)

