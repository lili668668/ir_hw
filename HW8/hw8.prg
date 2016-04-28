* init
set safety off
use bigram
use header

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
        result = merge_all(p_result)
        link_header(@result, this.counter)
        add_hitterm(@result, p_result)
    endfunc
enddefine

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

* merge result
function merge_all(p_result)
    result = term_query(p_result.terms[1])
    for i = 2 to p_result.counter
        next_result = term_query(p_result.terms[i])
        result = merge(result, next_result, p_result.operators[i])
    endfor
    return result
endfunc

function merge(resultA, resultB, operator)
    result = resultA + operator + resultB
    do case
        case operator == 'AND'
            select a.* from (resultA) as a inner join (resultB) as b on (a.doc_id == b.doc_id) into cursor (result)
        case operator == 'OR'
            select * from (resultA) union select * from (resultB) into cursor (result)
        otherwise
            ? 'Invalid operator'
    endcase
    return result
endfunc

* term query
function term_query(term)
    if not used(term)
        select doc_id, sent_id, wd_id-1 as wd_id from bigram where bigram.bigram == substrc(term, 1, 2) into cursor result
        for j = 2 to lenc(term)-1
            select doc_id, sent_id, wd_id-j as wd_id from bigram where bigram.bigram == substrc(term, j, 2) into cursor temp
            select result.* from result inner join temp on (result.doc_id == temp.doc_id and result.sent_id == temp.sent_id and result.wd_id == temp.wd_id) into cursor result
        endfor
        select distinct doc_id from result into cursor (term)
    endif
    return term
endfunc

* link header
function link_header(result, counter)
    new_result = 'query_' + alltrim(str(counter))
    select header.* ,counter as query_id from header, (result) as result where header.doc_id == result.doc_id into table (new_result)
    result = new_result
endfunc

* add hit_term
function add_hitterm(result, p_result)
    alter table (result) add hit_term M
    for i = 1 to p_result.counter
        update (result) set hit_term = hit_term+' '+p_result.terms[i] where doc_id in (select doc_id from (p_result.terms[i]))
    endfor
    update (result) set hit_term = alltrim(hit_term)
endfunc
