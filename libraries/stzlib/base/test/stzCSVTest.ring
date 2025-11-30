load "../stzbase.ring"
load "../../max/list/stzlist2D.ring"

/*---

pr()

aMyList = [
	[
		"product",
		[
			"Apple",
			"Orange",
			"Banana",
			"Grape",
			"Mango"
		]
	],
	[
		"price",
		[
			"$1.50",
			"$1.20",
			"$0.80",
			"$2.00",
			"$3.00"
		]
	],
	[
		"stock",
		[
			"100",
			"150",
			"200",
			"80",
			"50"
		]
	]
]

? ListToCSVXT(aMyList, ";")
#-->
'
product;price;stock
Apple;$1.50;100
Orange;$1.20;150
Banana;$0.80;200
Grape;$2.00;80
Mango;$3.00;50
'
pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--

pr()

str = '
product;price;stock
Apple;$1.50;100
Orange;$1.20;150
Banana;$0.80;200
Grape;$2.00;80
Mango;$3.00;50
'

? IsCSV(trim(str))

? @@NL( CSVToList(str) )
#-->
'
[
	[
		"product",
		[
			"Apple",
			"Orange",
			"Banana",
			"Grape",
			"Mango"
		]
	],
	[
		"price",
		[
			"$1.50",
			"$1.20",
			"$0.80",
			"$2.00",
			"$3.00"
		]
	],
	[
		"stock",
		[
			100,
			150,
			200,
			80,
			50
		]
	]
]
'

pf()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.11 second(s) in Ring 1.22

/*---
*/

cStr = 'tree_id;block_id;created_at;tree_dbh;alive
180683;348711;08/27/2015;3;Alive
200540;315986;09/03/2015;21;Alive
204026;218365;09/05/2015;3;Dead
204337;217969;09/05/2015;10;Alive
189565;223043;08/30/2015;21;Alive
190422;106099;08/30/2015;11;Dead
190426;106099;08/30/2015;11;Alive
208649;103940;09/07/2015;9;Alive
209610;407443;09/08/2015;6;Alive
180683;348711;08/27/2015;3;Alive'

? IsCSV(cStr)
#--> TRUE
