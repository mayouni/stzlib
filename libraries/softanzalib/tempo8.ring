load "stzlib.ring"


if _("ring").IsA(:String).Which(:IsLowercase).Containing(TheLetter("g")).AndHaving('FirstChar() = "r"')._
	
	? "Got it!"
else
	? "Sorry. May be next time..."
ok

#--> Got it!






