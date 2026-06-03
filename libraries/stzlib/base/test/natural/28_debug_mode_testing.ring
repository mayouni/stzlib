# Narrative
# --------
# DEBUG MODE TESTING
#
# Extracted from stznaturaltest.ring, block #28.
#ERR Error (R14) : Calling Method without definition: findantisectionszz

load "../../stzBase.ring"


pr()

Nt = Naturally("")
Nt.EnableDebug()
Nt.Execute("
    Create a string with 'test'
    Show it
")

? "Debug entries: " + len(Nt.DebugLog())

pf()
? @@NL( Nt.DebugLog() )
#--> [
#	[
#		[ "timestamp", 2166 ],
#		[ "message", "Executing natural code" ]
#	],
#	[
#		[ "timestamp", 2166 ],
#		[ "message", "Code length: 45 chars" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Raw values: 7 items" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[1]: type=STRING, content="Create"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[2]: type=STRING, content="a"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[3]: type=STRING, content="string"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[4]: type=STRING, content="with"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[5]: type=STRING, content="test"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[6]: type=STRING, content="Show"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[7]: type=STRING, content="it"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Converting to semantic tokens" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'Create'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Semantic: CREATE_OBJECT" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'a'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Ignored" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'string'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Semantic: OBJECT_STRING" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'with'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Ignored" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'test'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Literal" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'Show'" ]
#	],
#	[
#		[ "timestamp", 2169 ],
#		[ "message", "  Semantic: OUTPUT_DISPLAY" ]
#	],
#	[
#		[ "timestamp", 2169 ],
#		[ "message", "Processing: 'it'" ]
#	],
#	[
#		[ "timestamp", 2169 ],
#		[ "message", "  Ignored" ]
#	],
#	[
#		[ "timestamp", 2169 ],
#		[ "message", "Tokens: 4" ]
#	],
#	[
#		[ "timestamp", 2170 ],
#		[ "message", "Generated code:" ]
#	],
#	[
#		[ "timestamp", 2170 ],
#		[
#			"message",
#			'oStr = StzStringQ("test")
#			? oStr.Content()
#			@result = oStr.Content()'
#		]
#	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.24
