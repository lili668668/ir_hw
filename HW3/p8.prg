select sd.sales_id ,sd.month , sum(sd.amount*p.price) as month_total from sale_detail sd, product p group by sd.sales_id, sd.month where sd.product_id=p.id into table p1
select p1.month, p1.sales_id, p1.month_tota from p1 where p1.month_tota > 10000 order by p1.month into table p6
select p6.sales_id, count(p6.sales_id) as cnt from p6 group by sales_id into table p8