* init
set safety off
use bigram

* main
query_and('全球暖化', '氣候變遷')
query_or('國安基金', '護盤')

* exit
close all
return

* and query
function query_and(termA, termB)
    query(termA)
    query(termB)
    select a.* from (termA) as a inner join (termB) as b on (a.doc_id == b.doc_id) into table (termA+'and'+termB)
endfunc

* or query
function query_or(termA, termB)
    query(termA)
    query(termB)
    select * from (termA) union select * from (termB) into table (termA+'or'+termB)
endfunc

* term query
function query(term)
    select doc_id, sent_id, wd_id-1 as wd_id from bigram where bigram.bigram == substrc(term, 1, 2) into cursor result
    for i = 2 to lenc(term)-1
        select doc_id, sent_id, wd_id-i as wd_id from bigram where bigram.bigram == substrc(term, i, 2) into cursor temp
        select result.* from result inner join temp on (result.doc_id == temp.doc_id and result.sent_id == temp.sent_id and result.wd_id == temp.wd_id) into cursor result
    endfor
    select distinct doc_id from result into cursor (term)
endfunc
