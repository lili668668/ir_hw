select sd.sales_id ,sd.month , sum(sd.amount*p.price) as month_total from sale_detail sd, product p group by sd.sales_id, sd.month where sd.product_id=p.id into table p1
select p1.month, p1.sales_id, p1.month_tota from p1 where p1.month_tota > 10000 order by p1.month into table p6
select s.* from sales s, p6 where p6.month=1 and s.sales_id=p6.sales_id and s.sales_id in (select p6.sales_id from p6 where p6.month=2);
union;
select s.* from sales s, p6 where p6.month=2 and s.sales_id=p6.sales_id and s.sales_id in (select p6.sales_id from p6 where p6.month=3);
union;
select s.* from sales s, p6 where p6.month=3 and s.sales_id=p6.sales_id and s.sales_id in (select p6.sales_id from p6 where p6.month=4);
union;
select s.* from sales s, p6 where p6.month=4 and s.sales_id=p6.sales_id and s.sales_id in (select p6.sales_id from p6 where p6.month=5);
union;
select s.* from sales s, p6 where p6.month=5 and s.sales_id=p6.sales_id and s.sales_id in (select p6.sales_id from p6 where p6.month=6) into table p7