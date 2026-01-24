# This file loads the BASE layer of SoftanzaLib (along with its CORE layer)

# Giving priority to user code config (suggested by Mahmoud)
if NOT isGlobal(:$aStzLibConfig ) #TODO // Make it a stzlibconfig.ring file
    $aStzLibConfig = []
ok

// tz0 = clock()

# Loding the files related to the CORE layer

    load "../core/stzcore.ring" 

# Loading files related tp the COMMON module

    load "common/stzcounter.ring"
    load "common/stzfuncs.ring"
    load "common/stznamedparams.ring" #TODO //Use it instead the equivalent code in stzList

    load "common/stzoccurrences.ring"
    load "common/stzqtfuncs.ring"
    load "common/stzringfuncs.ring"

    load "common/stzringlibs.ring"
    load "common/stzsmallfuncs.ring"
    load "common/stzsplitter.ring"

    load "common/stzccode.ring"
    load "common/stznamedvars.ring"

# Loading files related to the DATA module

    load "data/stzchardata.ring"
    load "data/stzunicodedata.ring"
    load "data/stzlocaledata.ring"
    load "data/stzregexdata.ring"
    load "data/stzrandomdata.ring"
    load "data/stzsystemcalldata.ring"

# Loading files related to the OBJECT module

    load "object/stzobject.ring"
    load "object/stzobjecthistory.ring"

    load "object/stzlistofobjects.ring"
    load "object/stzlistofnamedobjects.ring"
    load "object/stznullobject.ring"
    load "object/stztrueobject.ring"
    load "object/stzfalseobject.ring"

# Loading files related to the NUMBER module

    load "number/stznumber.ring" #TODO Check compatibiiliy with stkNumber in CORE layer
    load "number/stzlistofnumbers.ring"
    load "number/stzpairofnumbers.ring"

    load "number/stzbinarynumber.ring"
    load "number/stzdecimaltobinary.ring"
    load "number/stzhexnumber.ring"
    load "number/stzoctalnumber.ring"

    load "number/stzlistofbytes.ring"

    load "number/stzrandom.ring"
    load "number/stzscinumber.ring"

    load "number/stzfastpro.ring"
    load "number/stzmatrix.ring"

# Loading files related to the STRING module

    load "string/stzstringfunc.ring"
    load "string/stzstring.ring"

    load "string/stzlistofstrings.ring"
    load "string/stzboxedstring.ring"
    load "string/stzchar.ring"
    load "string/stzlistofchars.ring"
    load "string/stzlistofunicodes.ring"
    load "string/stzstringart.ring"
    load "string/stzsubstring.ring"

    load "string/stztext.ring"
    load "string/stzstopwords.ring"

# Loading files related to REGEX module

    load "regex/stzregex.ring"
    load "regex/stzregexmaker.ring"
    load "regex/stzlistex.ring"
    load "regex/stznumbrex.ring"
    load "regex/stztimex.ring"
    load "regex/stzmatrex.ring"
    load "regex/stztablex.ring"
    load "regex/stzgraphex.ring"

    load "regex/stzlistexuter.ring"
    load "regex/stzregexuter.ring"

# Loading files related to the LIST module

    load "list/stzhashlist.ring"
    load "list/stzitem.ring"
    load "list/stzlist.ring"
    load "list/stzlistinstring.ring"

    load "list/stzlistofhashlists.ring"
    load "list/stzlistoflists.ring"
    load "list/stzlistofpairs.ring"
    load "list/stzlistofsections.ring"

    load "list/stzlistofsets.ring"
    load "list/stzlistpaths.ring"
    load "list/stzlistshow.ring"
    load "list/stzpair.ring"

    load "list/stzpairoflists.ring"
    load "list/stzsection.ring"
    load "list/stzset.ring"
    load "list/stzsetofsections.ring"

    load "list/stztable.ring"
    load "list/stzlistoftables.ring"

# Loading files related to the GRAPH module

    load "graph/stzgraph.ring"
    load "graph/stzgraphrule.ring"

    load "graph/stzgraphquery.ring"

    load "graph/stzgraphplanner.ring"
    load "graph/stzknowledgegraph.ring"

    load "graph/stzdiagram.ring"
    load "graph/stzdiagramcolor.ring"

    load "graph/stzorgchart.ring"

    load "graph/stzworkflow.ring"

# Loading files related to the VISUAL module

    #TODO// Put here all visual-oriented functions and classes

# Loading files related to SYSTEM module

    load "system/stzsystemcall.ring"

    load "system/stzmemoryglobals.ring"
    load "system/stzmemoryconvertors.ring"
    load "system/stzoperatingsystem.ring"

    load "system/stzmemoryprofiler.ring"
    load "system/stzmemoryprofiler32bit.ring"
    load "system/stzmemoryprofiler64bit.ring"

    load "system/stzprofilingtimer.ring"

    load "system/stzpointer.ring"

    load "system/stzuuid.ring"

# Loading files related to the FILE module

    load "file/stzfile.ring"
    load "file/stzzipfile.ring"

    load "file/stzfolder.ring"

    load "file/stzjson.ring"
    load "file/stzcsv.ring"
    load "file/stzhtml.ring"

# Loading files related to the ERROR module

    load "error/stzobjecterror.ring"
    load "error/stzstringerror.ring"

    load "error/stzcountererror.ring"
    load "error/stzfileerror.ring"

    load "error/stzlisterror.ring"
    load "error/stzlistofbyteserror.ring"
    load "error/stzlistofstringserror.ring"

    load "error/stznumbererror.ring"
    load "error/stzbinarynumbererror.ring"
    load "error/stzhexnumbererror.ring"
    load "error/stzoctalnumbererror.ring"
    load "error/stzdecimaltobinaryerror.ring"

    load "error/stzcountryerror.ring"

# Loading files related to the DATETIME module

    load "datetime/stzdate.ring"
    load "datetime/stztime.ring"
    load "datetime/stzdatetime.ring"
    load "datetime/stzduration.ring"
    load "datetime/stztimeline.ring"
    load "datetime/stzcalendar.ring"

    load "datetime/stzlistoftimelines.ring"

# Loading files related to the I18N module

    load "i18n/stzcountry.ring"
    load "i18n/stzcurrency.ring"
    load "i18n/stzlanguage.ring"
    load "i18n/stzlocale.ring"
    load "i18n/stzscript.ring"
    load "i18n/stzcurrency.ring"

# Loading files related to the EXTINCODE module

    load "extincode/stzextincode.ring"
    load "extincode/stzextincsharp.ring"
    load "extincode/stzextinpython.ring"
    load "extincode/stzextinjs.ring"
    load "extincode/stzextinsql.ring"
    load "extincode/stzextinperl.ring"
    load "extincode/stzextinc.ring"

# Loading files related to the EXERCODE module

    load "extercode/stzextercode.ring"
    load "extercode/stzpythoncode.ring"
    load "extercode/stzrcode.ring"
    load "extercode/stzjuliacode.ring"
    load "extercode/stzprologcode.ring"

    load "extercode/stzdotcode.ring"

# Loading files related to the NETWORK module

    load "network/stznetwork.ring"
    load "network/stzhttpclient.ring"
    load "network/stzwebsocket.ring"
    load "network/stztcpclient.ring"
    load "network/stztcpserver.ring"
    load "network/stznetworkutils.ring"

# Loading files related to the REACTIVE module

    load "reactive/stzreactiveglobals.ring"
    load "reactive/stzreactive.ring"
    load "reactive/stzreactivetask.ring"

    load "reactive/stzreactivefunc.ring"
    load "reactive/stzreactiveobject.ring"

    load "reactive/stzreactivetimer.ring"
    load "reactive/stzreactivestream.ring"
    load "reactive/stzreactivehttp.ring"

# Loading files related to APPSERVER module (FUTURE)

    load "appserver/stzappserver.ring"
    load "appserver/stzapprequest.ring"
    load "appserver/stzappresponse.ring"
    load "appserver/stzapprouter.ring"
    load "appserver/stzcomputeengine.ring"
    load "appserver/stzcontextpool.ring"

# Loading files related to CLUSTER module (FUTURE)

    load "cluster/stzcluster.ring"
    load "cluster/stzclusternode.ring"
    load "cluster/stzrequestclassifier.ring"
    load "cluster/stzloadbalancer.ring"
    load "cluster/stzclustermanager.ring"
    load "cluster/stzclustermonitor.ring"

# Loading files related to NATURAL module

    load "natural/stzchainoftruth.ring"
    load "natural/stzchainofvalue.ring"
    load "natural/stzconstraints.ring"

    load "natural/stzentity.ring"
    load "natural/stzlistofentities.ring"

    load "natural/stznaturalcode.ring"
    load "natural/stznatural.ring"
    load "natural/stznaturalmarkup.ring"

    load "natural/stzadverb.ring"
    load "natural/stzplural.ring"
    load "natural/stzsingular.ring"
    load "natural/stzordinal.ring"

# Loading files related to STATS module

    load "stats/stzdataset.ring"
    load "stats/stzbarplot.ring"
    load "stats/stzhbarplot.ring"
    load "stats/stzmbarplot.ring"
    load "stats/stzsurfaceplot.ring"
    load "stats/stzscatterplot.ring"
    load "stats/stzhistogram.ring"
    load "stats/stzdatawrangler.ring"
    load "stats/stzcoeffextractor.ring"
    load "stats/stzlinearsolver.ring"

// tz1 = clock()
// ? "Softanza laoding time:"
// ? (tz1 - tz0) / clockspersecond() + NL
