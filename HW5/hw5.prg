* 第16組
* 資二B 03156225 洪慈吟
* 法五B 00141250 陳冠群

* 初始化
set safety off
close all
create table sentence (doc_id int, sent_id int, content memo)

* 斷點
dimension keyWord(6)
keyWord(1) = "。"
keyWord(2) = "！"
keyWord(3) = "？"
keyWord(4) = "。」"
keyWord(5) = "！」"
keyWord(6) = "？」"

select 2
use header

* 主程式
do while not eof()
	docId = doc_id
	data = content
	sentId = 1
	select 1
	do while isEnd(data) != 0
		dataTrans = posAndType(data)
		send(docId, sentId, preCut(data, dataTrans))
		data  = lastCut(data, dataTrans)
		* ? docId
		sentId = sentId + 1
	enddo
	if len(data) != 0
		send(docId, sentId, right(data, len(data)))
	endif
	select 2
	skip
enddo

* 傳送位置與型態
define class trans as custom
	position = 0
	type = 0
enddefine

* 是否結束
function isEnd(str)
	flag = 0
	for cnt = 1 to 6
		if at(keyWord(cnt), str) > 0
			flag = 1
		endif
	endfor
	return flag
endfunc

* 回傳斷點前半段
function preCut(str, trans)
	if trans.type > 3
		return left(str, trans.position + 3)
	else
		return left(str, trans.position + 1)
	endif
endfunc

* 回傳斷點後半段
function lastCut(str, trans)
	if trans.type > 3
		return right(str, len(str) - trans.position - 3)
	else
		return right(str, len(str) - trans.position - 1)
	endif
endfunc

* 回傳位置與型態
function posAndType(str)
	ob = createobject("trans")
	for cnt = 1 to 3
		num = at(keyWord(cnt), str)
		if num > 0
			if ob.position == 0 or num < ob.position
				ob.position = num
				if num == at(keyWord(cnt + 3), str)
					ob.type = cnt + 3
				else
					ob.type = cnt
				endif				
			endif
		endif
	endfor
	return ob
endfunc

* 輸入至資料庫
function send(docId, sentId, str)
	append blank
	replace doc_id with docId
	replace sent_id with sentId
	replace content with str
endfunc