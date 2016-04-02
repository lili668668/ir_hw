* 初始化
set safety off
close all

* 抓出標點
use chinese
index uniq on word to tmp_index
copy to tmp
use tmp
copy to mark field word for recno() <= 155

* 去除標點
sele * from chinese where word not in (sele word from mark) into table less_mark

* bigram
sele a.doc_id, a.sent_id, a.wd_id, a.word + b.word as bigram from less_mark a, less_mark b where a.doc_id==b.doc_id and a.sent_id==b.sent_id and a.wd_id==b.wd_id-1 into table bigram
