Getting and Cleaning Data Course Project
========================================================
Purpose 
-----------------

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit:

1) a tidy data set as described below, 
2) a link to a Github repository with your script for performing the analysis, and 
3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called `CodeBook.md`

You should also include a `README.md` in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

Analysis files
-----------------
There is only one analysis file in this project: A R script called `run_analysis.R` that does the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Steps of cleaning data - run_analysis.R
-----------------
1. Downloads the raw data and unzips it for cleaning, in case that it was not previously downloaded
        
        if(!dir.exists("UCI HAR Dataset")){
                fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                download.file(fileUrl, destfile="UCI-HAR-dataset.zip", method="curl")
                unzip("UCI-HAR-dataset.zip")
        }
        
2. Reads and merges the training and the test sets to create one data set. Source files: `X_training.txt` and `X_test.txt`. Used command: *rbind*

        x.test <- read.table("./UCI HAR Dataset/test/X_test.txt")
        x.train <- read.table("./UCI HAR Dataset/train/X_train.txt")
        x <- rbind(x.test, x.train)

3. Only select columns that content **mean** or **std** (standard deviation) keywords. This is done by reading the content of the file `features.txt` and getting only the columns of the the dataset obtained in the last step by the numbers obtained by the following command: *grep* (to apply a filter)

        features <- read.table("./UCI HAR Dataset/features.txt")
        mean.std.colNumbers <- grep("*mean*|*std*",features[,2])
        extractedMeasurements <- x[,mean.std.colNumbers]
        names(extractedMeasurements) <- features[mean.std.colNumbers,2]

4. Read activities from the files. To do so, first the training and the test activities must be read from the following source files: `y_train.txt` and `y_test.txt`. Used command: *rbind*. Those files contain only numbers, so now, to obtain the real names, must read the labels that are in the file `activity_labels.txt` and replace the numbers by labels (factor the variable activities).

        y.test <- read.table("./UCI HAR Dataset/test/y_test.txt")
        y.train <- read.table("./UCI HAR Dataset/train/y_train.txt")
        y <- rbind(y.test, y.train)
        names(y) <- "activity"
        
        activities <- read.table("./UCI HAR Dataset/activity_labels.txt")
        y[, 1] = activities[y[, 1], 2]

5. Read the subject content from files `subject_train.txt` and `subject_test.txt` and combine them using the command: *rbind*

        subject.test <- read.table('./UCI HAR Dataset/test/subject_test.txt')
        subject.train <- read.table('./UCI HAR Dataset/train/subject_train.txt')
        subject <- rbind(subject.test, subject.train)
        names(subject) <- "subject"

6. Combine the content of the dataset, activities and subject by using the command *cbind* and write the obtained dataset into a file called `4.-cleaned and merged.txt` by using the command *ŵrite.tables*

        unorderedFf <- cbind(subject,extractedMeasurements,y)
        df <- unorderedFf[order(unorderedFf$subject), ]
        
        write.table(df,"4.-cleaned and merged.txt",row.names = FALSE)

7. Calculate the average of each column of the dataset, grouped by activity and subject. Used command: *aggregate*. To finish, delete the columns that had temporal values used by the function to obtain the final dataset that will be saved in the `5.-average.txt` file by using the command *ŵrite.tables*

        avg <- aggregate(df,by=list(activities=df$activity,sub=df$subject),mean)
        avg <- avg[, !(colnames(avg) %in% c("sub", "activity"))]
        
        write.table(avg,"5.-average.txt",row.names = FALSE)