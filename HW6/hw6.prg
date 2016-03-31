* init
set safety off
create table chinese(doc_id I, sent_id I, wd_id I, word C(2))
select 2
create table alphanum(doc_id I, sent_id I, wd_id I, word M)

* get data from sentence
select 3
use sentence

do while not eof()
    did = doc_id
    sid = sent_id
    wid = 1
    data = content
    strlen = lenc(data)
    flag = 0 && 0:chinese, 1:alphanum
    merge = ''
    for i = 1 to strlen
        ch = substrc(data, i, 1)
        if asc(ch) > 127
            if flag == 1
                newdata(2, merge)
                merge = ''
                flag = 0
            endif
            newdata(1, ch)
        else
            merge = merge + ch
            flag = 1
        endif
    endfor
    if lenc(merge) > 0
        newdata(2, merge)
    endif

    select sentence
    skip 1
enddo

* exit
close all
return

* newdata procedure
procedure newdata(table, str)
    select(table)
    append blank
    replace doc_id with did
    replace sent_id with sid
    replace wd_id with wid
    replace word with str
    wid = wid + 1
endproc
