#Class: Week 06
#Course: Big Data and Social Analysis
#Semester: Spring 2023
#Lesson: Loop and Advanced Dataframe Manipulation
#Instructor: Chung-pei Pien
#Organization: ICI, NCCU

### Student Information --------

#Chinese Name: 嘉博
#English First Name:Jasper
#UID: 111926019 
#E-mail: jasper.hewitt@me.com 

### Questions --------


#In this week's class, you utilized loop to create ntc_ref_2018.

#Download ntc_2021.zip and extract it into your working directory.
setwd("/Users/jasperhewitt/Desktop/big data & social analysis/code/datasets")


#These files contain the results of New Taipei City's 2021 pro-nuclear power referendum (Case 17) at the li level.
#The content of these files differs from 17_65000.json, as they have been cleaned.
#The two referendums had notably different outcomes: the pro-nuclear side won in 2018 but lost in 2021.
#We are interested in examining the differences between the two referendums at both the district and li levels.
#Please answer the following questions. Remember, No Comments, No Points!!!!!!!

#_______________________________________________________________________________________________________
#Question 1: (10 points) Use loop function to rbind all districts’ 2021 election results into ntc_ref_2021

#list all the files from ntc_2021
ntc_2021_list<-list.files('ntc_2021')
ntc_2021_list[1]

#create an empty data frame called ntc_ref_2021
ntc_ref_2021<- data.frame() #empty dataframe

#read every item in the ntc_2021_list[i] (total 29) and store it in the temp_df variable
#rbind temp_df to ntc_ref_2021. 
#note that the values in temp_df will be overwritten in the next iteration of the loop. 
for (i in 1:29){
  temp_df<-read.csv(paste("ntc_2021/",ntc_2021_list[i], sep=""))
  ntc_ref_2021<-rbind(ntc_ref_2021, temp_df)
}
ntc_ref_2021 #1032 obs. of 8 variables

#_______________________________________________________________________________________________________
#Question 2: (3 points) Merge ntc_ref_2018 and ntc_ref_2021 into ntc_ref

#step 1: do the same for 2018 
library(dplyr)
ntc_2018_list<-list.files('ntc_2018')
ntc_2018_list[1]

ntc_ref_2018<- data.frame() 
for (i in 1:29){
  temp_df<-read.csv(paste("ntc_2018/",ntc_2018_list[i], sep=""))
  ntc_ref_2018<-rbind(ntc_ref_2018, temp_df)
}

#step 2: delete excess columns from ntc_ref_2018 (because this is a comparison I will only take the 
#columns that are also in ntc_ref_2021)
#see columns ntc_ref_2021
colnames(ntc_ref_2021)

#only select relevant comlumns in ntc_ref_2018
ntc_ref_2018 <- ntc_ref_2018[c("district","li_id", "rf_16_yea", "rf_16_nay", "rf_16_valid_vote",
                               "rf_16_invalid_vote", "rf_16_turnout", "rf_16_num_voter")]

#step3: merge the two columns together on li_id and drop the duplicate district.y column 
ntc_ref <-merge(ntc_ref_2018, ntc_ref_2021, by='li_id')
ntc_ref <- subset(ntc_ref, select = -district.y)

#_______________________________________________________________________________________________________
#Question 3: (3 points) Using dplyr's mutate to calculate every li's yea rate in 2018 and 2021 (number of yea / number of valid vote)

#create a new column yea_rate_2018 that divides the 2018 number of yeas by the valid votes in 2018
ntc_ref <- ntc_ref %>% 
  mutate(yea_rate_2018 = rf_16_yea/rf_16_valid_vote)

#do the same for 2021
ntc_ref <- ntc_ref %>% 
  mutate(yea_rate_2021 = rf_17_yea/rf_17_valid_vote)

#_______________________________________________________________________________________________________
#Question 4: (2 points) Which li's yea rate has largest decrease? (Give me the li_id)
#calculate the difference between yea_rate in 2018 and 2021.
ntc_ref <- ntc_ref %>% 
  mutate(yea_change = yea_rate_2021 - yea_rate_2018)

#sort the df in an ascending order to find the biggest decrease (this will show the row with the biggest minus value first)
ntc_ref_sortdecrease <- ntc_ref[order(ntc_ref$yea_change, decreasing =FALSE),]
#show first row with head
head(ntc_ref_sortdecrease, 1) #li_id = 6500600-021, decrease = -0.379371

#_______________________________________________________________________________________________________
#Question 5: (2 points) Which li's yea rate has largest increase? (Give me the li_id)

#sort the df descending based on the yea_change column. So showing the highest value first  
ntc_ref_sortincrease <- ntc_ref[order(ntc_ref$yea_change, decreasing =TRUE),] 
#show first row with head()
head(ntc_ref_sortincrease, 1) #li_id:6500400-010, increase = +0.2155448


#_______________________________________________________________________________________________________
#Question 6: (6 points) Using dplyr's group_by() and summarise() to calculate every district's yea rate
#group_by district, use summarize to divide the sum of 2018 yeas per district by the sum of 2018 valid votes
district_yea_rate_2018<-ntc_ref%>%
  group_by(district.x)%>%
  summarise(district_yea_2018=sum(rf_16_yea) / sum(rf_16_valid_vote))

#now do the same for 2021
district_yea_rate_2021<-ntc_ref%>%
  group_by(district.x)%>%
  summarise(district_yea_2021=sum(rf_17_yea) / sum(rf_17_valid_vote))

#merge the two dataframes together
district_yea_rate<-merge(district_yea_rate_2018, district_yea_rate_2021, by='district.x')
#_______________________________________________________________________________________________________
#Question 7: (2 points) Which district's yea rate has largest decrease?
#use same code as in question 4 to find the largest decrease

#calculate the difference between mean yea rate in 2018 and 2021.
district_yea_rate <- district_yea_rate %>% 
  mutate(yea_change = district_yea_2021 - district_yea_2018)

#sort the df in an ascending order based on the yea_change column to find the biggest decrease.
district_yea_rate_decrease <- district_yea_rate[order(district_yea_rate$yea_change, decreasing =FALSE),]

#show first row with head
head(district_yea_rate_decrease, 1) #Gongliao, decrease -0.25320491

#_______________________________________________________________________________________________________
#Question 8: (2 points)

#Which district's yea rate has largest increase? (NO DISTRICT WITH INCREASE)

#sort the df descending based on the yea_change column. So showing the highest value first
district_yea_rate_increase <- district_yea_rate[order(district_yea_rate$yea_change, decreasing =TRUE),]

#show first row with head
head(district_yea_rate_increase, 1) #Xindian, decrease -0.01397470

#answer: there is no district with a mean increase in yeas. 
#all districts show a decrease in yea rates. 
#the district with the smallest decrease in yeas is Yonghe. 



#_______________________________________________________________________________________________________