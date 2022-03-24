/*
A bunch of functions to generate some code used in the library.

NOTE: This file is used only in development mode.
It's not inculded in the library in the runtime.

The result of these functions are ususally some code or data that
we need to include in the library files.

*/

load "stzlib.ring"

//? GenerateCodeFor(:IsStzTypeFunction)

? ListOfLocaleAbbreviations()

func GenerateCodeFor(pcFunction)

	switch pcFunction

	on :IsStzTypeFunction
		/* Generates the equivalent of this code to every stzClass:

		func IsStzNumber(pObject)
			if isObject(pObject) and classname(pObject) = "stznumber"
				return TRUE
			else
				return FALSE
			ok

		NOTE:
		stzObject is not included to this code generation operation, because
		the logic of IsStzOject relies on a different logic.

		In fact, all the softanza objects (whatever class they are created from
		are considered stzObjects (an not only the one created from stzObject class)
		*/

		cCode = ''
		aStzClasses = StzListQ(StzClasses()).RemoveQ("stzobject").Content()
		for cStzClass in aStzClasses

			type = (StzStringQ(cStzType) - "stz").Content()

			cCode +=
			'func IsStz' + type + '(pObject)' + NL +
			'	if isObject(pObject) and classname(pObject) = "' + cStzType + '"' + NL +
			'		return TRUE' + NL +
			'	else' + NL +
			'		return FALSE' + NL +
			'	ok' + NL + NL

		next

		return cCode

	off

func ListOfLocaleAbbreviations()
	aResult = []

	for acountry in LocaleAbbreviationsXT()
		for aLanguage in aCountry[2]
			for aLocale in aLanguage
				aResult + aLocale[2]
			next
		next
	next

	return aResult
