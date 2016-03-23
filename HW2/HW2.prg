CREATE TABLE sales (Sales_id I, Name C(20), gender I, birthDay C(10), telephone C(10))
USE sales
APPEND FROM sales.txt DELIMITED WITH TAB

CREATE TABLE sale_detail (Sales_id I, month I, day I, amount I, product_id I)
USE sale_detail
APPEND FROM sale_detail.txt DELIMITED WITH TAB

CREATE TABLE product (id I, name C(20), price I, color C(20), size C(20))
USE product
APPEND FROM product.txt DELIMITED WITH TAB
