* 資二B 洪慈吟
* 法五B 陳冠群

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
select df, log(37289/df)/log(2) as idf, bigram from df into table idf

* tfidf
select doc_id, tf, df, idf, (tf_norm * idf) as tfidf, tf_normalize.bigram, tf_norm from tf_normalize, idf where tf_normalize.bigram=idf.bigram into table tfidf

* Dlength
select doc_id, sqrt(sum(tfidf * tfidf)) as leng from tfidf group by doc_id into table Dlength

* query_length
create table Qlength (query_id I, leng F)
flag_query = 0

* main
qp = createobject('query_processor')
qp.search('全球暖化 氣候變遷 節能減碳')
qp.search('新興市場 金磚四國')
qp.search('新藥 生技 研發')
qp.search('金融海嘯 風暴 危機')
qp.search('國安基金 護盤')

* exit
close all
return

* query processor
define class query_processor as custom
    counter = 0

    function search(query)
        this.counter = this.counter + 1
		query_leng(this.counter, get_query_terms(@query))
		cos_sim(this.counter)
    endfunc
enddefine

* implement stack
define class stack as custom
	size = 0
	dimension stack(1)

	function push(element)
		this.size = this.size + 1
		dimension this.stack(this.size)
		this.stack[this.size] = element
	endfunc
	
	function pop()
		element = this.stack[this.size]
		this.size = this.size - 1
		return element
	endfunc
	
enddefine

* get query term
function get_query_terms(query)
	terms = createobject('stack')
	do while lenc(query) > 0
		terms.push(split(@query, ' '))
	enddo
	return terms
endfunc

* split function
function split(data, sep)
    flag = at(sep, data)
	
	if flag != 0
		temp = left(data, flag-1)
		data = right(data, len(data) - (flag+len(sep)-1))
	else
		temp = data
		data = ''
	endif
	
    return temp
endfunc

* query_length
function query_leng(id, terms)

	table_name = 'tfidf_query_' + alltrim(str(id))
	create table (table_name) (bigram C(4), tfidf F)
	flag = 0
	
	size = terms.size
	for cnt = 1 to size
		term = terms.pop()
		for cnt2 = 1 to lenc(term)-1
			if flag == 0
				select bigram, idf as tfidf from idf where bigram == substrc(term, cnt2, 2) into table (table_name)
				flag = 1
			else
				select * from (table_name) into table tmp
				select bigram, idf as tfidf from idf where bigram == substrc(term, cnt2, 2) union select * from tmp into table (table_name)
				drop table tmp
			endif
		endfor
	endfor
	
	if flag_query == 0
		select id as query_id, sqrt(sum(tfidf * tfidf)) as leng from (table_name) into table Qlength
		flag_query = 1
	else
		select * from Qlength into table tmp
		select id as query_id, sqrt(sum(tfidf * tfidf)) as leng from (table_name) union select * from tmp into table Qlength
		drop table tmp
	endif
endfunc

* CosSim
function cos_sim(id)
	table_name = 'tfidf_query_' + alltrim(str(id))
	score_table = 'score_' + alltrim(str(id))
	result = 'result_q' + alltrim(str(id))
	
	select doc_id, (Dlength.leng * Qlength.leng) as pow from Dlength, Qlength where Qlength.query_id == id group by Dlength.doc_id into table tmp
	select doc_id, sum(q.tfidf * d.tfidf) as sum from (table_name) as q, tfidf as d where q.bigram == d.bigram group by doc_id into table tmp2
	select id as query_id, tmp.doc_id, (tmp2.sum/tmp.pow) as score from tmp, tmp2 where tmp.doc_id == tmp2.doc_id group by tmp.doc_id into table (score_table)
	select header.doc_id, date, title1, title2, title3, edition, content, id as query_id, score from header, (score_table) as s where s.doc_id == header.doc_id order by score desc into table (result)
	
	alter table (result) add rank I
	use (result)
	replace all rank with recno()
	
	drop table tmp
	drop table tmp2

	return result
endfunc