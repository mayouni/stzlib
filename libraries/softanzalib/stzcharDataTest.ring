load "stzlib.ring"

/*-----------

/*-----------

? Q( CircledDigitUnicodes() ).MergedWith( CircledLatinLetterUnicodes() )

/*------------

# Do you knwo how many punctuation chars are theer in Unicode?
? NumberOfPunctuationChars() #--> 250

# See them all:
//? PunctuationChars()

# Unciode classifies them in two blocks: General and Supplemental.
# Let's see...

? NumberOfGeneralPunctuationChars() #--> 111

# They are liste here:
//? GeneralPunctuationChars()

? NumberOfSupplementalPunctuationChars() #--> 138

# You can see them here:
? SupplementalPunctuationChars()

/*--------------

? UnicodeDirectionsXT()[5][3]
