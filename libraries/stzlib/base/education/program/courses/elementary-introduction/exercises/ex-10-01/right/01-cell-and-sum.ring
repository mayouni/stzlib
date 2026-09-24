oT = new stzTable([ [ :DISH, :PRICE, :ORDERS ], [ "tea", 200, 6 ], [ "rice", 500, 3 ], [ "fish", 900, 2 ] ])
? oT.Cell(:PRICE, oT.FindInCol(:DISH, "fish")[1])
? StzListQ(oT.Col(:ORDERS)).Sum()
