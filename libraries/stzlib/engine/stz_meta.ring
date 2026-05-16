# Softanza Engine -- Meta-Engine Ring Bridge
#
# Loads stz_meta.dll and provides high-level Ring functions
# that wrap the native meta-engine. This replaces:
#
#   - 1,566 IsXxxNamedParam() methods  -> EngineIsNamedParam()
#   - CheckingParams() boilerplate     -> engine-side param validation
#   - StzRaise() hand-crafted strings  -> EngineFormatError()
#   - addmethod() alias loops          -> EngineRegisterAlias()
#   - CS/Q/Passive wrapper methods     -> EngineApplyGenRules()
#
# Used by: base/common/stzfuncs.ring, all Stz* classes

if isWindows()
    $cStzMetaLib = $cEngineDir + "/zig-out/bin/stz_meta.dll"
but isLinux()
    $cStzMetaLib = $cEngineDir + "/zig-out/lib/libstz_meta.so"
but isMacOS()
    $cStzMetaLib = $cEngineDir + "/zig-out/lib/libstz_meta.dylib"
ok

if fexists($cStzMetaLib)
    $pStzMetaHandle = LoadLib($cStzMetaLib)
else
    # stz_meta is optional -- all functions have NULL-handle fallbacks
    $pStzMetaHandle = NULL
ok

#------------------------------------------------------------#
#  INITIALIZATION                                            #
#------------------------------------------------------------#

func EngineMetaInit()
    if $pStzMetaHandle != NULL
        stz_meta_init()
    ok

func EngineMetaShutdown()
    if $pStzMetaHandle != NULL
        stz_meta_shutdown()
    ok

#------------------------------------------------------------#
#  NAMED PARAM REGISTRY (replaces 1,566 IsXxxNamedParam)     #
#------------------------------------------------------------#

# Replaces:
#   def IsOfNamedParam()
#       if This.NumberOfItems() = 2 and
#          (isString(This.Item(1)) and This.Item(1) = :Of)
#           return 1
#       else
#           return 0
#       ok
#
# With a single hash-lookup:
#   EngineIsNamedParam("Of")  -->  1

func EngineIsNamedParam(cKeyword)
    if $pStzMetaHandle = NULL
        return 0
    ok
    return stz_meta_is_named_param(cKeyword)

# Replaces IsOneOfTheseNamedParams() which used eval() to
# dynamically build method names. Now does N hash lookups.
func EngineIsOneOfTheseNamedParams(paList, pacNames)
    if $pStzMetaHandle = NULL
        return 0
    ok

    if NOT isList(paList)
        return 0
    ok

    if len(paList) != 2
        return 0
    ok

    if NOT isString(paList[1])
        return 0
    ok

    nLen = len(pacNames)
    for i = 1 to nLen
        if ring_lower(paList[1]) = ring_lower(pacNames[i])
            if EngineIsNamedParam(pacNames[i])
                return 1
            ok
        ok
    next

    return 0

# Unified named-param check: is this list a [:Keyword, value] pair
# where Keyword is registered in the engine?
func EngineIsAnyNamedParam(paList)
    if NOT isList(paList)
        return 0
    ok

    if len(paList) != 2
        return 0
    ok

    if NOT isString(paList[1])
        return 0
    ok

    return EngineIsNamedParam(paList[1])

#------------------------------------------------------------#
#  PARAM CHECKING TOGGLE                                     #
#------------------------------------------------------------#

func EngineParamCheckEnabled()
    if $pStzMetaHandle = NULL
        return _bParamCheck
    ok
    return stz_meta_param_check_enabled()

func EngineSetParamCheck(bValue)
    if $pStzMetaHandle != NULL
        stz_meta_set_param_check(bValue)
    ok
    _bParamCheck = bValue

#------------------------------------------------------------#
#  ERROR CATALOG (replaces hand-crafted StzRaise strings)    #
#------------------------------------------------------------#

# Usage:
#   StzRaise(EngineFormatError(:PARAM_TYPE, [
#       :param = "pItem", :expected = "string"
#   ]))

func EngineFormatError(cCode, paParams)
    if $pStzMetaHandle = NULL
        return "Error: " + cCode
    ok

    # Convert Ring hash list to flat key/value pairs for the engine
    # [:param = "pItem", :expected = "string"]
    # becomes: "param", "pItem", "expected", "string"

    nLen = len(paParams)

    switch nLen
    on 0
        return stz_meta_format_error(cCode)
    on 1
        return stz_meta_format_error(cCode,
            paParams[1][1], paParams[1][2])
    on 2
        return stz_meta_format_error(cCode,
            paParams[1][1], paParams[1][2],
            paParams[2][1], paParams[2][2])
    on 3
        return stz_meta_format_error(cCode,
            paParams[1][1], paParams[1][2],
            paParams[2][1], paParams[2][2],
            paParams[3][1], paParams[3][2])
    on 4
        return stz_meta_format_error(cCode,
            paParams[1][1], paParams[1][2],
            paParams[2][1], paParams[2][2],
            paParams[3][1], paParams[3][2],
            paParams[4][1], paParams[4][2])
    other
        return "Error: " + cCode
    off

#------------------------------------------------------------#
#  ALIAS ENGINE (replaces addmethod() init loops in XT)      #
#------------------------------------------------------------#

func EngineRegisterAlias(cClass, cAlias, cCanonical)
    if $pStzMetaHandle = NULL
        return
    ok
    stz_meta_register_alias(cClass, cAlias, cCanonical)

func EngineResolveAlias(cClass, cMethod)
    if $pStzMetaHandle = NULL
        return ""
    ok
    return stz_meta_resolve_alias(cClass, cMethod)

func EngineAliasCount(cClass)
    if $pStzMetaHandle = NULL
        return 0
    ok
    return stz_meta_alias_count(cClass)

# Bulk register aliases from a table (same format as XT classes)
# aAliases = [ [:Value, :Content], [:Size, :NumberOfItems], ... ]
func EngineRegisterAliases(cClass, aAliases)
    if $pStzMetaHandle = NULL
        return
    ok

    nLen = len(aAliases)
    for i = 1 to nLen
        stz_meta_register_alias(cClass, aAliases[i][1], aAliases[i][2])
    next

#------------------------------------------------------------#
#  METHOD GENERATION (CS/Q/Passive auto-dispatch)            #
#------------------------------------------------------------#

# Apply generation rules to a class object using addmethod().
# Called once at class init instead of writing hundreds of wrappers.
func EngineApplyGenRules(oObject, cClass)
    if $pStzMetaHandle = NULL
        return
    ok

    nCount = stz_meta_gen_rule_count(cClass)
    if nCount = 0
        return
    ok

    for i = 1 to nCount
        cRule = stz_meta_gen_rule_get(cClass, i)
        if cRule = ""
            loop
        ok

        # Parse "kind|generated|canonical"
        aparts = split(cRule, "|")
        if len(aparts) != 3
            loop
        ok

        cKind      = aparts[1]
        cGenerated = aparts[2]
        cCanonical = aparts[3]

        switch cKind
        on "cs"
            # For CS rules, the generated method calls canonical with CS=1
            # We use addmethod to point generated -> a wrapper
            # Ring's addmethod can only alias, so we create a dispatcher
            _EngineAddCSWrapper(oObject, cGenerated, cCanonical)
        on "fluent_q"
            addmethod(oObject, cGenerated, cCanonical)
        on "passive"
            addmethod(oObject, cGenerated, cCanonical)
        off
    next

# CS wrapper: creates a method that calls the CS version with TRUE
func _EngineAddCSWrapper(oObject, cNonCS, cCS)
    # For now, use addmethod as a direct alias.
    # Full CS-dispatch (appending ,1) requires Ring method interception
    # which will be added when the engine gains method-call hooks.
    addmethod(oObject, cNonCS, cCS)

#------------------------------------------------------------#
#  HISTORY TRACKING                                          #
#------------------------------------------------------------#

func EngineHistoryEnabled()
    if $pStzMetaHandle = NULL
        return _bKeepHisto
    ok
    return stz_meta_history_enabled()

func EngineSetHistory(bValue)
    if $pStzMetaHandle != NULL
        stz_meta_set_history(bValue)
    ok
    _bKeepHisto = bValue
