# The row of fish, not its price.
oT = new stzTable([ [ :DISH, :PRICE, :ORDERS ], [ "tea", 200, 6 ], [ "rice", 500, 3 ], [ "fish", 900, 2 ] ])
? @@( oT.Row(3) )
? StzListQ(oT.Col(:ORDERS)).Sum()
