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

    load "../base/stzbase.ring"

# Loading files related to the COMMON module

    load "common/stzwalker.ring"
    load "common/stzlistofwalkers.ring"
    load "common/stzwalker2d.ring"
    load "common/stzlistofwalkers2d.ring"
    load "common/stzparser.ring"

    load "common/stzglobalhelp.ring"

# Loading files related to the DATA module

    load "data/stzconstraintsdata.ring"
//  load "data/stzstopwordsdata.ring"
    load "data/stzdatamodeldata.ring"

# Loading files related to the NUMBER module

    load "number/stzbignumber.ring"
    load "number/stzlistoflistsofnumbers.ring"
    load "number/stzlistofpairsofnumbers.ring"

    load "number/stznumberlowleveltype.ring"

# Loading files related to STRING module

    load "string/stzmultistring.ring"
    load "string/stzstringconstraints.ring"
    load "string/stztextencoding.ring"

# Loading files related to the SYSTEM module

    load "system/stzbinaryfile.ring"

# Loading files related to the TEST module

    load "test/stztestoor.ring"

# Loading files related to the ERROR module

    load "error/stzgriderror.ring"
    load "error/stzlistofsetserror.ring"
    load "error/stzmultistringerror.ring"
    load "error/stzseterror.ring"
    load "error/stztextencodingsystemerror.ring"

# Loading files related to WINGS modules

//  load "wings/stzwings.ring"
