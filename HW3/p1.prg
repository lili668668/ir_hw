select sd.sales_id ,sd.month , sum(sd.amount*p.price) as month_total from sale_detail sd, product p group by sd.sales_id, sd.month where sd.product_id=p.id into table p1