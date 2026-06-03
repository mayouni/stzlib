# Narrative
# --------
# $CustomLogo = "
#
# Extracted from stzstringarttest.ring, block #23.
#ERR exit 1: Error (S1) In file: 23_customlogo.ring

load "../../stzBase.ring"

pr()

   ____  _
  / __ \(_)____  ____ _
 / /_/ / / ___/ / __ `/
/ _, _/ / /    / /_/ /
/_/ |_/_/_/     \__,_/
"

? StringArt("#{customLogo}")


#~~~~~~

? NL + "~~~~~~~"

t = (clock() - t0) / clockspersecond()
? "Executed in " + t + " seconds."

pf()
