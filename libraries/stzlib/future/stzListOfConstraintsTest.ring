load "../stzlib.ring"

oStr = StzStringQ("salem")


? IsListOfConstraints(oStr, [
	:JustFive = '{ @.NumberOfChars() <= 5 }',
	:OnlyLowercase = '{ @Lowercased() = _TRUE_ }',
	:NoNumbers = '{ @.ContainsNumbers() = _FALSE_ }' ])
