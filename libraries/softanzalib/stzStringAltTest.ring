load "stzlib.ring"


pron()

o1 = new stzStringAlt("<<♥♥>>emm<<❀❀>>!")

? @@S( o1.AnySectionsBetween("<<", ">>") )
#--> [ "♥♥", "❀❀" ]

proff()
