* init
set safety off

* tf
select doc_id, count(bigram) as tf, bigram from bigram group by doc_id, bigram into table tf
select doc_id, bigram, max(tf) as tf from tf group by doc_id into table max_tf
select tf.doc_id, tf.bigram, tf.tf, (tf.tf/max_tf.tf) as tf_norm where tf.doc_id=max_tf.doc_id from tf, max_tf into table tf_normalize
* df
select distinct doc_id, bigram from bigram into cursor bigram_tmp
select count(bigram) as df, bigram from bigram_tmp group by bigram into table df
*idf
use header
select df, log(reccount('header')/df)/log(2) as idf, bigram from df into table idf

*idf_norm
select max(idf) as idf_max from idf into cursor idf_max
select df, idf/idf_max as idf_norm, bigram from idf, idf_max into table idf_norm

* tfidf
select doc_id, tf, df, idf_norm, (tf_norm * idf_norm) as tfidf, tf_normalize.bigram, tf_norm from tf_normalize, idf_norm where tf_normalize.bigram=idf_norm.bigram into table tfidf

* main
qp = createobject('query_processor')
qp.search('全球暖化 and 氣候變遷 and 節能減碳')
qp.search('新興市場 or 金磚四國')
qp.search('新藥 and 生技 and 研發')
qp.search('金融海嘯 and 風暴 and 危機')
qp.search('國安基金 or 護盤')

* exit
close all
return

* query processor
define class query_processor as custom
    counter = 0

    function search(query)
        this.counter = this.counter + 1
        
        p_result = parse(query)
        
        for cnt = 1 to p_result.counter
            term_merge_weight(p_result.terms[cnt])
        endfor
        
        result = 'query_' + alltrim(str(this.counter))
        select * from (p_result.terms[1]) into table (result)
        
        for cnt = 2 to p_result.counter
            sim(result, p_result.terms[cnt],p_result.operators[cnt])
        endfor
        
        link_header(result)
    endfunc
enddefine

* term_merge_weight
function term_merge_weight(term)

    term_doc_id = term_query(term)
    
    for cnt2 = 1 to lenc(term)-1
        if cnt2 == 1
            select tfidf.doc_id, tfidf from tfidf, (term_doc_id) as t where bigram == substrc(term, cnt, 2) and tfidf.doc_id==t.doc_id into table tmp
        else
            select * from tmp into table tmp2
            select tfidf.doc_id, tfidf from tfidf, (term_doc_id) as t where bigram == substrc(term, cnt, 2) and tfidf.doc_id==t.doc_id union select * from tmp2 into table tmp
            drop table tmp2
        endif
    endfor
    
    select doc_id, sqrt(sum( (1 - tfidf) * (1 - tfidf) )) as tmp_num from tmp group by doc_id into table tmp2
    
    select doc_id, 1 - tmp_num / (lenc(term)-1) as weight from tmp2 group by doc_id into table (term)
    
    drop table tmp
    drop table tmp2
endfunc

function sim(result, term, operator)

    select * from (result) union select * from (term) into table tmp

    do case
        case operator == 'AND'
            select doc_id, sqrt(sum( (1 - weight) * (1 - weight) )) as tmp_num from tmp group by doc_id into table tmp2
            select doc_id, 1 - tmp_num / 2 as weight from tmp2 group by doc_id into table (result)
            drop table tmp2
        case operator == 'OR'
            select doc_id, sqrt( sum( weight * weight ) / 2 ) as weight from tmp group by doc_id into table (result)
        otherwise
            ? 'Invalid operator'
    endcase

    drop table tmp
endfunc

* query parser
function parse(query)
    result = createobject('parse_result')
    result.append(get_term(@query), '')
    do while lenc(query) > 0
        operator = get_operator(@query)
        term = get_term(@query)
        result.append(term, operator)
    enddo
    return result
endfunc

* parse result
define class parse_result as custom
    counter = 0
    dimension terms(1)
    dimension operators(1)

    function append(term, operator)
        this.counter = this.counter + 1
        dimension this.terms(this.counter)
        dimension this.operators(this.counter)
        this.terms[this.counter] = term
        this.operators[this.counter] = operator
    endfunc
enddefine

function get_operator(query)
    do case
        case atcc('AND', query) == 1
            operator = 'AND'
        case atcc('OR', query) == 1
            operator = 'OR'
        otherwise
            operator = ''
    endcase
    query = rightc(query, lenc(query) - lenc(operator))
    return operator
endfunc

function get_term(query)
    flag_and = atcc('AND', query)
    flag_or = atcc('OR', query)
    do case
        case flag_and == 0 and flag_or == 0
            flag = lenc(query)
        case flag_and != 0 and flag_or != 0
            flag = min(flag_and, flag_or) - 1
        otherwise
            flag = max(flag_and, flag_or) - 1
    endcase
    term = alltrim(leftc(query, flag))
    query = rightc(query, lenc(query)-flag)
    return term
endfunc

* term query
function term_query(term)
    name = term + 'tmp'
    if not used(term)
        select doc_id, sent_id, wd_id-1 as wd_id from bigram where bigram.bigram == substrc(term, 1, 2) into cursor result
        for j = 2 to lenc(term)-1
            select doc_id, sent_id, wd_id-j as wd_id from bigram where bigram.bigram == substrc(term, j, 2) into cursor temp
            select result.* from result inner join temp on (result.doc_id == temp.doc_id and result.sent_id == temp.sent_id and result.wd_id == temp.wd_id) into cursor result
        endfor
        select distinct doc_id from result into cursor (name)
    endif
    return name
endfunc

* link header
function link_header(result)
    select * from (result) into table tmp
    select header.*, weight from header, tmp where header.doc_id==tmp.doc_id order by tmp.weight desc into table (result)
    
    alter table (result) add rank I
    use (result)
    replace all rank with recno()
    
    drop table tmp
endfunc