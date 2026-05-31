# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #19.

load "../../../stzBase.ring"


o1 = new stzHashList([
	:egypt		= :africa,
	:tunisia	= :africa,
	:saudi_arabia	= :asia,
	:spain		= :europe,
	:canada		= :america,
	:france		= :europe,
	:poland		= :europe,
	:niger		= :africa,
	:iraq		= :asia,
	:japan		= :asia,
	:panama		= :america,
	:argentina	= :america
])

? @@( o1.Classify() ) + NL
#--> [ 
#	:africa 	= [ "egypt", "tunisia", "niger" 	],
#	:asia 		= [ "saudi_arabia", "iraq", "japan" 	],
#	:america 	= [ "canada", "panama", :argentina	],
#	:europe 	= [ "france", :spain, "poland" 		]
#    ]

? @@( o1.Klass(:asia) )
#--> [ "saudi_arabia", "iraq", "japan" ]

pf()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.19
# Executed in 1.54 second(s) in Ring 1.17
