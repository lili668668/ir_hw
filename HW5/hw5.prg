* ��16��
* ��GB 03156225 �x�O�u
* �k��B 00141250 ���a�s

* ��l��
set safety off
close all
create table sentence (doc_id int, sent_id int, content memo)

* �_�I
dimension keyWord(6)
keyWord(1) = "�C"
keyWord(2) = "�I"
keyWord(3) = "�H"
keyWord(4) = "�C�v"
keyWord(5) = "�I�v"
keyWord(6) = "�H�v"

select 2
use header

* �D�{��
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

* �ǰe��m�P���A
define class trans as custom
	position = 0
	type = 0
enddefine

* �O�_����
function isEnd(str)
	flag = 0
	for cnt = 1 to 6
		if at(keyWord(cnt), str) > 0
			flag = 1
		endif
	endfor
	return flag
endfunc

* �^���_�I�e�b�q
function preCut(str, trans)
	if trans.type > 3
		return left(str, trans.position + 3)
	else
		return left(str, trans.position + 1)
	endif
endfunc

* �^���_�I��b�q
function lastCut(str, trans)
	if trans.type > 3
		return right(str, len(str) - trans.position - 3)
	else
		return right(str, len(str) - trans.position - 1)
	endif
endfunc

* �^�Ǧ�m�P���A
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

* ��J�ܸ�Ʈw
function send(docId, sentId, str)
	append blank
	replace doc_id with docId
	replace sent_id with sentId
	replace content with str
endfunc