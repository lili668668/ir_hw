* init
set safety off
create table header(doc_id I, date C(10), title1 M, title2 M, title3 M, edition C(4), content M)

* get data from file0
select 2
use file0

data = ''
do while not eof()
    data = content
    select 1
    append blank
    replace date with split(',"')
    replace title1 with split('","')
    replace title2 with split('","')
    replace title3 with split('","')
    replace content with split('","')
    replace edition with left(data, len(data)-1)

    select 2
    skip 1
enddo

* add doc_id
select 1
replace all doc_id with recno()

* exit
close all
return

* split function
function split(sep)
    flag = at(sep, data)
    temp = left(data, flag-1)
    data = right(data, len(data) - (flag+len(sep)-1))
    return temp
endfunc
