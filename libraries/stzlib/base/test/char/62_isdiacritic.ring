# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #62.

load "../../stzBase.ring"

pr()

? StzCharQ("ỳ").IsDiacritic() #--> TRUE
? StzCharQ("ỳ").Name() #--> LATIN SMALL LETTER Y WITH GRAVE

? StzCharQ("ž").IsDiacritic() #--> TRUE
? StzCharQ("ž").Name() #--> LATIN SMALL LETTER Z WITH CARON

? StzCharQ("đ").IsDiacritic() #--> TRUE
? StzCharQ("đ").Name() #--> LATIN SMALL LETTER D WITH STROKE

? StzcharQ("é").IsDiacritic() #--> TRUE
? StzcharQ("é").Name() #--> LATIN SMALL LETTER E WITH ACUTE

? StzCharQ("ῃ").IsDiacritic() #--> FALSE
? StzCharQ("ῃ").Name() #--> GREEK SMALL LETTER ETA WITH YPOGEGRAMMENI

? StzCharQ("ὸ").IsDiacritic() #--> FALSE
? StzCharQ("ὸ").Name() #--> GREEK SMALL LETTER OMICRON WITH VARIA

? StzCharQ("ὑ").IsDiacritic() #--> FALSE
? StzCharQ("ὑ").Name() #--> GREEK SMALL LETTER UPSILON WITH DASIA

? StzCharQ("ē").IsDiacritic() #--> TRUE
? StzCharQ("ē").Name() #--> LATIN SMALL LETTER E WITH MACRON

? StzCharQ("ُ").IsDiacritic() #--> TRUE
? StzCharQ("ُ").Name() #--> ARABIC DAMMA

? StzCharQ("׳").IsDiacritic() #--> FALSE
? StzCharQ("׳").Name() #--> HEBREW PUNCTUATION GERESH

pf()
# Executed in 0.37 second(s) in Ring 1.23
