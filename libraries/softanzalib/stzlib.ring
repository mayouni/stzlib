
#~~~~~~~~~~~~~~~~~~#
#  IMPORTANT NOTE  #
#~~~~~~~~~~~~~~~~~~#

# NOTE: Softanza software design is being refactored according to these 7 principles:

# Layered:
#~~~~~~~~~

#	Structured into SoftanzaCore, SoftanzaStandard, and SoftanzaExtended.

#	The three levels have the same fold structure (there is a class for managing
#	string in each level : stzCoreString, stzString, and stzStringXT.

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
# 	used classes and methods.

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
#	format to enable its export to HTML, PDF or other formats.

#~~~~~~~~~~~~~~~~~~~~~~~~#
#  END OF THE NOTE NOTE  #
#~~~~~~~~~~~~~~~~~~~~~~~~#

# t0 = clock()

# Loding the files related to the CORE layer

	load "core/stzCoreLib.Ring"	

# Loading files related to the OBJECT module

	load "object/stzObject.ring"
	load "error/stzObjectError.ring"
	load "object/stzListOfObjects.ring"

# Loading files related to the NUMBER module

	load "number/stzNumber.ring"
	load "error/stzNumberError.ring"

	load "number/stzDecimalToBinary.ring"
	load "error/stzDecimalToBinaryError.ring"
	
	load "number/stzPairOfNumbers.ring"
	load "number/stzListOfNumbers.ring"
	
	load "number/stzRandom.ring"

	load "number/stzBinaryNumber.ring"
	load "error/stzBinaryNumberError.ring"

	load "number/stzHexNumber.ring"
	load "error/stzHexNumberError.ring"

	load "number/stzOctalNumber.ring"
	load "error/stzOctalNumberError.ring"

	load "number/stzListOfBytes.ring"
	load "error/stzListOfBytesError.ring"

# Loading files related to the LIST module

	load "list/stzList.ring"
	load "error/stzListError.ring"

	load "list/stzSortedList.ring"

	load "list/stzHashList.ring"
	load "list/stzListOfHashLists.ring"
	load "list/stzSet.ring"
	
	load "list/stzListOfLists.ring"
	load "list/stzListOfPairs.ring"
	load "list/stzPair.ring"
	load "list/stzPairOfLists.ring"
	
	load "list/stzListOfSets.ring"
	load "error/stzListOfSetsError.ring"
	
	load "list/stzTable.ring"
	load "list/stzTree.ring"
	load "list/stzGrid.ring"
	load "error/stzGridError.ring"

	load "list/stzItem.ring"
	load "list/stzListParser.ring"

	load "list/stzListInString.ring"

# Loading files related to the STRING module

	load "string/stzString.ring"
	load "error/stzStringError.ring"

	load "string/stzMultiString.ring"
	load "error/stzMultiStringError.ring"

	load "string/stzSubString.ring"

	load "string/stzListOfStrings.ring"
	load "error/stzListOfStringsError.ring"

	load "string/stzChar.ring"
	load "error/stzCharError.ring"

	load "string/stzListOfChars.ring"
	load "error/stzListOfCharsError.ring"

	load "string/stzListOfUnicodes.ring"
	load "string/stzStringArt.ring"

# Loading files related tp the COMMON module

	load "common/stzFunctions.ring"
	load "common/stzSplitter.ring"
	load "common/stzWalker.ring"

	load "common/stzCounter.ring"
	load "common/stzCounterError.ring"

	load "common/stzSection.ring"

	load "common/stzSmallFunc.ring"
	load "common/stzQtFunc.ring"
	load "common/stzRingLibs.ring"

# Loading files related to the TEST module

	load "test/stzTest.ring"

# Loading files related to the DATA mlodule

	load "data/stzLocaleData.ring"
	load "data/stzStopWordsData.ring"

//	load "data/stzUnicodeData.ring"		#TODO check error!

	load "data/stzConstraintsData.ring"
	load "data/stzRandomData.ring"
	load "data/stzCharData.ring"

# Loading files related to the I18N module (part of SoftanzaExtend layer)

	load "extended/i18n/stzLocale.ring"
	load "error/stzLocaleError.ring"	# ? Shoudld add extended/error/ folder?

	load "extended/i18n/stzCountry.ring"
	load "error/stzCountryError.ring"

	load "extended/i18n/stzLanguage.ring"
	load "extended/i18n/stzScript.ring"
	load "extended/i18n/stzCurrency.ring"

	load "extended/i18n/stzDate.ring"
	load "extended/i18n/stzTime.ring"

	load "extended/i18n/stzStopWords.ring"

# Loading files related to the IO module

	load "io/stzFile.ring"
	load "error/stzFileError.ring"

	load "io/stzFolder.ring"
	load "io/stzExtCode.ring"

# Files related to NATURAL module (part of SoftanzaExtended layer)

	load "extended/natural/stzChainOfValue.ring"
	load "extended/natural/stzChainOfTruth.ring"

	load "extended/natural/stzEntity.ring"
	load "error/stzEntityError.ring"

	load "extended/natural/stzListOfEntities.ring"
	load "error/stzListOfEntitiesError.ring"

	load "extended/natural/stzText.ring"
	load "extended/natural/stzConstraints.ring"

	load "extended/natural/stzCCode.ring"

	load "extended/natural/stzNullObject.ring"
	load "extended/natural/stzTrueObject.ring"
	load "extended/natural/stzFalseObject.ring"

# Loading the files related to SYSTEMS module (par of SoftanzaExtended layer)

	load "extended/systems/stzArchSys.ring"
	load "extended/systems/stzProfilingSystem.ring"
	load "extended/systems/stzShowSystem.ring"

	load "extended/systems/stzTextEncodingSystem.ring"
	load "error/stzTextEncodingSystemError.ring"

# loading MISC files

	load "misc/stzDistanceZero.ring"

# ? (clock()-t0)/clockspersecond()
#--> 0.06 seconds (Ring 1.20 64-bit)
