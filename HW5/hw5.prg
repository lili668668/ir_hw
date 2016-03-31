* ��16��
* ��GB 03156225 �x�O�u
* �k��B 00141250 ���a�s

* ��l��
set safety off
close all
create table sentence (doc_id int, sent_id int, content memo)

* �_�I
dimension keyWord(3)
keyWord(1) = "�C"
keyWord(2) = "�I"
keyWord(3) = "�H"

* �D�{��
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

* �ǰe��m�P�_�I�r����
define class trans as custom
	position = 0
	length = 0
enddefine

* �^���_�I�e�b�q
function preCut(str, trans)
		return left(str, trans.position + trans.length - 1)
endfunc

* �^���_�I��b�q
function lastCut(str, trans)
		return right(str, len(str) - trans.position - trans.length + 1)
endfunc

* �^�Ǧ�m�P���A
function posAndType(str)
	ob = createobject("trans")
	for cnt = 1 to 3
		num = at(keyWord(cnt), str)
		if num > 0 and (ob.position == 0 or num < ob.position)
                        ob.position = num
                        if substr(str, num + 2, 2) == "�v"
                                ob.length = 4
                        else
                                ob.length = 2
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
