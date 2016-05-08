* init
set safety off

* main
select doc_id, sqrt(sum(tfidf * tfidf)) as leng from tfidf group by doc_id into table doc_len

* exit
close all
return