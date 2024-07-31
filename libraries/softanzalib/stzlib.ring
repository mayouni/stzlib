
//t1 = clock()

load "stdlibcore.ring"
load "lightguilib.ring" # Takes most of the time made by non-Softanza libraries
#TODO // Replace with "ringqtcorelib.ring" when included in future Ring.
      // test it with:
      // load "../libraries/guilib/classes/ring_qtcore.ring"
      // loadlib("ringqt_core.dll")
      // But don't keep it because we will not be able to use load "guilib.ring" or "lightguilib.ring"

load "sqlitelib.ring"
load "tracelib.ring"
load "internetlib.ring"
load "typehints.ring"

//? (clock()-t1)/clockspersecond()
# Loading libraries takes 0.06

#TODO optimise the load time of lightguilib.ring by loading only the
# qt classes used in RingQt by Softanza:
# Qfile, QFileInfo, QTextStream, QStringList, QChar, QString2, QDate, QDir,
# QLocale, QByetArray, QTextCodec, QTime

load "stzGlobal.ring"
load "stzTest.ring"

load "stzObject.ring"
load "stzObjectError.ring"
load "stzListOfObjects.ring"

load "stzNullObject.ring"
load "stzTrueObject.ring"
load "stzFalseObject.ring"

load "stzNumber.ring"
load "stzNumberError.ring"
load "stzDecimalToBinary.ring"
load "stzDecimalToBinaryError.ring"

load "stzListOfNumbers.ring"

load "stzRandom.ring"
load "stzRandomData.ring"

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
load "stzSortedList.ring"

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

load "stzTextEncoding.ring"

load "stzTextEncodingError.ring"

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

load "stzDistanceZero.ring"
load "stzSection.ring"

load "stzNaturalCode.ring"

load "stzRingInstance.ring"

# Loading Softanza Systems

load "stzGlobSys.ring"
load "stzProfSys.ring"
load "stzArchSys.ring"
load "stzShowSys.ring"
load "stzPlugSys.ring"

# Loading additional Softanza Utilities

load "stzSmallFunc.ring"
load "stzQtFunc.ring"

//? (clock()-t1)/clockspersecond()

# Softanza global startup time : 0.10 second(s) in Ring 1.20 (64 bits)
# External libraries loading time: 0.06 second(s). Most is taken by lightguilib.ring
# Softanza files loading time : 0.04 second(s)

