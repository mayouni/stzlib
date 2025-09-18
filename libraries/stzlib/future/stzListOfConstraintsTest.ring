load "../stzlib.ring"

oStr = StzStringQ("salem")


? IsListOfConstraints(oStr, [
	:JustFive = '{ @.NumberOfChars() <= 5 }',
	:OnlyLowercase = '{ @Lowercased() = 1 }',
	:NoNumbers = '{ @.ContainsNumbers() = 0 }' ])
