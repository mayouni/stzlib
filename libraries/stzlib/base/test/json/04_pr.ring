# Narrative
# --------
# pr()
#
# Extracted from stzjsontest.ring, block #4.

load "../../stzBase.ring"


? ListToJsonXT([
	:a = 10,
	:b = 20,
	:c = [
		:d = 30,
		:e = 40
	]
])
#-->
'
{
	"a": 10,
	"b": 20,
	"c": {
		"d": 30,
		"e": 40
	}
}
'

pf()
# Executed in almost 0 second(s) in Ring 1.22
