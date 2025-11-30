# This file loads the MAX layer of SoftanzaLib (along with it's CORE and BASE layers)

# Loading the Softanza Base layer (which loads Core layer in behind)

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

# Loading files related to OBJECT module

    #TODO // Abstract stzTrueObject, stzFalseObject, stzNullObject,
    # and stzNamedObject here in the MAX layer

# Loading files related to the NUMBER module

    load "number/stzbignumber.ring"
    load "number/stzlistoflistsofnumbers.ring"
    load "number/stzlistofpairsofnumbers.ring"

    load "number/stznumberlowleveltype.ring"


# Loading files related to STRING module

    load "string/stzmultistring.ring"
    load "string/stzstringconstraints.ring"
    load "string/stztextencoding.ring"

# Loading files related to the LIST module

    load "list/stzlist2d.ring"
    load "list/stzlistparser.ring"
    load "list/stzlistprovidedasstring.ring"

    load "list/stzsortedlist.ring"
    load "list/stzpivottable.ring"
    load "list/stzpivottableshow.ring"

    load "list/stztree.ring"

    load "list/stzgrid.ring"
    load "list/stzlistofgrids.ring"
    load "list/stztile.ring"

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
