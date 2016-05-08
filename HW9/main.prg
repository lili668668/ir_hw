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

* main
qp = createobject('query_processor')
qp.search('全球暖化 氣候變遷 節能減碳')
qp.search('新興市場 金磚四國')
qp.search('新藥 生技 研發')
qp.search('金融海嘯 風暴 危機')
qp.search('國安基金 護盤')

* query processor
define class query_processor as custom
    counter = 0

    function search(query)
        this.counter = this.counter + 1
        
		query_leng(counter, get_query_terms(@query))
		result = cos_sim(counter)
		select *, recno() as rank from (result) order by score desc into table (result)
    endfunc
enddefine

* terms
defind class array as custom
	size = 0
	dimension terms(1)

	function add(term)
		this.size = this.size + 1
		dimension terms(this.size)
		this.terms[this.size] = term
	endfunc
enddfind

* get query term
function get_query_terms(query)
	terms = createobject('array')
	do while lenc(query) > 0
		terms.add(split(@query, ' '))
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
		tmp = data
		data = ''
	endif
	
    return temp
endfunc

* query_length
function query_leng(id, terms)

	table_name = 'tfidf_query_' + alltrim(str(id))
	create table (table_name) (bigram C(4), tfidf F)
	
	for cnt = 1 to terms.size
		for cnt2 = 1 to lenc(terms[cnt])-1
			insert into (table_name) (bigram, tfidf) select bigram, idf from idf where bigram == substrc(terms[cnt], cnt2, 2)
		endfor
	endfor
	
	insert into Qlength (leng) select id as query_id, sqrt(sum(tfidf * tfidf)) as leng from (table_name)
	
	use Qlength
	skip id
	result = Qlength.leng
	close Qlength
endfunc

* CosSim
function cos_sim(id)
	table_name = 'tfidf_query_' + alltrim(str(id))
	result = 'result_q' + alltrim(str(id))
	select header.doc_id, date, t1, t2, t3, edition, content, Qlength.query_id, (sum(q.tfidf * d.tfidf)/(Dlength.leng * Qlength.leng)) as score from (table_name) as q, tfidf as d, Dlength, Qlength, header where Qlength.query_id == id, Dlength.doc_id == d.doc_id, header.doc_id == Dlength.doc_id, q.bigram == d.bigram into cursor (result)
	
	return result
endfunc

* exit
close all
return