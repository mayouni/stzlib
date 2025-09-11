load "../stzbase.ring"
load "../../max/list/stzList2D.ring"

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
