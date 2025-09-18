load "../stzlib.ring"

StzStringQ("ring programming language") {

	EnforceConstraint('{
		@.IsLowercase()
	}')

	EnforceConstraint('{
		@.ContainsNoNumbers()
	}')


	Update("RING")

? CheckConstraints()
	? Content()
}


/*
oStr = new stzString("ring programming language")

? IsNamedConstraint(oStr, :JustFive = '{ @.NumberOfChars() <= 5 }')
? IsConstraint(oStr, :JustFive = '{ @.NumberOfChars() <= 5 }')

? IsConstraint(oStr, '{ @.NumberOfChars() <= 5 }')
? IsNamedConstraint(oStr, '{ @.NumberOfChars() <= 5 }')

/*

oStr = new stzString("Salem aleilokm no numbers!")

o1 = new stzConstraint(oStr, '{
	IsStzString(@) and
	@.NumberOfChars() < 30 and
	@.IsLowercase() and
	@.ContainsNoNumbers()
}')

? o1.CheckConstraint()

/*
o1 = new stzRule( oStr, '{
	if NOT IsStzString(@) return 0 ok
	if NOT @.IsLowercase() @.ApplyLowercase() ok
	if NOT @.NumberOfChars() = 30 @.SetNumberOfChars(30) ok
	if @.ContainsNumbers() @.RemoveNumbers() ok
'})
