## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


require(plyr)
## load data

features <- read.table('./UCI HAR Dataset/features.txt', colClasses = c("character"))
activity_labels <- read.table('./UCI HAR Dataset/activity_labels.txt', col.names = c("ActivityId", "Activity"))
x_train <- read.table('./UCI HAR Dataset/train/x_train.txt')
y_train <- read.table('./UCI HAR Dataset/train/y_train.txt')
subject_train <- read.table('./UCI HAR Dataset/train/subject_train.txt')
x_test <- read.table('./UCI HAR Dataset/test/x_test.txt')
y_test <- read.table('./UCI HAR Dataset/test/y_test.txt')
subject_test <- read.table('./UCI HAR Dataset/test/subject_test.txt')

## 1. Merges the training and the test sets to create one data set.

training_data <- cbind(cbind(x_train, subject_train), y_train)
test_data <- cbind(cbind(x_test, subject_test), y_test)
merged_data <- rbind(training_data, test_data)
labels <- rbind(rbind(features, c(562, "Subject")), c(563, "ActivityId"))[,2]
names(merged_data) <- labels

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
data_extract <- merged_data[,grepl("mean|std|Subject|ActivityId", names(merged_data))]

## 3. Uses descriptive activity names to name the activities in the data set
data_extract <- join(data_extract, activity_labels, by = "ActivityId", match = "first")
data_extract <- data_extract[,-1]

## 4. Appropriately labels the data set with descriptive activity names.
names(data_extract) <- gsub('Acc',"Acceleration",names(data_extract))
names(data_extract) <- gsub('GyroJerk',"AngularAcceleration",names(data_extract))
names(data_extract) <- gsub('Gyro',"AngularSpeed",names(data_extract))
names(data_extract) <- gsub('Mag',"Magnitude",names(data_extract))
names(data_extract) <- gsub('^t',"TimeDomain.",names(data_extract))
names(data_extract) <- gsub('^f',"FrequencyDomain.",names(data_extract))
names(data_extract) <- gsub('\\.mean',".Mean",names(data_extract))
names(data_extract) <- gsub('\\.std',".StandardDeviation",names(data_extract))
names(data_extract) <- gsub('Freq\\.',"Frequency.",names(data_extract))
names(data_extract) <- gsub('Freq$',"Frequency",names(data_extract))

## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy_data = ddply(data_extract, c("Subject","Activity"), numcolwise(mean))
write.table(tidy_data, file = "./tidy_data.txt", row.names =FALSE)