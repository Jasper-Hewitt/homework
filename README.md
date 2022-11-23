# homework-individual assignment fake news detection

  • _Can Stemming or Lemmatization improve the accuracy of fake news detection?_
  • _Please perform an experiment and provide test results in any format._

I found that stemming slightly increases the accuracy of fake news detection from 0.9041 to 0.9079. I reran the code several time and the stemmed text finishes higher consistenly. This was done with a datasize of 4000 and a maximum_df of 0.6. 

That being said, when I increase the datasize to 6000. I find that the UNstemmed variant finishes consistently higher than the stemmed one. 

stemmed code: https://github.com/Jasper-Hewitt/homework/blob/main/homework_stemmed_fake_news_detection.ipynb 

unstemmed code: https://github.com/Jasper-Hewitt/homework/blob/main/homework_UNstemmed_fake_news_detection.ipynb


