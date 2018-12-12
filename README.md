
# Big Data Project: CDC dataset


# Step 1:Clean data
          - Re-categorized “method of disposition” into Burial, Cremation, Others as predictive categories
          - Programmatically selected columns that have many missing values and dropped them in the dataframe
          - Add a column as “year”
          - Dropped all missing value
# Step 2: Descriptive Analysis
# Step 3: Feature selection
          - Filter out redundant features by the result of feature selection 
          - Final choices of 7 features to build predictive models:
              'resident_status', 'education_2003_revision', 'age_recode_12', 'sex', 'month_of_death', 'place_of_death_and_decents_status', 'marital_status'
# Step 4: Prediction Model
          - Multinomial Logistic Regression Model
          - Multi Layer Perceptron Neural Network
          - Decision Tree Model

## Tool: Pyspark; Mainly build on databrick
