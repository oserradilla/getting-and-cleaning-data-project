# A script that does the following:
# 1.- Merges the training and the test sets to create one data set.
# 2.- Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3.- Uses descriptive activity names to name the activities in the data set
# 4.- Appropriately labels the data set with descriptive variable names.
# 5.- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#

if(!dir.exists("UCI HAR Dataset")){
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile="UCI-HAR-dataset.zip", method="curl")
        unzip("UCI-HAR-dataset.zip")
}

# 1.- Merges the training and the test sets to create one data set
x.test <- read.table("./UCI HAR Dataset/test/X_test.txt")
x.train <- read.table("./UCI HAR Dataset/train/X_train.txt")
x <- rbind(x.test, x.train)

# 2.- Extracts only the measurements on the mean and standard deviation for each measurement. 
features <- read.table("./UCI HAR Dataset/features.txt")

mean.std.colNumbers <- grep("*mean*|*std*",features[,2])
extractedMeasurements <- x[,mean.std.colNumbers]
names(extractedMeasurements) <- features[mean.std.colNumbers,2]

# 3.- Uses descriptive activity names to name the activities in the data set
y.test <- read.table("./UCI HAR Dataset/test/y_test.txt")
y.train <- read.table("./UCI HAR Dataset/train/y_train.txt")
y <- rbind(y.test, y.train)
names(y) <- "activity"

activities <- read.table("./UCI HAR Dataset/activity_labels.txt")
y[, 1] = activities[y[, 1], 2]

# 4.- Appropriately labels the data set with descriptive variable names.
subject.test <- read.table('./UCI HAR Dataset/test/subject_test.txt')
subject.train <- read.table('./UCI HAR Dataset/train/subject_train.txt')
subject <- rbind(subject.test, subject.train)
names(subject) <- "subject"

unorderedFf <- cbind(subject,extractedMeasurements,y)
df <- unorderedFf[order(unorderedFf$subject), ]

write.table(df,"4.-cleaned and merged.txt",row.names = FALSE)

# 5.- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#used "activities" and "sub" because activity and subject are dataframe's column names (so can't be repeated)
avg <- aggregate(df,by=list(activities=df$activity,sub=df$subject),mean)
avg <- avg[, !(colnames(avg) %in% c("sub", "activity"))]

write.table(avg,"5.-average.txt",row.names = FALSE)

#groupedDf <- do.call(rbind.data.frame, groupedList)
#avgDf <- colMeans(groupedDf)
