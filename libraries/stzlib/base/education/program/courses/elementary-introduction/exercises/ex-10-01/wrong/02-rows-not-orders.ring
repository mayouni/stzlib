# Counts the rows instead of adding the orders.
oT = new stzTable([ [ :DISH, :PRICE, :ORDERS ], [ "tea", 200, 6 ], [ "rice", 500, 3 ], [ "fish", 900, 2 ] ])
? oT.Cell(:PRICE, 3)
? oT.NumberOfRows()
