# homework-individual assignment fake news detection with BERT 6/12/22

https://www.canva.com/design/DAF3ZvcmNTU/9W7vgiezGMZX8-xPXf3GrQ/edit?utm_content=DAF3ZvcmNTU&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton


1. 總統大選候選人排名

2.bonus: 每候選人的得票率 (+- 3%)

3.韓國瑜當選國會議長 【刪掉】

4.本島投票率最低的直轄市/縣市會是

5.本島投票率最高的直轄市/縣市會是

6.投票率多少

7.民進黨總席次

8.選舉之後，最年輕的立委幾歲？（+- 1Y）

9.選舉之後，立委的男女比例是多少？(+-3%)

10.民進黨、國民黨、民眾黨之外的政黨（包括無黨籍）在立委總共得到多少席次？（+-一個席次）

11.台北市第一選區當選人

12.台中市第二選區當選人

13.台南市第三選區國民黨候選人得票率?

14.沒當選的話柯文哲請辭黨主席

15.台北市之外，柯文哲在總統大選得票率最高的直轄市/縣市是

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





