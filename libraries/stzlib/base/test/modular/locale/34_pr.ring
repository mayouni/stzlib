# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #34.

load "../../../stzBase.ring"


? NamesOfDaysIn(:Japanese)  # Or ...In(:Japan)
#--> [ "日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日" ]


? Association([ NamesOfDaysIn(:English), NamesOfDaysIn(:Japanese) ])
#-->
'
[
	[ "Sunday", "日曜日" ],
	[ "Monday", "月曜日" ],
	[ "Tuesday", "火曜日" ],
	[ "Wednesday", "水曜日" ],
	[ "Thursday", "木曜日" ],
	[ "Friday", "金曜日" ],
	[ "Saturday", "土曜日" ]
]
'

pf()
# Executed in 0.042 second(s) in Ring 1.23
