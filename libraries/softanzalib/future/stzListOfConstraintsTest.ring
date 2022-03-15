load "stzlib.ring"

oStr = StzStringQ("salem")


? IsListOfConstraints(oStr, [
	:JustFive = '{ @.NumberOfChars() <= 5 }',
	:OnlyLowercase = '{ @Lowercased() = TRUE }',
	:NoNumbers = '{ @.ContainsNumbers() = FALSE }' ])
