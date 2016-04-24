* init
set safety off
use bigram
use header

* main
output(query_and(query_and('全球暖化', '氣候變遷'), '節能減碳'))
output(query_or('新興市場', '金磚四國'))
output(query_and(query_and('新藥', '生技'), '研發'))
output(query_and(query_and('金融海嘯', '風暴'), '危機'))
output(query_or('國安基金', '護盤'))

* exit
close all
return

* and query
function query_and(termA, termB)
    query(termA)
    query(termB)
    select a.* from (termA) as a inner join (termB) as b on (a.doc_id == b.doc_id) into cursor (termA+'and'+termB)
    return termA+'and'+termB
endfunc

* or query
function query_or(termA, termB)
    query(termA)
    query(termB)
    select * from (termA) union select * from (termB) into cursor (termA+'or'+termB)
    return termA+'or'+termB
endfunc

* term query
function query(term)
    if not used(term)
        select doc_id, sent_id, wd_id-1 as wd_id from bigram where bigram.bigram == substrc(term, 1, 2) into cursor result
        for i = 2 to lenc(term)-1
            select doc_id, sent_id, wd_id-i as wd_id from bigram where bigram.bigram == substrc(term, i, 2) into cursor temp
            select result.* from result inner join temp on (result.doc_id == temp.doc_id and result.sent_id == temp.sent_id and result.wd_id == temp.wd_id) into cursor result
        endfor
        select distinct doc_id from result into cursor (term)
    endif
endfunc

* output result
function output(query_name)
    select header.* from header, (query_name) as result where header.doc_id == result.doc_id into table (query_name)
endfunc
