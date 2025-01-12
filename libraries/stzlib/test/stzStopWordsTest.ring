load "../max/stzmax.ring"

pr()

? ShowShort( StopWordsIn(:English)  ) + NL
#--> [ "a's", "able", "about", "...", "yourself", "yourselves", "zero" ]

? ShowShort( StopWordsIn(:Arabic)  )
#o--> [ "من", "إلى", "على", "في", "ك", "س", "ف", "لو" ]

? StopWordLanguage("my")
#--> :English

? StopWordLanguage("لو")
#--> :Arabic

proff()
# Executed in 0.39 second(s) in Ring 1.21
