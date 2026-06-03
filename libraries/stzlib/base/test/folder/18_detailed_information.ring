# Narrative
# --------
# Detailed Information
#
# Extracted from stzfoldertest.ring, block #18.

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Windows")
? @@NL(o1.Info())
#-->'
[
	[ "name", "Windows" ],
	[ "path", "C:/Windows" ],
	[ "absolutepath", "C:/Windows" ],
	[ "count", 118 ],
	[ "files", 32 ],
	[ "folders", 86 ],
	[ "isempty", 0 ],
	[ "isreadable", 1 ],
	[ "isroot", 0 ],
	[ "exists", 1 ]
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
