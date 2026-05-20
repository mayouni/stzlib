# Softanza Engine -- Meta-Engine Ring Bridge
#
# Loads stz_meta.dll and provides high-level Ring functions
# that wrap the native meta-engine. This replaces:
#
#   - 1,566 IsXxxNamedParam() methods  -> StzMetaIsNamedParam()
#   - CheckingParams() boilerplate     -> engine-side param validation
#   - StzRaise() hand-crafted strings  -> StzMetaFormatError()
#   - addmethod() alias loops          -> StzMetaRegisterAlias()
#   - CS/Q/Passive wrapper methods     -> StzMetaApplyGenRules()
#
# Used by: base/common/stzFuncs.ring, all Stz* classes

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
    $pStzMetaHandle = NULL
ok

#------------------------------------------------------------#
#  INITIALIZATION                                            #
#------------------------------------------------------------#

func StzMetaInit()
    if $pStzMetaHandle != NULL
        stz_meta_init()
    ok

	func EngineMetaInit()
		StzMetaInit()

func StzMetaShutdown()
    if $pStzMetaHandle != NULL
        stz_meta_shutdown()
    ok

	func EngineMetaShutdown()
		StzMetaShutdown()

#------------------------------------------------------------#
#  NAMED PARAM REGISTRY (replaces 1,566 IsXxxNamedParam)     #
#------------------------------------------------------------#

func StzMetaIsNamedParam(cKeyword)
    if $pStzMetaHandle = NULL
        return 0
    ok
    return stz_meta_is_named_param(cKeyword)

	func EngineIsNamedParam(cKeyword)
		return StzMetaIsNamedParam(cKeyword)

func StzMetaIsOneOfTheseNamedParams(paList, pacNames)
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
            if StzMetaIsNamedParam(pacNames[i])
                return 1
            ok
        ok
    next

    return 0

	func EngineIsOneOfTheseNamedParams(paList, pacNames)
		return StzMetaIsOneOfTheseNamedParams(paList, pacNames)

func StzMetaIsAnyNamedParam(paList)
    if NOT isList(paList)
        return 0
    ok

    if len(paList) != 2
        return 0
    ok

    if NOT isString(paList[1])
        return 0
    ok

    return StzMetaIsNamedParam(paList[1])

	func EngineIsAnyNamedParam(paList)
		return StzMetaIsAnyNamedParam(paList)

#------------------------------------------------------------#
#  PARAM CHECKING TOGGLE                                     #
#------------------------------------------------------------#

func StzMetaParamCheckEnabled()
    if $pStzMetaHandle = NULL
        return _bParamCheck
    ok
    return stz_meta_param_check_enabled()

	func EngineParamCheckEnabled()
		return StzMetaParamCheckEnabled()

func StzMetaSetParamCheck(bValue)
    if $pStzMetaHandle != NULL
        stz_meta_set_param_check(bValue)
    ok
    _bParamCheck = bValue

	func EngineSetParamCheck(bValue)
		StzMetaSetParamCheck(bValue)

#------------------------------------------------------------#
#  ERROR CATALOG (replaces hand-crafted StzRaise strings)    #
#------------------------------------------------------------#

func StzMetaFormatError(cCode, paParams)
    if $pStzMetaHandle = NULL
        return "Error: " + cCode
    ok

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

	func EngineFormatError(cCode, paParams)
		return StzMetaFormatError(cCode, paParams)

#------------------------------------------------------------#
#  ALIAS ENGINE (replaces addmethod() init loops in XT)      #
#------------------------------------------------------------#

func StzMetaRegisterAlias(cClass, cAlias, cCanonical)
    if $pStzMetaHandle = NULL
        return
    ok
    stz_meta_register_alias(cClass, cAlias, cCanonical)

	func EngineRegisterAlias(cClass, cAlias, cCanonical)
		StzMetaRegisterAlias(cClass, cAlias, cCanonical)

func StzMetaResolveAlias(cClass, cMethod)
    if $pStzMetaHandle = NULL
        return ""
    ok
    return stz_meta_resolve_alias(cClass, cMethod)

	func EngineResolveAlias(cClass, cMethod)
		return StzMetaResolveAlias(cClass, cMethod)

func StzMetaAliasCount(cClass)
    if $pStzMetaHandle = NULL
        return 0
    ok
    return stz_meta_alias_count(cClass)

	func EngineAliasCount(cClass)
		return StzMetaAliasCount(cClass)

func StzMetaRegisterAliases(cClass, aAliases)
    if $pStzMetaHandle = NULL
        return
    ok

    nLen = len(aAliases)
    for i = 1 to nLen
        stz_meta_register_alias(cClass, aAliases[i][1], aAliases[i][2])
    next

	func EngineRegisterAliases(cClass, aAliases)
		StzMetaRegisterAliases(cClass, aAliases)

#------------------------------------------------------------#
#  METHOD GENERATION (CS/Q/Passive auto-dispatch)            #
#------------------------------------------------------------#

func StzMetaApplyGenRules(oObject, cClass)
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

        aparts = split(cRule, "|")
        if len(aparts) != 3
            loop
        ok

        cKind      = aparts[1]
        cGenerated = aparts[2]
        cCanonical = aparts[3]

        switch cKind
        on "cs"
            _StzMetaAddCSWrapper(oObject, cGenerated, cCanonical)
        on "fluent_q"
            addmethod(oObject, cGenerated, cCanonical)
        on "passive"
            addmethod(oObject, cGenerated, cCanonical)
        off
    next

	func EngineApplyGenRules(oObject, cClass)
		StzMetaApplyGenRules(oObject, cClass)

func _StzMetaAddCSWrapper(oObject, cNonCS, cCS)
    addmethod(oObject, cNonCS, cCS)

	func _EngineAddCSWrapper(oObject, cNonCS, cCS)
		_StzMetaAddCSWrapper(oObject, cNonCS, cCS)

#------------------------------------------------------------#
#  HISTORY TRACKING                                          #
#------------------------------------------------------------#

func StzMetaHistoryEnabled()
    if $pStzMetaHandle = NULL
        return _bKeepHisto
    ok
    return stz_meta_history_enabled()

	func EngineHistoryEnabled()
		return StzMetaHistoryEnabled()

func StzMetaSetHistory(bValue)
    if $pStzMetaHandle != NULL
        stz_meta_set_history(bValue)
    ok
    _bKeepHisto = bValue

	func EngineSetHistory(bValue)
		StzMetaSetHistory(bValue)
