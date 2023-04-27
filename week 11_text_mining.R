install.packages("httr")
install.packages("widyr")
install.packages('wordcloud2')
library(httr)
library(widyr)



library(readr)
library(readxl)
library(writexl)
library(dplyr)
library(tidytext)
library(wordcloud2)
library(httr)

#the code below was provided by Torrent


options(warn = -1)

setwd("/Users/jasperhewitt/Desktop/big data & social analysis/code/datasets") # where I stored imdb

setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # what is this?

api_key <- "" #delete later

ici <- c("ICI is great",
         "NCCU is great",
         "Big data is so easy",
         "I love big data courses of ICI, NCCU",
         "ICI offer 10 great courses")

#put it in a df
ici_df <- data.frame(line = 1:5, text = ici, stringsAsFactors = FALSE)
ici_df

#loop this stuff 
response <- POST(
  url = "https://api.openai.com/v1/chat/completions", 
  add_headers(Authorization = paste("Bearer", api_key)),
  content_type_json(),
  encode = "json",
  body = list(
    model = "gpt-3.5-turbo",
    messages = list(list(role = "system", content = paste0("I want you to do sentiment analysis. I will provide you a message and you will tell me the message is positive, neutral, or negative. The message is here:", ici_df$text[1])),
                    list(role = "user", content = "Is the message is positive, neutral, or negative? Just give me low case positive, neutral, or negative. Don't give me other things and do not write original texts and explanations."))
  )
)

content(response)$choices[[1]]$message$content

temp <- data.frame(order = 1,
                   chatgpt = content(response)$choices[[1]]$message$content)

#now let's loop all the rows through them and store them to this df. 
#convert this code into Python

ici_chatgpt <- data.frame()

for (i in 1:nrow(ici_df)) {
  
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions", 
    add_headers(Authorization = paste("Bearer", api_key)),
    content_type_json(),
    encode = "json",
    body = list(
      model = "gpt-3.5-turbo",
      max_tokens = 1,
      temperature = 0,
      n = 1,
      messages = list(list(role = "system", content = paste0("I want you to do sentiment analysis. I will provide you messages and you will tell me a message is positive, neutral, or negative. The message is here:", ici_df$text[i])),
                      list(role = "user", content = "Is the message is positive, neutral, or negative? Just give me low case positive, neutral, or negative. Don't give me other things and do not write original texts and explanations."))
    )
  )
  
  answer <- strsplit(httr::content(response)$choices[[1]]$message$content, "\n")[[1]]
  
  print(c(i, answer))
  
  temp <- data.frame(order = i,
                     chatgpt = answer[1],
                     stringsAsFactors = FALSE)
  
  ici_chatgpt <- bind_rows(ici_chatgpt, temp)
  
}


#now we can rbind it together, or put it together
ici_df$chatgpt<-ici_chatgpt$chatgpt

#Sentiment Analysis for IMDB dataset

imdb <- read_xlsx("imdb.xlsx")

set.seed(123)
imdb_manual <- imdb[sample(1:50000, 100),] #get a 100 rows

imdb_manual_done <- read_xlsx("imdb_manual.xlsx") #get the manually labelled dataset

imdb_chatgpt <- data.frame()

for (i in 1:100) {
  
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions", 
    add_headers(Authorization = paste("Bearer", api_key)),
    content_type_json(),
    encode = "json",
    body = list(
      model = "gpt-3.5-turbo",
      max_tokens = 1,
      temperature = 0,
      n = 1,
      messages = list(list(role = "system", content = paste0("I want you to do sentiment analysis. I will provide you messages and you will tell me a message is positive or negative. The message is here:", imdb_manual_done$review[i])),
                      list(role = "user", content = "Is the message is positive or negative? Just give me low case positive or negative. Don't give me other things and do not write original texts and explanations."))
    )
  )
  
  answer <- strsplit(httr::content(response)$choices[[1]]$message$content, "\n")[[1]]
  
  print(c(i, answer))
  
  temp <- data.frame(order = i,
                     chatgpt = answer[1],
                     stringsAsFactors = FALSE)
  
  imdb_chatgpt <- bind_rows(imdb_chatgpt, temp)
  
}
#now calculate the accuracy
imdb_manual_done$chatgpt <- imdb_chatgpt$chatgpt

#this is incase you have to clean something. but for now turn it off bc it messes up
#the code
#imdb_manual_done$chatgpt <- tolower(imdb_manual_done$chatgpt)
#imdb_manual_done$chatgpt <- gsub(".", "", imdb_manual_done$chatgpt)

imdb_manual_done <- imdb_manual_done %>%
  mutate(check = case_when(sentiment == chatgpt ~ 1,
                           TRUE ~ 0))

sum(imdb_manual_done$check) / nrow(imdb_manual_done) #accuracy 0.94


#Information extraction
#presidents

president <- data.frame(line = 1:5, text = c("Obama and Trump was the US President.",
                                             "Obama and Trump was the US President and they won the US elections in 2008 and 2016, respectively.",
                                             "Ing-wen Tsai has been the Taiwan President since 2016.",
                                             "Biden has served as the US President since 2021, having defeated Trump in the election.",
                                             "Ing-wen Tsai, met with McCarth, the US House Speaker, this May."))



response <- POST(
  url = "https://api.openai.com/v1/chat/completions", 
  add_headers(Authorization = paste("Bearer", api_key)),
  content_type_json(),
  encode = "json",
  body = list(
    model = "gpt-3.5-turbo",
    #temperature = 0,
    messages = list(list(role = "system", content = paste0("I will give you a message. You will give me the entities from the message. The message is here:", president$text[2], "Give me the following things:")),
                    list(role = "user", content = "1. Name: Just give me the name and sparate them by |. if there is no name, give me N"),
                    list(role = "user", content = "2. Governmental Position: Just give me the name and sparate them by |. if there is no position, give me N"),
                    list(role = "user", content = "3. Does the message mention the US elections? If yes, give me 1, otherwise 0. Just give me 1 or 0, no other things."),
                    list(role = "user", content = "4. Year: Just give me the year and sparate them by |. if there is no year, Just give me N"))
    
  )
)

response
answer <- strsplit(httr::content(response)$choices[[1]]$message$content, "\n")[[1]]

answer

temp <- data.frame(order = 1,
                   name = answer[1],
                   position = answer[2],
                   election = answer[3],
                   year = answer[4],
                   stringsAsFactors = FALSE)

#Loop for information extraction

extract <- data.frame()

for (i in 1:nrow(president)) {
  
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions", 
    add_headers(Authorization = paste("Bearer", api_key)),
    content_type_json(),
    encode = "json",
    body = list(
      model = "gpt-3.5-turbo",
      temperature = 0,
      messages = list(list(role = "system", content = paste0("I will give you a message. You will give me the entities from the message. The message is here:", president$text[i], "Give me the following things:")),
                      list(role = "user", content = "1. Personal Name: Just give me the name and sparate them by |. if there is no name, give me N"),
                      list(role = "user", content = "2. Governmental Position: Just give me the name and sparate them by |. if there is no position, give me N"),
                      list(role = "user", content = "3. Does the message mention the US elections? If yes, give me 1, otherwise 0. Just give me 1 or 0, no other things."),
                      list(role = "user", content = "4. Year: Just give me the year and sparate them by |. if there is no year, Just give me N"))
      
    )
  )
  
  answer <- strsplit(httr::content(response)$choices[[1]]$message$content, "\n")[[1]]
  
  print(paste(i, answer))
  
  temp <- data.frame(order = i,
                     name = answer[1],
                     position = answer[2],
                     election = answer[3],
                     year = answer[4],
                     stringsAsFactors = FALSE)
  
  extract <- bind_rows(extract, temp)
  
}

#Clean data

extract_clean <- extract

extract_clean$name <- gsub("[0-9]. ", "", extract_clean$name)

extract_clean$name <- gsub(" \\| ", "|", extract_clean$name)

extract_clean$position <- gsub("[0-9]. ", "", extract_clean$position)

extract_clean$position <- gsub(" \\| ", "|", extract_clean$position)

extract_clean$election <- gsub("[0-9]. ", "", extract_clean$election)  

extract_clean$election[regexpr("\\(", extract_clean$election) > 0] <- substr(extract_clean$election[regexpr("\\(", extract_clean$election) > 0], 1, regexpr("\\(", extract_clean$election[regexpr("\\(", extract_clean$election) > 0]) - 1)

extract_clean$election <- gsub(" ", "", extract_clean$election)

extract_clean$election[extract_clean$election == "N"] <- 0

extract_clean$year <- gsub("[0-9]. ", "", extract_clean$year)  

extract_clean$year[regexpr("\\(", extract_clean$year) > 0] <- substr(extract_clean$year[regexpr("\\(", extract_clean$year) > 0], 1, regexpr("\\(", extract_clean$year[regexpr("\\(", extract_clean$year) > 0]) - 1)

extract_clean$year <- gsub(" ", "", extract_clean$year)


#word cloud
library(tidyverse)
library(tidyr)
#put everything in the proper format to create the wordcloud
#see slides for more info on how to reshape everything.
extrac_reshape <- extract_clean %>%
  select(order, name) %>%
  separate_rows(name, sep = "\\|")


frq <- extrac_reshape %>%
  count(name, sort = TRUE) 

wordcloud2(frq)

extrac_reshape_all <- extract_clean %>%
  select(order, name, position) %>%
  separate_rows(name, position, sep = "\\|") %>%
  gather(key = "variable", value = "entity", -order) %>%
  select(-variable) %>%
  arrange(order)

frq_all <- extrac_reshape_all %>%
  count(entity, sort = TRUE) 

wordcloud2(frq_all)

#Word associations

library(widyr)

cors <- extrac_reshape_all %>%
  group_by(entity) %>%
  pairwise_cor(entity, order, sort = TRUE)
