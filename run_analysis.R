Code to Run Analysis
#Download the file and put the file in the data folder
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

unzip(zipfile="./data/Dataset.zip",exdir="./data")

## Unzipped files are in the folder UCI HAR Dataset. Get the list of the files

pathref <- file.path ("./data", "UCI HAR Dataset")
files<-list.files(pathref, recursive=TRUE)
files

#Read the TEST AND TRAIN Activity files

dataActivitytest <- read.table(file.path(pathref, "test", "y_test.txt"), header = FALSE)
dataActivitytrain <- read.table(file.path(pathref, "train", "y_train.txt"), header = FALSE)

#Read the TEST AND TRAIN Subject files

dataSubjecttest <- read.table(file.path(pathref, "test", "subject_test.txt"), header = FALSE)
dataSubjecttrain <- read.table(file.path(pathref, "train", "subject_train.txt"), header = FALSE)

#Read the TEST AND TRAIN Feature files

dataFeaturetest <- read.table(file.path(pathref, "test", "X_test.txt"), header = FALSE)
dataFeaturetrain <- read.table(file.path(pathref, "train", "X_train.txt"), header = FALSE)

#Read Feature Names
dataFeaturenames <- read.table(file.path(pathref, "features.txt"),header=FALSE)

#Merge the training and the test sets to create one data set

#rbind observations ot training and test

dataSubject <- rbind(dataSubjecttrain, dataSubjecttest)
dataActivity<- rbind(dataActivitytrain, dataActivitytest)
dataFeatures<- rbind(dataFeaturetrain, dataFeaturetest)

#Make variables more meaningful with column names "subject" and "activity"
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
names(dataFeatures)<- dataFeaturenames$V2

#Merge Columns and get single data frame

dataCombine <- cbind(dataFeatures, dataSubject, dataActivity)

#Extract only the measurements on the mean and standard deviation for each measurement
#1. Subset Names of Features with "mean()" or "std()"
subdataFeaturenames<-dataFeaturenames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturenames$V2)]

#2 
selectedNames<-c(as.character(subdataFeaturenames), "subject", "activity" )
dataCombine<-subset(dataCombine,select=selectedNames)

#Appropriately label the data set with descriptive variable names
names(dataCombine)<-gsub("^t", "time", names(dataCombine))
names(dataCombine)<-gsub("^f", "frequency", names(dataCombine))
names(dataCombine)<-gsub("Acc", "Accelerometer", names(dataCombine))
names(dataCombine)<-gsub("Gyro", "Gyroscope", names(dataCombine))
names(dataCombine)<-gsub("Mag", "Magnitude", names(dataCombine))
names(dataCombine)<-gsub("BodyBody", "Body", names(dataCombine))

library(plyr);
Data<-aggregate(. ~subject + activity, dataCombine, mean)
Data<-Data[order(Data$subject,Data$activity),]
write.table(Data, file = "tidydata.xls",row.name=FALSE)

