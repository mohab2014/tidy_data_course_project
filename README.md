# Tidy Data Course Project


### Introduction

The aim of the script `run_analysis.R` is to produce a tidy data set
from the given data sets acquired through experiments that have been
carried out with a group of 30 volunteers. 

Six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) were conducted by
each volunteer wearing a smart phone on the waist. Using its embedded accelerometer and gyroscope, 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz were captured.

The acquired data set has been randomly divided into two sets, one set is called `training data set`
collected from 21 selected persons (70% of the volunteers) and the other set is called `testing data set`
collected from 9 selcted persons (300% of the volunteers).

### Step 1: merge the training and the test sets to create one data set.
The training/testing data sets contains three data sets: `subject_train (subject_test)`, `Y_train (Y_test)` and 
`X_train (X_test)`. In this step, the training and test data sets files are read using `read.table`
function using the file name of each data set as its input.

After reading the data, the name of the first column in `subject_train (subject_test)` 
is changed from `V1` to `Subject`. Also, the name of the first column in `Y_train (Y_test)` 
is changed from `V1` to `Activity`. Then, the training (testing) data sets are merged together using 
the function `cbind(subject_train,Y_train,X_train) (cbind(subject_test,Y_test,X_test))` to form
a new data set called `train_data (test_data)`.

Finally, the `train_data` and `test_data` are merged together to form
a new data set called `train_test_data` using the function `rbind(train_data,test_data)`.


<!-- -->

    subject_train <- read.table("train/subject_train.txt")
    names(subject_train)[names(subject_train) == "V1"] <- "Subject"
    
    Y_train <- read.table("train/Y_train.txt")
    names(Y_train)[names(Y_train) == "V1"] <- "Activity"
    
    X_train <- read.table("train/X_train.txt")
    train_data <- cbind(subject_train,Y_train,X_train)

    subject_test <- read.table("test/subject_test.txt")
    names(subject_test)[names(subject_test) == "V1"] <- "Subject"
    
    Y_test <- read.table("test/Y_test.txt")
    names(Y_test)[names(Y_test) == "V1"] <- "Activity"
    
    X_test <- read.table("test/X_test.txt")
    test_data <- cbind(subject_test,Y_test,X_test)
    
    train_test_data <- rbind(train_data,test_data)


### Step 2: extract only the measurements on the mean and standard deviation for each measurement. 

The measurements variables existing in `features.txt` are loaded into an R object called 
features. The second column of this object contains the names of the 561 measurements. The grep function 
is used with `fixed=TRUE` to find the corresponding indices (or location of) the variables which 
contains `mean()` and `std()` as part of their name at the second column of features. The option `fixed=TRUE`
is used to exclude the variables that contain `meanFreq` or `Mean` as part of their name. Using the grep
function with `value=TRUE` beside `fixed=TRUE` yields the name of the variables.

Using `extracted_dol_indices <- c(grep("mean()",features[,2],fixed=TRUE),grep("std()",features[,2],fixed=TRUE))` yields the extracted
column indices and using `c(grep("mean()",features[,2],fixed=TRUE,value=TRUE),grep("std()",features[,2],fixed=TRUE,value=TRUE))`
yields the extracted column names. Now, `c(1,2,extracted_col_indices+2)` will extract only only the measurements on the mean and standard deviation for each measurement from the `train_data_set` that we merged in Step 1. Note that in  `c(1,2,extracted_col_indices+2)`: the first argument `1` refers to the first column `Subject` and the second argument `2` refers the 2nd column `Activity` and the third argument `extracted_col_indices+2` will let the varibale `Vi` point to column `i+2` and this is because the 1st and 2nd columns (`Subject` and `Activity`) in the merged data `train_test_data` are not part of measurements variables in `features.txt`. 


<!-- -->

    features <- read.table("features.txt")
    
    extracted_col_indices <- c(grep("mean()",features[,2],fixed=TRUE),grep("std()",features[,2],fixed=TRUE))

    extracted_col_names <- c(grep("mean()",features[,2],fixed=TRUE,value=TRUE),grep("std()",features[,2],fixed=TRUE,value=TRUE))

    extracted_data <- train_test_data[,c(1,2,extracted_col_indices+2)]


### Step 3: Use descriptive activity names to name the activities in the data set

The activity labels in `activity_labels.txt` are loaded into an R object
called activity_labels_data. The activity lables are extracted from the
2nd column. the function `as.character` is used to change the class 
from `factor` to `character`. A simple for loop through all the six labels
is performed to change each number to its corresponding activity label.


<!-- -->


    activity_labels_data <- read.table("activity_labels.txt")

    activity_labels <- activity_labels_data[,c(2)] 
    
    for (i in 1:6)
       extracted_data$Activity[extracted_data$Activity == i] <- as.character(activity_labels[i]) 


### Step 4: Appropriately label the data set with descriptive variable names.

The function `make.names` is used to make syntactically valid names out of character vectors. In this step, it replaces the charcters `(`, `)` and `-` 
(that exists in the varble names) to `.` in order to make it a valid name.

<!-- -->

    extracted_col_names <- make.names(extracted_col_names)

    for (i in seq(extracted_col_indices))
       names(extracted_data)[names(extracted_data) == paste("V",as.character(extracted_col_indices[i]), sep="")] <- extracted_col_names[i]



### Step 5: Using the data set in `Step 4`, create a second, independent tidy data set with the average of each variable for each activity and each subject.

Use the functions `group_by` and `summarise_each` from package `dplyr` to create a tidy data set with the average of each variable for each activity and each subject.
The obtained tidy data set called `tidy_data` is then written into a text file called `tidy_data.txt` using the function `write.table` with the option
`row.name=FALSE`.

<!-- -->

    tidy_data <- extracted_data %>% group_by(Subject,Activity) %>% summarise_each(funs(mean))

    write.table(tidy_data,file="tidy_data.txt",row.name=FALSE)
