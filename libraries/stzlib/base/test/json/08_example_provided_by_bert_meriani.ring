# Narrative
# --------
# Example provided by Bert Meriani
#
# Extracted from stzjsontest.ring, block #8.

load "../../stzBase.ring"

pr()

cJsonStr = '[{"exdate": "2026-01-06","paydate": "2026-01-30","amount": "1.40","desc": "unconfirmed/estimated"},{"exdate": "2025-10-03","paydate": "2025-10-31","amount": "1.40","desc": "unconfirmed/estimated"},{"exdate": "2025-07-03","paydate": "2025-07-31","amount": "1.40","desc": ""},{"exdate": "2025-01-06","paydate": "2025-01-31","amount": "1.25","desc": ""},{"exdate": "2024-07-05","paydate": "2024-07-31","amount": "1.15","desc": ""},{"exdate": "2024-01-04","paydate": "2024-01-31","amount": "1.05","desc": ""},{"exdate": "2023-07-05","paydate": "2023-07-31","amount": "1.00","desc": ""},{"exdate": "2023-01-05","paydate": "2023-01-31","amount": "1.00","desc": ""},{"exdate": "2022-07-05","paydate": "2022-07-31","amount": "1.00","desc": ""},{"exdate": "2022-01-05","paydate": "2022-01-31","amount": "1.00","desc": ""},{"exdate": "2021-07-02","paydate": "2021-07-31","amount": "0.90","desc": ""},{"exdate": "2021-01-05","paydate": "2021-01-31","amount": "0.90","desc": ""}]'

? IsJson(cJsonStr)
#--> TRUE

aJsonList = JsonToList(cJsonStr)
? len(aJsonList)
#--> 12

? @@NL(aJsonList)
#-->
'
[
	[
		[ "exdate", "2026-01-06" ],
		[ "paydate", "2026-01-30" ],
		[ "amount", "1.40" ],
		[ "desc", "unconfirmed/estimated" ]
	],
	[
		[ "exdate", "2025-10-03" ],
		[ "paydate", "2025-10-31" ],
		[ "amount", "1.40" ],
		[ "desc", "unconfirmed/estimated" ]
	],
	[
		[ "exdate", "2025-07-03" ],
		[ "paydate", "2025-07-31" ],
		[ "amount", "1.40" ],
		[ "desc", "" ]
	],
	[
		[ "exdate", "2025-01-06" ],
		[ "paydate", "2025-01-31" ],
		[ "amount", "1.25" ],
		[ "desc", "" ]
	],
	[
		[ "exdate", "2024-07-05" ],
		[ "paydate", "2024-07-31" ],
		[ "amount", "1.15" ],
		[ "desc", "" ]
	],
	[
		[ "exdate", "2024-01-04" ],
		[ "paydate", "2024-01-31" ],
		[ "amount", "1.05" ],
		[ "desc", "" ]
	],
	[
		[ "exdate", "2023-07-05" ],
		[ "paydate", "2023-07-31" ],
		[ "amount", "1.00" ],
		[ "desc", "" ]
	],
	[
		[ "exdate", "2023-01-05" ],
		[ "paydate", "2023-01-31" ],
		[ "amount", "1.00" ],
		[ "desc", "" ]
	],
	[
		[ "exdate", "2022-07-05" ],
		[ "paydate", "2022-07-31" ],
		[ "amount", "1.00" ],
		[ "desc", "" ]
	],
	[
		[ "exdate", "2022-01-05" ],
		[ "paydate", "2022-01-31" ],
		[ "amount", "1.00" ],
		[ "desc", "" ]
	],
	[
		[ "exdate", "2021-07-02" ],
		[ "paydate", "2021-07-31" ],
		[ "amount", "0.90" ],
		[ "desc", "" ]
	],
	[
		[ "exdate", "2021-01-05" ],
		[ "paydate", "2021-01-31" ],
		[ "amount", "0.90" ],
		[ "desc", "" ]
	]
]
'

pf()
