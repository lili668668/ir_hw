* init
set safety off

* main
* df
select distinct doc_id, bigram from bigram into cursor bigram_tmp
select count(bigram) as df, bigram from bigram_tmp group by bigram into table df
*idf
select df, log(37289/df)/log(2) as idf, bigram from df into table idf

* exit
close all
return