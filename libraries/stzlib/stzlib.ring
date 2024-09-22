
#~~~~~~~~~~~~~~~~~~#
#  IMPORTANT NOTE  #
#~~~~~~~~~~~~~~~~~~#

# NOTE: Softanza software design is being refactored according to these 7 principles:

# Layered:
#~~~~~~~~~

#	Structured into SoftanzaCore, SoftanzaStandard, and SoftanzaExtended.

#	The three levels have the same fold structure. For example, there is
#	a class for managing string in each level : stzCoreString, stzString,
#	and stzStringXT. And so on.

#	Each layer utilizes the one beneath it, and enhancements made to a lower
#	layer automatically benefit those above.

# Modular:
#~~~~~~~~~

#	Classes are organized by functional domain, and the codebase's folder
#	structure clearly reflects these domains. The four main domains are
# 	the four types supported by Ring : NUMBER, STRING, LIST, and OBJECTS.

# Granular:
#~~~~~~~~~~

#	Programmers can operate at desired abstraction levels:

#	~> By using only the required layer:

#		=> SoftanzaCore: for basic features, efficiency, small code,
#		   or performance-critical development on supported platforms
# 		   (web, mobile, microcontrollers, MS-DOS).

# 		=> SoftanzaStandard: for a wide range of functionalities covering
# 		   number, character, string, and list management.

# 		=> SoftanzaExtended: for advanced features enabling innovative,
#		   industry-grade software solutions (natural coding, knowledge-oriented,
# 		   plugin-based, memory profiling, workflow processing, etc.).

#		=> By using only necessary modules: If only STRING management is needed,
#		   load STRING-related files from the selected layer.

#		=> By loading only specific files: For example, load /core/stzCoreChar.ring
# 		   for unicode character operations.

# Configurable:
#~~~~~~~~~~~~~~

#	Library gymnastics, that may not be loved by every one, like function alternative
#	forms, misspelled forms, multilingual forms, and case sensitivity can be dynamically
#	configured for each object at runtime. Programmers specify tuning using syntax like:

#		Use([
#			:stzStringClass = [
# 				:@AllAlternativeForms,
#				:@TheseMisspelledForms = [ ..., ... ],
#				:@NFirstMultilingualForms = 10, etc ]
#			],

#			stzListClass = [ ... ]
#	        ]

# Optimized:
#~~~~~~~~~~~

#	A future script will create, based on a codebase that uses Softanza,
#	a lightweight, dependency-free library (SoftanzaMine) containing only
# 	used classes and methods in that particular codebase.

#	SoftanzaMine can be generated as a standalone executable or DLL
#	for deployment with applications, potentially callable from external
# 	languages via a wrapper class.

# APIfied:
#~~~~~~~~~

#	All Softanza classes, modules, or layers can be delivered as
#	a unified service-oriented API under a dedicated application
#	server working over HTTP. This allows the use of the library
#	in a production setting, on the cloud or in promise, in
#	developing web and mobile backend services, and professional
#	client server applications.

# Battle-tested & documented
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#	All Softanza classes and functions are made hand in hand with
#	tests crafted at design time, and then enritched, by using
#	the library in solving several real world algorithmic cases.

#	The library is carefelly documented through comments inside
#	the code base and a set of narrations prvided as test samples.
#	A documentation file is made to each class, in a strcutered
#	format to enable its export to HTML, PDF or other forms.

#~~~~~~~~~~~~~~~~~~~~~~~~#
#  END OF THE NOTE NOTE  #
#~~~~~~~~~~~~~~~~~~~~~~~~#

//decimals(3)
//t0 = clock()

# Loding the files related to the CORE layer

	load "core/stzCoreLib.Ring"	

# Loading files related to the OBJECT module

	load "object/stzObject.ring"
	load "error/stzObjectError.ring"
	load "object/stzListOfObjects.ring"
	load "object/stzNullObject.ring"
	load "object/stzTrueObject.ring"
	load "object/stzFalseObject.ring"

# Loading files related to the NUMBER module

	load "number/stzNumber.ring"
	load "number/stzDecimalToBinary.ring"
	load "number/stzPairOfNumbers.ring"
	load "number/stzListOfNumbers.ring"
	load "number/stzRandom.ring"
	load "number/stzBinaryNumber.ring"
	load "number/stzHexNumber.ring"
	load "number/stzOctalNumber.ring"
	load "number/stzListOfBytes.ring"

# Loading files related to the LIST module

	load "list/stzList.ring"
	load "list/stzSortedList.ring"
	load "list/stzHashList.ring"
	load "list/stzListOfHashLists.ring"
	load "list/stzSet.ring"
	load "list/stzListOfLists.ring"
	load "list/stzListOfPairs.ring"
	load "list/stzPair.ring"
	load "list/stzPairOfLists.ring"
	load "list/stzListOfSets.ring"
	load "list/stzTable.ring"
	load "list/stzTree.ring"
	load "list/stzGrid.ring"
	load "list/stzItem.ring"
	load "list/stzListParser.ring"
	load "list/stzListInString.ring"

# Loading files related to the STRING module

	load "string/stzString.ring"
	load "string/stzMultiString.ring"
	load "string/stzSubString.ring"
	load "string/stzListOfStrings.ring"
	load "string/stzChar.ring"
	load "string/stzListOfChars.ring"
	load "string/stzListOfUnicodes.ring"
	load "string/stzStringArt.ring"

# Loading files related tp the COMMON module

	load "common/stzFuncs.ring"
	load "common/stzSplitter.ring"
	load "common/stzWalker.ring"
	load "common/stzCounter.ring"
	load "common/stzSection.ring"
	load "common/stzSmallFuncs.ring"
	load "common/stzQtFuncs.ring"
	load "common/stzRingLibs.ring"

# Loading files related to ERROR module

	load "error/stzNumberError.ring"
	load "error/stzDecimalToBinaryError.ring"
	load "error/stzBinaryNumberError.ring"
	load "error/stzHexNumberError.ring"
	load "error/stzOctalNumberError.ring"
	load "error/stzListOfBytesError.ring"
	load "error/stzListError.ring"
	load "error/stzListOfSetsError.ring"
	load "error/stzGridError.ring"
	load "error/stzStringError.ring"
	load "error/stzMultiStringError.ring"
	load "error/stzListOfStringsError.ring"
	load "error/stzCharError.ring"
	load "error/stzListOfCharsError.ring"
	load "error/stzCounterError.ring"
	load "error/stzLocaleError.ring"
	load "error/stzCountryError.ring"
	load "error/stzEntityError.ring"
	load "error/stzListOfEntitiesError.ring"
	load "error/stzTextEncodingSystemError.ring"

# Loading files related to the TEST module

	load "test/stzTest.ring"

# Loading files related to the DATA mlodule

	load "data/stzLocaleData.ring"
	load "data/stzStopWordsData.ring"
	load "data/stzUnicodeData.ring"
	load "data/stzConstraintsData.ring"
	load "data/stzRandomData.ring"
	load "data/stzCharData.ring"

# Loading files related to the MAX/I18N module (part of SoftanzaMax layer)

	load "max/i18n/stzLocale.ring"
	load "max/i18n/stzCountry.ring"
	load "max/i18n/stzLanguage.ring"
	load "max/i18n/stzScript.ring"
	load "max/i18n/stzCurrency.ring"
	load "max/i18n/stzDate.ring"
	load "max/i18n/stzTime.ring"
	load "max/i18n/stzStopWords.ring"

# Loading files related to the IO module

	load "io/stzFile.ring"
	load "error/stzFileError.ring"
	load "io/stzFolder.ring"
	load "io/stzExtCode.ring" // #TODO Is this the right place?

# Files related to MAX/NATURAL module (part of SoftanzaMax layer)

	load "max/natural/stzChainOfValue.ring"
	load "max/natural/stzChainOfTruth.ring"
	load "max/natural/stzEntity.ring"
	load "max/natural/stzListOfEntities.ring"
	load "max/natural/stzText.ring"
	load "max/natural/stzConstraints.ring"
	load "max/natural/stzCCode.ring"
	load "max/natural/stzNaturalCode.ring"

# Loading the files related to MAX/SYSTEMS module (par of SoftanzaMax layer)

	load "max/systems/stzArchSys.ring"
	load "max/systems/stzProfilingSystem.ring"
	load "max/systems/stzShowSystem.ring"
	load "max/systems/stzTextEncodingSystem.ring"

# loading MISC files

	load "misc/stzDistanceZero.ring"

//? (clock()-t0)/clockspersecond()
#--> 0.06 seconds (Ring 1.20 64-bit)
