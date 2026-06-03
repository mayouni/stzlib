# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #13.
#ERR Error (R14) : Calling Method without definition: firstcharq

load "../../stzBase.ring"

pr()

? Q([ "Ring", :and = "Ruby" ]).AreBothQ(:strings).HavingQ().TheirQ().FirstCharQ().EqualTo("R")
#--> TRUE

? Q([ "Ring", :and = "ruby" ]).AreTwoQ(:strings).HavingQ().TheirQ().FirstCharCSQ(WhatEverCaseItHas).EqualTo(TheLetter("R"))
#-> TRUE

? Q([ "Ring", :and = "Bing" ]).
  AreBothQ(:strings).HavingMQ().TheirQ().FirstCharsQ().InUppercaseQ().AndQ().TheirQM().LastCharQ().EqualTo("g")
#-> TRUE

? Q([ "Ring", :and = "Bing" ]).
  AreBothQ(:strings).HavingMQ().TheirQ().FirstCharsQ().InUppercaseQ().AndQ().TheirQM().LastCharQ().EqualTo("g")
#-> TRUE

pf()
# Executed in 0.11 second(s) in Ring 1.23
