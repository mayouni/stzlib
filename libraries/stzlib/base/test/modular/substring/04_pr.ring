# Narrative
# --------
# pr()
#
# Extracted from stzsubstringTest.ring, block #4.

load "../../../stzBase.ring"


? Q("ring").InQ("I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? Q("ring").SubStringInQ("I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? The("ring").SubStringInQ("I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? TheQ("ring").SubStringInQ("I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? Q("ring").SubstringQ( :In = "I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? TheQ("ring").SubStringQ( :In = "I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? The("ring").SubStringQ( :In = "I LOVE ring LANGUAGE!" ).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? SubStringQ("ring").InQ("I LOVE ring LANGUAGE!").Uppercased()
#--> I LOVE THE RING LANGUAGE!

? TheSubStringQ("ring").InQ("I LOVE ring LANGUAGE!").Uppercased()
#--> I LOVE THE RING LANGUAGE!

? SubStringQ([ "ring", :In = "I LOVE ring LANGUAGE!" ]).Uppercased()
#--> I LOVE THE RING LANGUAGE!

? TheSubStringQ([ "ring", :In = "I LOVE ring LANGUAGE!" ]).Uppercased()
#--> I LOVE THE RING LANGUAGE!

pf()
# Executed in 0.05 second(s) in Ring 1.22
# Executed in 0.16 second(s) in Ring 1.21
