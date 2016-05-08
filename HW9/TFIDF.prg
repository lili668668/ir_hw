* init
set safety off

* main
select doc_id, tf, df, idf, (tf_norm * idf) as tfidf, tf_normalize.bigram, tf_norm from tf_normalize, idf where tf_normalize.bigram=idf.bigram into table tfidf

* exit
close all
return