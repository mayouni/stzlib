# Narrative
# --------
# #TODO adjust lines under titles
#
# Extracted from stzhashlisttest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzHashList([
	:name = 	[ "foued", "karima", "wissal" ],
	:prename = 	[ "kamel", "ayouni", "salhi"  ],
	:job = 		[ "tutor", "coach",  "tutor"  ]
])

o1.ToStzTable().Show()
#-->   NAME   PRENAME     JOB
#      ----- --------- ----
#       foued     kamel   tutor
#      karima    ayouni   coach
#      wissal     salhi   tutor

pf()
