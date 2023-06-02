#_____________________________________________________________________________________________________________
setwd("/Users/jasperhewitt/Desktop/fertnews")

#pdffiles 

library(pdftools)
library(tidyverse)
library(stringr)
library(lubridate)

#convert to txt with pdftools package
text <- pdf_text("fertnews1MERGED.pdf")

# put everything into one single string. 
text_combined <- paste(text, collapse = "\n")

# Split text on '文章編號:' because this indicates the end of an article
split_text <- strsplit(text_combined, split = "文章編號:")


# Convert the list to a data frame
wise_df <- data.frame(dirty_content = split_text[[1]], stringsAsFactors = FALSE)

# for now, put the same content into the dirty_date column.
#we will start writing separate regexes for both columns later. 
wise_df$dirty_date <- wise_df$dirty_content


#drop the last row, bc this only contains unimportant information that came after the last article
wise_df <- wise_df[-nrow(wise_df), ]

#regex for date column: our goal is to only get the publishing date of the article. Nothing else
# Define the pattern. everything from '|' until '網站' (because that's where the date is in between)
pattern <- "\\|.*\\n網站"
wise_df$date <- str_extract(wise_df$dirty_date, pattern)

# delete the parts that we don't need
wise_df$date <- str_replace_all(wise_df$date, "\\| ", "")
wise_df$date <- str_replace_all(wise_df$date, "\n網站", "")

# delete everything before '文字快照'. 
wise_df$content <- sub(".*文字快照", "", wise_df$dirty_content)

#delete the column we no longer need
wise_df$dirty_content <- NULL
wise_df$dirty_date <- NULL

#this works: using a regular regex here does not really work because the links have several different formats
#Since all of the rows now start with a link, and are then followed by a news article in Chinese
#the following code uses the stringi package to delete all the non-han characters at the start of each row. This effectively gets
#rid of all of the links
wise_df$content <- stringi::stri_replace_all_regex(wise_df$content, '^[^\\p{Han}]*', "")

#delete newline symbols
wise_df$content <- gsub("\n", "", wise_df$content)


print(wise_df$content[1])

#to do!

#still select the part after 更多內容 in some of the posts and delete it bc it might contain some titles to other
#news articles. if those news articles have our key words than the whole article is not about
#our topic!


library(dplyr)
library(stringr)
library(purrr)

search_pattern <- "少子化|生育率|生育|生孩子|孕育|懷孕|育兒|育嬰|新生兒|托嬰|公托|臨托|產檢|孕"

wise_df <- wise_df %>%
  mutate(important_sentences = str_split(content, "[。？！]")) %>% #split it into sentences
  #find the sentences that contain some of our keywords, and paste that sentences into the important_sentences column
  mutate(important_sentences = map(important_sentences, ~ .[str_detect(., regex(search_pattern, ignore_case = TRUE))])) %>%
  #unnest the columns, so each important sentence will get their own row. just like 'explode in pandas' 
  unnest(important_sentences)

#delete rows with empty content column! because these are maybe not that important. 

print(wise_df$important_sentences)
print(class(wise_df$important_sentences))
print(class(wise_df$content))

#prepare dataframe for later plots
wise_df <- wise_df %>% 
  rename(text = content)%>% 
  filter(!str_detect(text,"^\\s*$"))%>% #remove empty docs
  mutate(doc_id = row_number())

#________________________________________________________________________________________________________________________
#wordclouds. https://alvinntnu.github.io/NTNU_ENC2036_LECTURES/chinese-text-processing.html
install.packages("quanteda")
install.packages("readtext")
library(tidyverse)
library(tidytext)
library(quanteda)
library(stringr)
library(jiebaR)
library(readtext)


text <- "綠黨桃園市議員王浩宇爆料，指民眾黨不分區被提名人蔡壁如、黃瀞瑩，在昨（6）日才請辭是為領年終獎金。台灣民眾黨主席、台北市長柯文哲7日受訪時則說，都是按流程走，不要把人家想得這麼壞。"


seg1 <- worker()
segment(text, jiebar = seg1)

class(seg1)

#custom dictionary of important words (to make R recognize it)
#some of the words are not recognized correctly, 民眾黨 and 柯文哲 should be put into one word, but they are not. 
#we can make a custom list of words.
#you can solve this by adding to user argument in worker. 
#yeah now it works!
seg2 <- worker(user = "customdict.txt") 
segment(text, seg2)

#stopwords.https://github.com/stopwords-iso/stopwords-zh/blob/master/stopwords-zh.txt converted to traditional
seg3 <- worker(user = "demo_data/dict-ch-user-demo.txt",
               stop_word = "stopwords_zh_trad.txt")
segment(text, seg3)

#_______________________________________________________________________________________________________________________

#different approach? or is this still part of the first one? THIS IS JUST TO SHOW US THAT QUANTADATA IS NOT THAT GOOD

## create corpus object
text_corpus <- corpus(text)

## summary
summary(text_corpus)

## Create tokens object
text_tokens <- tokens(text_corpus)

## Check quanteda-native word tokenization result. it's fine, but ofc it does't get our 民眾黨 and stuff.
text_tokens[[1]]

#a search for 柯文哲 yields no results
kwic(text_tokens, pattern = "柯文哲")

#this search does yield some interesting contextual results. 
kwic(text_tokens, pattern = "柯")

#_______________________________________________________________________________________________________________________
#SO NOW WE HAVE TO USE THE SELF DEFINED JIEBAR THINGIE TO MAKE IT BETTER
# a text-based tidy corpus
text_corpus_tidy <-text_corpus %>%
  tidy %>% 
  mutate(textID = row_number())

text_corpus_tidy

# initialize segmenter
my_seg <- worker(bylines = T, 
                 user = "customdict.txt", 
                 symbol=T)



# tokenization
text_corpus_tidy_word <- text_corpus_tidy %>%
  unnest_tokens(
    word,                 ## new tokens unnested
    text,                 ## original larger units
    token = function(x)   ## self-defined tokenization method
      segment(x, jiebar = my_seg)
  )

text_corpus_tidy_word


## create tokens based on self-defined segmentation
text_tokens <- text_corpus_tidy$text %>%
  segment(jiebar = my_seg) %>%
  as.tokens 

## kwic on word tokens. now it is way better
#output:  [text1, 37] 民眾黨 主席、 台北 市長 | 柯文哲 | 7 日 受訪 時則 說
kwic(text_tokens,
     pattern = "柯文哲")

#also interesting way of searching the text
kwic(text_tokens,
     pattern = ".*?[台市].*?", valuetype = "regex")

##_______________________________________________________________________________________________________________________
#now let's do some analysis on wise_df

 
#we are not actually going to use quanteda-native tokenization because it is not that strong. but we can still use it 
#to get a fast overview of our data. 
wise_corpus<-corpus(wise_df)
summary(wise_corpus, 10) 

## Get all summary
wise_corpus_overview <- summary(wise_corpus, ndoc(wise_corpus))

## Quick overview of number of tokens per document. but this may be misleading bc we are using quantadata's tokenization method
wise_corpus_overview %>%
  ggplot(aes(Tokens)) +
  geom_histogram(fill="white", color="lightblue")

##_______________________________________________________________________________________________________________________
#now let's get in it with the jiebaR

# initialize segmenter, getting everything ready

## for word segmentation only
my_seg <- worker(bylines = T,
                 user = "customdict.txt",
                 symbol = T)

## for POS tagging
my_seg_pos <- worker(
  type = "tag",
  bylines = F,
  user = "customdict.txt",
  symbol = T
)

#we can quickly add word to our custom dict 
#Add customized terms 
temp_new_words <-c("蔡英文", "新北市", "批踢踢實業坊", "批踢踢")
new_user_word(my_seg, temp_new_words)
new_user_word(my_seg_pos, temp_new_words)


#so we are using quanteda framework but with jiebar's segment(), and a custom dict. this performs better than quanteda's own tokenization
#apperently Jiebar's segment works best when working with smaller chunks of texts. since we are using long news articles it will be better
#to just cut the texts at the end of the sentence 


CHUNK_DELIMITER <- "[，。！？]+" #i took out newline breaks because it might split up important words in our text. 

## create `tokens` object using jiebaR. 

wise_df$text %>%
  map(str_split, pattern= CHUNK_DELIMITER, simplify=TRUE) %>% ## line tokenization
  map(segment, my_seg) %>% ## word tokenization
  map(unlist) %>% ## list to vec
  as.tokens -> wise_tokens

# add document-level variables. this will make it easier to trace back where certain tokens came from 

docvars(wise_tokens) <- wise_df[c("doc_id")]

## perform kwic. before adding this to the customdict there were no results, and now there are! 
kwic(wise_tokens, pattern= "九合一選舉", window = 10) #it might be an idea to delete the \n and just plot this. since these are the very
#related words lol 

#if you don't care about chunk tokenization you can also just do this wise_tokens <- as.tokens(segment(wise_df$text, my_seg))

install.packages("quanteda.textplots")
library(quanteda.textplots)
textplot_xray(
  kwic(wise_tokens, pattern= "柯文哲")
)

#________________________________________________________________________________________________________________
#now let's get to the actual wordcloud. let's try to do this with just the sentences surrounding the keywords. 
#ok so here we don't use corpus I guess

## for word segmentation only
my_seg <- worker(bylines = T,
                 user = "customdict.txt",
                 symbol = T)

#if we want to plot the whole text based on the text column we can use this. 
#but if we just use the important sentences column we don't have to do that because our df 
#already has split the sentences into different rows. 

## Tokenization: lines > words
#wise_line <- wise_df %>%
  ## line tokenization
#  unnest_tokens(
#    output = line,
#    input = text,
#    token = function (x)
#      str_split(x, CHUNK_DELIMITER)
#  )   %>%
#  group_by(doc_id) %>%
#  mutate(line_id = row_number()) %>%
#  ungroup

#wise_line %>% head(20)


#wise_word <- wise_line %>%
#  ## word tokenization
#  unnest_tokens(
#    output = word,
#    input = line,
#    token = function(x)
#      segment(x, jiebar = my_seg)
#  ) %>%
#  group_by(doc_id) %>%
#  mutate(word_id = row_number()) %>% # create word index within each document
#  ungroup

#wise_word %>% head(100)

wise_word <- wise_df %>%
  ## word tokenization
  unnest_tokens(
    output = word,
    input = important_sentences,  # the name of the column we are plotting
    token = function(x)
      segment(x, jiebar = my_seg)
  ) %>%
  group_by(doc_id) %>%
  mutate(word_id = row_number()) %>% # create word index within each document
  ungroup

wise_word %>% head(100)


#stop word lists
## load chinese stopwords
stopwords_chi <- readLines("stopwords_zh_trad.txt",
                           encoding = "UTF-8")

#if you want to add some custom keywords, we can use this.We want to take out some basic words like 
#少子化 and 生育率, because they are not very informative 
custom_stopwords <- c("經濟", "科技", "報導", "可能", "指出", "認為", "新聞網", "國際", 
                      "應該", "可能", "提出", "過去", "現在", "進行","今天", "相關", "社會",
                      "議題", "很多", "undo", "需要", "需求", "已經", "目前", "今年", "透過",
                      "地方", "沒有", "記者", "成為", "持續", "市場", "表示", "台灣", "造成",
                      "不少", "原因", "影響", 
                      "少子化", "台北", "生育率", "問題", "育兒", "生育")  # specific words about 生育率
stopwords_chi <- c(stopwords_chi, custom_stopwords)



## create word freq list
wise_word_freq <- wise_word %>%
  filter(!word %in% stopwords_chi) %>% # remove stopwords
  filter(word %>% str_detect(pattern = "\\D+")) %>% # remove words consisting of digits
  count(word) %>%
  arrange(desc(n))

library(wordcloud2)
#we could also consider to just keep in certain words. and go from there!
#like we just select a bunch of keywords that we think are worth discussing and then we only run a word cloud with that?
wise_word_freq %>%
  filter(n > 55) %>%
  filter(nchar(word) >= 2) %>% ## remove monosyllabic tokens
  wordcloud2(shape = "circle", size = 0.4)



#case study 3



























