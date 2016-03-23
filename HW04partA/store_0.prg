* init
set safety off
create table file0(content M)
raw = fopen('ue_201012_2.txt')

* get data from txt
merge = ''
do while not feof(raw)
    line = fgets(raw, 65536)
    flag1 = at(',"', line)
    flag2 = at('","', line)
    if (flag1 < flag2 or flag2 == 0) and flag1 > 1 
        newdata(merge)
        merge = line
    else
        merge = merge + line
    endif
enddo
newdata(merge)

* exit
fclose(raw)
close all
return

* newdata function
function newdata(merge)
    if len(merge) > 0
        append blank
        replace content with merge
    endif
endfunc
