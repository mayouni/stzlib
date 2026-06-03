# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #200.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceRows([ "___", "___", "___" ])
? o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#    ------- ---------- --------- ----------
#       ___        ___       ___      Africa
#       ___        ___       ___      Europe
#       ___        ___       ___      Africa
#       ___        ___       ___      Europe
#       ___        ___       ___        Asia

o1.ReplaceRowsXT([ "___", "~~~" ])
o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#    ------- ---------- --------- ----------
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~

pf()
# Executed in 0.22 second(s)
