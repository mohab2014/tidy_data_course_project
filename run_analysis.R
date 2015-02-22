library(dplyr) #used when calling %>%, group_by and summarise_each

subject_train <- read.table("train/subject_train.txt")

#change column name from "V1" to "Subject"
names(subject_train)[names(subject_train) == "V1"] <- "Subject"

Y_train <- read.table("train/Y_train.txt")

#change column name from "V1" to "Activity"
names(Y_train)[names(Y_train) == "V1"] <- "Activity"

X_train <- read.table("train/X_train.txt")

train_data <- cbind(subject_train,Y_train,X_train)




subject_test <- read.table("test/subject_test.txt")

#change column name from "V1" to "Subject"
names(subject_test)[names(subject_test) == "V1"] <- "Subject"

Y_test <- read.table("test/Y_test.txt")
#change column name from "V1" to "Activity"
names(Y_test)[names(Y_test) == "V1"] <- "Activity"


X_test <- read.table("test/X_test.txt")

test_data <- cbind(subject_test,Y_test,X_test)

#clean some memory
#rm(X_test,Y_test,subject_test)

#Step1: merge the training and the test sets to create one data set.
train_test_data <- rbind(train_data,test_data)


#Step2: extract only the measurements on the mean and standard deviation for each measurement. 

#load the measurements variables
features <- read.table("features.txt")

#use grep function with fixed=TRUE to find the indices with exact match for "mean()"
extracted_col_indices <- c(grep("mean()",features[,2],fixed=TRUE),grep("std()",features[,2],fixed=TRUE))


#use grep function with fixed=TRUE to find the variables' with names containing exact match for "mean()"
extracted_col_names <- c(grep("mean()",features[,2],fixed=TRUE,value=TRUE),grep("std()",features[,2],fixed=TRUE,value=TRUE))

#c(1,2,extracted_col_indices+2): here 1 refers to the first column "Subject" and 2 refers the 2nd column "Activity"
#extracted_col_indices+2 will let the varibale V_i point to column "i+2", This is because the 1st and 2nd columns are not part of features.txt variables
extracted_data <- train_test_data[,c(1,2,extracted_col_indices+2)]



#Step3: Use descriptive activity names to name the activities in the data set
activity_labels_data <- read.table("activity_labels.txt")

#extract the labels in the 2nd column
activity_labels <- activity_labels_data[,c(2)] 
#change the numbers to their corresponding labels
for (i in 1:6)
  extracted_data$Activity[extracted_data$Activity == i] <- as.character(activity_labels[i]) 

#Step4: Appropriately label the data set with descriptive variable names. 
#make.names replaces the () and - with '.'
extracted_col_names <- make.names(extracted_col_names)

#valid names out of character vectors.
for (i in seq(extracted_col_indices))
  names(extracted_data)[names(extracted_data) == paste("V",as.character(extracted_col_indices[i]), sep="")] <- extracted_col_names[i]

#Step5: Using the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
  
#Use group_by and summarise_each from package "dplyr"
tidy_data <- extracted_data %>% group_by(Subject,Activity) %>% summarise_each(funs(mean))

#write the tidy data into a text file
write.table(tidy_data,file="tidy_data.txt",row.name=FALSE)
