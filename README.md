# homework-individual assignment fake news detection with BERT 6/12/22



| model |  not finetuned   |finetuned (3 epochs) | 
|  ---- |  ----  | ----  |
bert-base-uncased |  0.494 | 0.975 |
Roberta-base |  0.495 | 0.997 |

Questions: 

  • _Can BERT have better classification performance without fine-tuning?_
  
  • _do other BERT pre-training models have better classification performance after fine-tuning?_
  
I found that both bert-base-uncased and roberta-base perform significantly better after fine tuning (see table above). I think it is safe to assume that virtually all other BERT pre-trained models will have a better classification performance after fine-tuning.

code:

not finetuned roberta-base: https://github.com/Jasper-Hewitt/homework/blob/main/Roberta_base_not_finetuned.ipynb

finetuned roberta-base: https://github.com/Jasper-Hewitt/homework/blob/main/Roberta_base_finetuned.ipynb





# homework-individual assignment fake news detection 22/11/22

  • _Can Stemming or Lemmatization improve the accuracy of fake news detection?_
  
  • _Please perform an experiment and provide test results in any format._

I found that stemming slightly increases the accuracy of fake news detection from 0.9041 to 0.9079. I reran the code several times and the stemmed text finishes higher consistenly. This was done with a datasize of 4000 and a maximum_df of 0.6. 

That being said, when I increase the datasize to 6000. I find that the UNstemmed variant finishes consistently higher than the stemmed one. There appear to
be people who agree that stemming tends to lower precision (https://nlp.stanford.edu/IR-book/html/htmledition/stemming-and-lemmatization-1.html).

stemmed code: https://github.com/Jasper-Hewitt/homework/blob/main/homework_stemmed_fake_news_detection.ipynb 

unstemmed code: https://github.com/Jasper-Hewitt/homework/blob/main/homework_UNstemmed_fake_news_detection.ipynb

screenshot of the unfolded dataframe for closer inspection of the stemmed sentences: https://github.com/Jasper-Hewitt/homework/blob/main/example%20stemmed%20sentences.png





