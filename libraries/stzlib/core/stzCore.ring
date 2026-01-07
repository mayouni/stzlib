# This file loads the CORE layer of SoftanzaLib

# Loading external extensions

    //load "lightguilib.ring"

# Loading files in COMMON module

    load "common/stkglobals.ring"
    load "common/stklistcommons.ring"
    load "common/stklowlevelfuncs.ring"
    load "common/stknumbercommons.ring"
    load "common/stkobjectcommons.ring"
    load "common/stkringfuncs.ring"
    load "common/stkringlibs.ring"
    load "common/stkstringcommons.ring"
    load "common/stkprofiler.ring"

# Loading files in ERROR module

    load "error/stkerror.ring"

# Loading files in OBJECT module

    load "object/stkobject.ring"

# Loading files in LIST module

    load "list/stklist.ring"

# Loading files in NUMBER module

    load "number/stknumber.ring"
    load "number/stklistofnumbers.ring"
    load "number/stkscinumber.ring"

# Loading files in STRING module

    load "string/stkstring.ring"
    load "string/stkchar.ring"

# Loading files in SystEM module

    load "system/stkpointer.ring"
    load "system/stkbuffer.ring"
    load "system/stkmemory.ring"
