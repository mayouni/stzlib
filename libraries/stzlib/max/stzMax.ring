# This file loads the MAX layer of SoftanzaLib (along with its CORE and BASE layers)
#
# Architecture: Core (stk*) -> Base (stz*) -> Max (stx*)
#
# The Max layer extends Base with advanced features: walkers, parsers,
# big numbers, multi-strings, text encoding, binary files, the testing
# framework, and the wings plugin system.
#
# NOTE: Files already loaded by the Base layer are NOT re-loaded here.
# Max only adds what is genuinely new at this level.

# Loading the Softanza Base layer (which loads Core layer underneath)

    load "../base/stzBase.ring"

# Loading files related to the COMMON module

    load "common/stzWalker.ring"
    load "common/stzListOfWalkers.ring"
    load "common/stzWalker2D.ring"
    load "common/stzListOfWalkers2D.ring"
    load "common/stzParser.ring"

    load "common/stzGlobalHelp.ring"

# Loading files related to the DATA module

    load "data/stzConstraintsData.ring"
//  load "data/stzStopWordsData.ring"
    load "data/stzDataModelData.ring"

# Loading files related to the NUMBER module

    load "number/stzBigNumber.ring"
    load "number/stzListOfListsOfNumbers.ring"
    load "number/stzListOfPairsOfNumbers.ring"

    load "number/stzNumberLowLevelType.ring"

# Loading files related to STRING module

    load "string/stzMultiString.ring"
    load "string/stzSringConstraints.ring"
    load "string/stzTextEncoding.ring"

# Loading files related to the SYSTEM module

    load "system/stzBinaryFile.ring"

# Loading files related to the TEST module

    load "test/stzTestoor.ring"

# Loading files related to the ERROR module

    load "error/stzGridError.ring"
    load "error/stzListOfSetsError.ring"
    load "error/stzMultiStringError.ring"
    load "error/stzSetError.ring"
    load "error/stzTextEncodingSystemError.ring"

# Loading files related to WINGS modules

//  load "wings/stzWings.ring"
