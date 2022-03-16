load "stzlib.ring"

? StzStringQ("MustHave@32@Chars").ExtractBetween("@","@")

/*
StzStringQ("softanza") {

	CheckConstraint(:MustBeUppercase)
	CheckConstraint(:MustHave@8@Chars)

}




? ConstraintRingCode(:MustBeUpperCase, :OnStzString)
# :MustBeUpperCase contains no dynamic pars (bounded by @ and @),
# so we return its corresponding Ring code in stzConstraintsData as is:
# --> 'Q(@str).IsUpperCase()'

? ConstraintRingCode(:MustHave@8@CharsIncluding@2@Spaces)
# :MustHave@n@Chars contains a dynamic part.
# In stzConstraintData.ring:

#	-> the corrosponding constraint name is:
#	   'MustHave@n1@charsIncluding@n2@Spaces, and

#	-> the corrosponding ring code is:
#	   'Q(@str).NumberOfChars() = n1 and Q(@str).NumberOfSpaces() = n2'

/* Steps

	If the name of constraint provided contains no @_@

		--> find it in the constraints repo
		--> if existant, take its code as-is

	else
		:MustHave@8@CharsIncluding@2@Spaces

		Step 1. Extract the dynamic parts --> [ 8, 2]

		Step 2. Replace the dynamic parts in the param with _
		--> :MustHave@_@CharsIncluding@_@Spaces
		
		Step 3. Check if sutch a template exists in the repo
			- Loop over the constraint names
			- for each name, replace the dynamic parts with _
			- compare with the template in step 2 and 

			- if the same template exists then take its
			corrosponding ring code

			Q(@str).NumberOfChars()  = n1 and
			Q(@stz).NumberOfSpaces() = n2

		Step 4. Replace the dynamic parts we had in step 1 
			in the Ring code we have in Step 3

			Q(@str).NumberOfChars()  = 8 and
			Q(@stz).NumberOfSpaces() = 2

	ok


:MustBegingWith@substr@ = '{
			Q(@str).BeginsWith(susbtr)
		}


func GenerateConstraint(pcConstraintName, pcOnStzClass)
	
