#download the data from http://archive.ics.uci.edu/ml/machine-learning-databases/00240/ and then put the files from the 
#repo in the same directory with the data
#setwd("C:/.....")

#if you have not already installed tidy or dplyr, un-comment out their corresponding install.packages line below
#install.packages("tidyr")
#install.packages("dplyr")
library(dplyr)
library(tidyr)
activity_labels <- read.table("activity_labels.txt",sep = " " )
activity_labels <- rename(activity_labels, activity_id=V1, activity_name=V2)
measurement_labels <- read.table("features.txt",sep = " " )
measurement_labels <- rename(measurement_labels, measurement_id=V1, measurement_name=V2)

#I used a solution from the below stack overflow article because the two spaces
#before the row and the single space before each field was causing issues.
#http://stackoverflow.com/questions/23568981/how-to-read-data-with-different-separators
measurement_test   <- read.table(textConnection(gsub("  ", " ", readLines("test/X_test.txt"))))
measurement_train   <- read.table(textConnection(gsub("  ", " ", readLines("train/X_train.txt"))))

measurement_all <- rbind(measurement_test, measurement_train)
names(measurement_all) <- measurement_labels$measurement_name
measurement_all$my_meas_row_num <- seq.int(nrow(measurement_all))
valid_column_names <- make.names(names=names(measurement_all),unique = TRUE, allow_ = TRUE)
names(measurement_all) <- valid_column_names
measurement_mean_std <- select(measurement_all,matches("mean|std"))
activity_test <- read.table("test/y_test.txt")
activity_train <- read.table("train/y_train.txt")
activity_all <- rbind(activity_test, activity_train)
names(activity_all) <- c("activity_id")
subject_test <- read.table("test/subject_test.txt")
subject_train <- read.table("train/subject_train.txt")
subject_all <- rbind(subject_test, subject_train)
names(subject_all) <- c("subject_id")
bound_data <- cbind(activity_all,subject_all,measurement_mean_std)
merged_data <- merge(activity_labels,bound_data, by.x = "activity_id", by.y = "activity_id", all=TRUE)
grouped_means <- group_by(merged_data,subject_id,activity_id)
summary_groupings <- summarize_each(grouped_means,funs(mean)) 
names(summary_groupings)[-c(1:3)] <- paste("mean_of_", names(summary_groupings)[-c(1:3)],sep = "")
write.table(select(summary_groupings, -activity_name),"output.txt",sep=",", row.names = F)
