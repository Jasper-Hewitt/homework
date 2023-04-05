#Class: Week 07
#Course: Big Data and Social Analysis
#Semester: Spring 2023
#Lesson: Regular Expression
#Instructor: Chung-pei Pien
#Organization: ICI, NCCU

### Student Information --------

#Chinese Name: 嘉博
#English First Name: Jasper 
#UID: 111926019 
#E-mail: jasper.hewitt@me.com

### Questions --------



#Please read "trumptweets.xlsx", which contains Trump's tweets from Feb. 2017 to May 2018.
#The "text" column contains the content of Trump's tweets.
library("readxl")
library("dplyr")
library('stringr')
#Question 1 (5 points):

#Using regular expressions (regexpr(), grep(), or grepl()) and other R skills, create a new column called "china".
#Label "china" column as 1 if Trump mentioned China, otherwise label it as 0.
setwd("/Users/jasperhewitt/Desktop/big data & social analysis/code/datasets")
trumptweet <- read_xlsx("trumptweets.xlsx")

#since trump likes to write in caps, we first convert everything to lower case
trumptweet$text <- tolower(trumptweet$text)

#create a new column called China where all the values are NA
trumptweet$China <- NA  

# I decided to use stringr from the Regex cheat sheet you provided because it looks a lot like
#str.contains in python. str_detect will return an output of TRUE and FALSE to show whether
#the sentence does or does not contain the word 'china'. I store the output in the variable 'chinamatch'
chinamatch <- str_detect(trumptweet$text, "china")

# if chinamatch for a specific row is TRUE, assign 1 to that row in the China column 
trumptweet$China[chinamatch] <- 1
#  if chinamatch for a specific row is FALSE, assign 0 to that row in the China column
trumptweet$China[!chinamatch] <- 0

#count in how many tweets the word China appeared (count how many times 1 appears in the new column)
china_count <- sum(trumptweet$China == 1)
print(china_count) #73 tweets that contain the word 'china'

#_______________________________________________________________________________
#Question 2 (3 points):

#The "created_at" column indicates when Trump posted his tweets.
#Use "created_at" column to create a new column called "year", which shows the year in which the tweet was made.

# find the position of the first '-' in the 'created_at' column and store it in the variable yp
yp <- regexpr('-', trumptweet$created_at)

#extract the characters from from the created_at column. Only take the ones from the first position
#until the position of the first '-' minus 1 (because we do not want to include the dash).
#this basically takes the first 4 characters from the rows in the created_at column and assigns them to the
#new column 'year'
trumptweet$year <- substr(trumptweet$created_at, 1, yp-1)

#_______________________________________________________________________________
#Question 3 (4 points):

#Use group_by() and summarise() to determine the number of tweets made by Trump that mentioned China in 2017 and 2018.

#step 1: select the two relevant columns, do not consider the rest
#step 2: group_by year. so the new df will have two rows, 2017 and 2018 
#step 3: use summarize to create a new column 'china_per_year' with the sum of the China column per year. 
#because all the values in the China column are already 0 or 1, this is an easy step
selected_tweets <- trumptweet%>%
  select(China, year)%>%
  group_by(year)%>%
  summarize(china_per_year=sum(China)) #2017: 43, 2018: 30

#_______________________________________________________________________________
#Question 4 (3 points):

#The "is_retweet" column represents whether a tweet is a retweet or not.
#Create a new dataframe called "notrt_trump" that includes only Trump's original tweets (i.e., tweets that are not retweets).

#use dplyr's 'filter' to filter trumptweet based on the condition is_retweet == FALSE (not a retweet).
#the new dataframe is stored in notr_trump. this dataframe only contains TRump's original tweets
notrt_trump <- trumptweet %>%
  filter(is_retweet == FALSE) #2845 observations



#_______________________________________________________________________________
#Question 5 (5 points):

#On many social media platforms, the "@" symbol is referred to as a "handle".
#Apply regular expressions to extract the username associated with the "@" symbol in the "text" column of "notrt_trump" for the first row.

#there is two ways to solve this problem. If we wanna stick to the same structure as we did in last class
#we can do the following: 
#find the starting position and length of the Twitter handle (I let chatGPT generate the pattern, as Googling resulted in 
#many different patterns that all did not really work. chatGPT's pattern only works when you add the argument
#perl=TRUE. This has something to do with different types of regexpr in R). 
user_start_pos <- regexpr("(?<=@)[A-Za-z0-9_]+", notrt_trump$text[1], perl=TRUE)
print(user_start_pos) #starting position 227. length 10 

#extract substring. from starting position, starting position + the length of the handle -1 (to get rid of the space)
username <- substr(notrt_trump$text[1],
                   user_start_pos,
                   user_start_pos + attr(user_start_pos, "match.length")-1)
print(username) #nikkihaley

#alternatively, I found a simpler and faster method on stack overlflow that uses regmatches. 
#regmatches is also on the cheat sheet: regmatches(string, gregexpr(pattern, string))
#this directly extracts the pattern
handle <- regmatches(notrt_trump$text[1], gregexpr("(?<=@)[A-Za-z0-9_]+", notrt_trump$text[1], perl = TRUE))
print(handle) #nikkihaley

#_______________________________________________________________________________
#Question 6 (3 points)

#Use gregexpr() to obtain a list called "atsign", which shows the starting positions and length of the usernames associated with the "@" symbol in the "text" column.

#we can use the same code as above and what we used in class. But I add perl=TRUE to get the pattern. 
atsign <- gregexpr("(?<=@)[A-Za-z0-9_]+", notrt_trump$text, perl = TRUE)

print(atsign)

#Review the "atsign" list and identify the smallest row number that contains "@" symbols with a length greater than 2 and tell me the row number

#ANSWER:do you mean the smallest row number that contains a twitter handle? this would be row 1. it contains a twitter handle with a length of 10.
#however, since we already got the handle of the first row in the previous question, I assume that this is not what you mean.
#the second row with a Twitter handle is row number 8. It contains two handles 



#_______________________________________________________________________________
#Question 7 (7 points)

#Using a loop, extract the usernames associated with the "@" symbol in the "text" column of "notrt_trump" for the row you identified in Question 6.

#assuming you mean the second lowest row number that contains @symbols (because we already found the handle to the first one in question 5). 
#I've decided to look at row number 8. 

#for x in 1 to the length of atsign[[8]] (row number 8)
for (x in 1:length(atsign[[8]])) {

  #at_content = the starting positions of the handles in the text column of row 8 + the length of said handles -1 (to get rid of the space)
  at_content <- substr(notrt_trump$text[8],
                       atsign[[8]][x],
                       atsign[[8]][x] + attr(atsign[[8]], "match.length")[x] - 1)
  
  print(at_content) # loudobbs and greggjarret 
}

#alternatively, the code below using regmatches shows the same results
handle_8 <- regmatches(notrt_trump$text[8], gregexpr("(?<=@)[A-Za-z0-9_]+", notrt_trump$text[8], perl = TRUE))
print(handle_8)


#Now you have 30 points! Question 8 is a bonus!
#_______________________________________________________________________________
#Question 8 (5 points)

#Using loops, extract the usernames associated with the "@" symbol in the text column of "notrt_trump" for all rows.

#we can put the code above in another loop that goes through all the rows. And store the extracted usernames in a df
#we can use parts of the code from last lecture 
#create empty df
df <- data.frame()
#for every row in the notr_trump df, use gregexpr to get the starting positions and length of the handles
for (i in 1:nrow(notrt_trump)) {
  atsign <- gregexpr("(?<=@)[A-Za-z0-9_]+", notrt_trump$text[i], perl=TRUE)
  
  #here we do the same as before. However, this time we replace substr(notrt_trump$text[8], with substr(notrt_trump$text[i],
  #this makes the code loop through all the sentences and extract the hasthags from all of them
  #this is done in the same way. #at_content = the starting positions of the handles in the text column of row 8 
  #+ the length of said handles -1 (to get rid of the space)
  for (x in 1:length(atsign[[1]])) {
    at_content <- substr(notrt_trump$text[i],
                         atsign[[1]][x],
                         atsign[[1]][x] + attr(atsign[[1]], "match.length")[x] - 1)
    #store output in a temporary df. 
    temp <- data.frame(row_id = i,
                       usernames = at_content)
    #bind the temporary df to the main df after every iteration of the loop
    df <- rbind(df, temp)
  }
}

#alternatively, we can use regmatches to get the same results. 
all_handle <- regmatches(notrt_trump$text, gregexpr("(?<=@)[A-Za-z0-9_]+", notrt_trump$text, perl = TRUE))

# putting the output into a df was a little too complicated for me so I used chatGPT. It uses sapply to put 
#everything into the df. 
df <- data.frame(row_id = rep(1:nrow(notrt_trump), sapply(all_handle, length)),
                 usernames = unlist(all_handle))

