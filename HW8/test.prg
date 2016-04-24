* init
set safety off
use bigram

* search term
term = '全球暖化'
select doc_id, sent_id, wd_id-1 as wd_id from bigram where bigram.bigram == substrc(term, 1, 2) into cursor merge
for i = 2 to lenc(term)-1
    select doc_id, sent_id, wd_id-i as wd_id from bigram where bigram.bigram == substrc(term, i, 2) into cursor temp
    select merge.* from merge inner join temp on (merge.doc_id == temp.doc_id and merge.sent_id == temp.sent_id and merge.wd_id == temp.wd_id) into cursor merge
endfor
select merge
copy to output

* exit
close all
return
