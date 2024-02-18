load "stzlib.ring"

pron()

? AWord()
#--> "square"

? Five( Words() )
#--> [ "apple", "yacht", "truck", "station", "base" ]

? Three( ArabicWords() )
#o-> [ "كلمة", "كرسيّ", "شجرة" ]

? Q([]).FilledWith( Four( FrenchWords() ) )
#--> [ "question", "chien", "lampe", "chat" ]

? Q("").FilledWith( AnEnglishWord() + ' & ' + AFrenchWord() )
#--> question & soleil

proff()
# Executed in 0.04 second(s)

