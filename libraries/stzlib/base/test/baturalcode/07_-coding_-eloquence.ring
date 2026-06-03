# Narrative
# --------
# #natural-coding #semantic-eloquence
#
# Extracted from stzbaturalcodetest.ring, block #7.

load "../../stzBase.ring"

pr()

? Q("ring").IsAString()
#--> TRUE

? Q("ring").IsStzString()
#--> TRUE


? Q("ring").IsA(:String)
#--> TRUE

? Q("ring").IsAXT([ :Lowercase, :Latin, :String ])
#--> TRUE

? Q("ring").IsAXT([ :String ])
#--> TRUE

? QM("ring").IsAXTQ([ :Lowercase, :Latin, :String ]).WhichQ().HasAQ().LengthQ().EqualTo(4)
#--> TRUE

? TheStringQM("ring").IsAQ([ :Lowercase, :Latin, :String ]).WithAQ().LengthQ().Of(4)
#--> TRUE

? TheWordQM("ring").IsAQ([ :Lowercase, :Latin, :Word ]).WithAQ().LengthQ().OfXT(4, :Letters)
#--> TRUE

? TheWordQM("ring").IsAQ([ :Lowercase, :Latin, :Word ]).
  WithQ().ALengthQ().OfQ(4)._Q(:Letters).AndQ().OnlyQM(1).VowelNB()
#--> TRUE

? TheWordQ("ring").HasNQ(4).LettersNB()
#--> TRUE

? TheWordQ("ring").HasNQ(4).LowercaseBQ().LettersNB()
#--> TRUE

? TheWordQ("ring").HasNQ(4).LettersNBQ().ThatAreQ().InLowercase()
#--> TRUE

? Q("ring").IsAQ([ :Lowercase, :Latin, :Word ]).WhichQ().HasTheNumberQ(4).AsAQ().NumberOfCharsB()
#--> TRUE

? Q("ring").IsTheQ([ :Lowercase, :string ]).WhichIsQ().TheQ().ReverseOfB("gnir")
#--> TRUE

pf()
# Executed in 0.38 second(s) in Ring 1.23
# Executed in 0.60 second(s) in Ring 1.20
