# Narrative
# --------
# # Arabic Shaddah ("ّ ") is a considedred by Unicode as a diacritic,
#
# Extracted from stzTtexttest.ring, block #2.

load "../../stzBase.ring"

pr()

# say a special vocal sign that decorates the consonent letters like
# a, e, and i in latin languages.

? StzCharQ(ArabicShaddah()).IsArabicDiacritic() #--> TRUE

# Which is not correct. In fact, diacrirtcs in arabic are:
? @@( Arabic7araket() ) # [ "ُ ", "َ ", "ِ ", "ْ " ]

# As you see, ("ّ ") is not one of them. That's because the Shaddah
# is actually a letter and NOT a diacritic:

? StzCharQ(ArabicShaddah()).IsLetter() #--> TRUE

# In fact, Arabs use it as a short form for a stressed letter like the "د" in
# the word "مودّتي" (that we read as "mawaDDati" --> with a stressed D)

# Hence, when we ask Softanza for the list of letters in this word:

txt = "مودّتي"
? @@( TQ(txt).Letters() )
#--> Gives ["م", "و", "د", " ّ", "ت", "ي" ]

# the ("ّ ") is managed here as a letter a part. Softanza even help you to get
# Bua more explicit result, by replacing the shaddach char by the letter it
# actually represents:

? @@( TQ(txt).LettersXT([ :ManageArabicShaddah = 1 ]) )
#o--> [ "م", "و", "د", "د", "ت", "ي" ]

pf()
