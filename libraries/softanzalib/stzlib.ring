
//t1 = clock()

load "stdlib.ring"

load "lightguilib.ring"
load "sqlitelib.ring"
load "tracelib.ring"
load "internetlib.ring"
load "typehints.ring"

//? (clock()-t1)/clockspersecond()
# 0.05 seconds in Ring 1.19
# 0.46 seconds in Ring 1.14

t1 = clock()

load "stzGlobal.ring"

load "stzTest.ring"

load "stzObject.ring"
load "stzObjectError.ring"
load "stzListOfObjects.ring"

load "stzNumber.ring"
load "stzNumberError.ring"
load "stzDecimalToBinary.ring"
load "stzDecimalToBinaryError.ring"

load "stzListOfNumbers.ring"

load "stzRandom.ring"

load "stzListOfUnicodes.ring"

load "stzBinaryNumber.ring"
load "stzBinaryNumberError.ring"
load "stzHexNumber.ring"
load "stzHexNumberError.ring"
load "stzOctalNumber.ring"
load "stzOctalNumberError.ring"

load "stzString.ring"
load "stzStringError.ring"
load "stzMultiString.ring"
load "stzMultiStringError.ring"
load "stzSubString.ring"

load "stzItem.ring"

load "stzStopWords.ring"
load "stzStopWordsData.ring"

load "stzListOfStrings.ring"

load "stzListOfStringsError.ring"
load "stzListInString.ring"

load "stzListOfBytes.ring"
load "stzListOfBytesError.ring"

load "stzChar.ring"
load "stzCharError.ring"
load "stzCharData.ring"

load "stzListOfChars.ring"
load "stzListOfCharsError.ring"

load "stzList.ring"
load "stzListError.ring"
load "stzHashList.ring"

load "stzListOfHashLists.ring"
load "stzSet.ring"

load "stzListOfLists.ring"

load "stzSplitter.ring"

load "stzListOfPairs.ring"

load "stzPair.ring"
load "stzPairOfNumbers.ring"
load "stzPairOfLists.ring"

load "stzListOfSets.ring"
load "stzListOfSetsError.ring"
load "stzPairOfLists.ring"
load "stzTree.ring"

load "stzWalker.ring"
load "stzTable.ring"

load "stzLocaleData.ring"
load "stzLocale.ring"
load "stzLocaleError.ring"

load "stzCountry.ring"
load "stzCountryError.ring"
load "stzLanguage.ring"
load "stzScript.ring"
load "stzCurrency.ring"

load "stzUnicodeData.ring"
load "stzListParser.ring"
load "stzGrid.ring"
load "stzGridError.ring"
load "stzCounter.ring"
load "stzCounterError.ring"

load "stzDate.ring"
load "stzTime.ring"
load "stzFile.ring"
load "stzFileError.ring"
load "stzFolder.ring"
load "stzRunTime.ring"
load "stzTextEncoding.ring"

load "stzTextEncodingError.ring"
load "stzNaturalCode.ring"
load "stzChainOfValue.ring"
load "stzChainOfTruth.ring"
load "stzEntity.ring"
load "stzEntityError.ring"
load "stzListOfEntities.ring"
load "stzListOfEntitiesError.ring"

load "stzText.ring"
load "stzStringArt.ring"
load "stzConstraints.ring"
load "stzConstraintsData.ring"

load "stzCCode.ring"
load "stzExtCode.ring"

load "stzNullObject.ring"
load "stzTrueObject.ring"
load "stzFalseObject.ring"

load "stzDistanceZero.ring"

//? (clock()-t1)/clockspersecond()

# Softanza startup time :
# 	0.02s in Ring 1.19
#	0.04s in Ring 1.14
