* init
set safety off
use bigram
use header

* main
parse('全球暖化 and 氣候變遷 and 節能減碳')
parse('新興市場 or 金磚四國')
parse('新藥 and 生技 and 研發')
parse('金融海嘯 and 風暴 and 危機')
parse('國安基金 or 護盤')

* exit
close all
return

* query parser
function parse(query)
    term = get_term(@query)
    result = term_query(term)
    do while lenc(query) > 0
        operator = get_operator(@query)
        term = get_term(@query)
        result = merge(result, term, operator)
    enddo
    output(result)

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
endfunc

* merge result
function merge(termA, termB, operator)
    term_query(termA)
    term_query(termB)
    result = termA + operator + termB
    do case
        case operator == 'AND'
            select a.* from (termA) as a inner join (termB) as b on (a.doc_id == b.doc_id) into cursor (result)
        case operator == 'OR'
            select * from (termA) union select * from (termB) into cursor (result)
        otherwise
            ? 'Invalid operator'
    endcase
    return result
endfunc

* term query
function term_query(term)
    if not used(term)
        select doc_id, sent_id, wd_id-1 as wd_id from bigram where bigram.bigram == substrc(term, 1, 2) into cursor result
        for i = 2 to lenc(term)-1
            select doc_id, sent_id, wd_id-i as wd_id from bigram where bigram.bigram == substrc(term, i, 2) into cursor temp
            select result.* from result inner join temp on (result.doc_id == temp.doc_id and result.sent_id == temp.sent_id and result.wd_id == temp.wd_id) into cursor result
        endfor
        select distinct doc_id from result into cursor (term)
    endif
    return term
endfunc

* output result
function output(query_name)
    select header.* from header, (query_name) as result where header.doc_id == result.doc_id into table (query_name)
endfunc
