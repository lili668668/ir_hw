* init
set safety off
create table file0(content M)
raw = fopen('UE2010.txt')

* get data from txt
merge = ''
do while not feof(raw)
    merge = merge + fgets(raw, 65536)
    if at('","', merge, 4) > 0 and right(merge, 1) == '"'
        append blank
        replace content with merge
        merge = ''
    endif
enddo

* exit
fclose(raw)
close all
return
