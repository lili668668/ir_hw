* 第16組
* 資二B 03156225 洪慈吟
* 法五B 00141250 陳冠群

* 初始化
set safety off
close all
create table sentence (doc_id int, sent_id int, content memo)

* 斷點
dimension keyWord(3)
keyWord(1) = "。"
keyWord(2) = "！"
keyWord(3) = "？"

* 主程式
select 2
use header

do while not eof()
	docId = doc_id
	data = content
	sentId = 1
	select 1
	dataTrans = posAndType(data)
	do while dataTrans.position != 0
		send(docId, sentId, preCut(data, dataTrans))
		data  = lastCut(data, dataTrans)
		sentId = sentId + 1
		dataTrans = posAndType(data)
	enddo
	if len(data) != 0
		send(docId, sentId, data)
	endif
	select 2
	skip
enddo

* 傳送位置與斷點字長度
define class trans as custom
	position = 0
	length = 0
enddefine

* 回傳斷點前半段
function preCut(str, trans)
		return left(str, trans.position + trans.length - 1)
endfunc

* 回傳斷點後半段
function lastCut(str, trans)
		return right(str, len(str) - trans.position - trans.length + 1)
endfunc

* 回傳位置與型態
function posAndType(str)
	ob = createobject("trans")
	for cnt = 1 to 3
		num = at(keyWord(cnt), str)
		if num > 0 and (ob.position == 0 or num < ob.position)
                        ob.position = num
                        if substr(str, num + 2, 2) == "」"
                                ob.length = 4
                        else
                                ob.length = 2
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
