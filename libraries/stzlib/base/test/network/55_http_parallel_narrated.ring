load "../../stzBase.ring"
load "../_narrated.ring"

# M-DEP4 follow-on: parallel HTTP GET via std.Thread per URL.
# Pins the API surface + the all-fail path (every URL bogus).

Scenario("StzEngineHttpParallelGet exists and is callable")
    Then("StzEngineHttpParallelGet is defined",
        isString(@@(:StzEngineHttpParallelGet)), TRUE)
EndScenario()

Scenario("Parallel GET against all-bogus URLs returns one record per URL")
    Given("three bogus URLs joined by newline")
    cBlob = "not a url" + char(10) + "also bad" + char(10) + "still bad"
    cJoined = StzEngineHttpParallelGet(cBlob)
    Then("output is non-empty", len(cJoined) > 0, TRUE)
    # Each record ends with the RECORD_SEPARATOR (0x1E).
    aRecs = @split(cJoined, char(30))
    # Empty trailing element after the final separator is filtered.
    nFilled = 0
    nLr = len(aRecs)
    for _i_ = 1 to nLr
        if aRecs[_i_] != "" nFilled++ ok
    next
    Then("three records produced", nFilled, 3)
    Then("each record begins with '-1:' (transport error)",
        StzLeft(aRecs[1], 3), "-1:")
EndScenario()

Scenario("stzHttpClient.GetMany wraps the engine call")
    Given("a client and a list of bogus URLs")
    oC = new stzHttpClient()
    aR = oC.GetMany([ "bad1", "bad2", "bad3" ])
    Then("three responses returned",     len(aR), 3)
    Then("each response is a list",      isList(aR[1]), TRUE)
    Then("status code = -1 (transport)", aR[1][:code], -1)
EndScenario()

Scenario("A batched GET is still the SAME client")

    # -- WHY THIS SCENE EXISTS --
    #
    # GetMany() called StzEngineHttpParallelGet with the URLs and NOTHING ELSE.
    # Every setter on the client -- user agent, cookies, custom headers, auth,
    # bearer token, proxy, client certificate, verify-SSL, follow-redirects,
    # accept-encoding and both timeouts -- was dropped the moment you asked for
    # more than one URL. A client holding a bearer token sent unauthenticated
    # requests; a client pinned to a proxy went straight out to the host instead.
    #
    # Nothing errored, and the sibling GetManySequential() was right all along
    # because it goes through Get_() -> _Perform() like every other verb. So the
    # two batch methods disagreed, and the documented default was the broken one.

    Given("a client configured the way a caller would configure it")
    oCfg = new stzHttpClient()
    oCfg.SetUserAgent("zzagent")
    oCfg.SetHeader("X-Zz", "marker")
    oCfg.SetBearer("zztoken")

    # If either blob were empty the checks below would pass for the wrong reason:
    # there would be nothing to carry in the first place.
    Then("its header blob carries the agent", StzFindFirst("zzagent", oCfg._ComposeHeaderBlob()) > 0, TRUE)
    Then("...and the custom header", StzFindFirst("X-Zz: marker", oCfg._ComposeHeaderBlob()) > 0, TRUE)
    Then("...and its options blob carries the token", StzFindFirst("bearer=zztoken", oCfg._ComposeOptionsBlob()) > 0, TRUE)

    When("that client runs a batch")
    Then("it still gets one record per URL", len(oCfg.GetMany([ "http://127.0.0.1:9/a", "http://127.0.0.1:9/b" ])), 2)

    # -- THE PROOF THAT THE CONFIGURATION TRAVELS --
    #
    # Point the client's PROXY at a socket we are listening on. If the options
    # blob reaches the batch, curl connects HERE instead of to the unroutable
    # host in the URL -- and the connection arriving is observable at once, with
    # no timing and no network. Nothing else in this suite touches that port, so
    # a connection on it has exactly one possible source.
    Given("a listener standing in for a proxy")
    Then("the batch connects to the proxy it was given", BatchReachedProxy(TRUE), TRUE)
    Then("...and does not go near it when no proxy is set", BatchReachedProxy(FALSE), FALSE)

    # THE NEGATIVE SIBLING is the unconfigured call: the engine entry grew four
    # arguments, and called without them it has to behave exactly as it did when
    # it took one. That is what every existing caller still does.
    Given("the engine entry called the old way, with one argument")
    cOld = StzEngineHttpParallelGet("not a url" + char(10) + "also bad")
    Then("two records still come back", NPfRecords(cOld), 2)
    Then("...each a transport error", StzLeft(@split(cOld, char(30))[1], 3), "-1:")

    Given("and called with an explicitly empty configuration")
    cBare = StzEngineHttpParallelGet("not a url" + char(10) + "also bad", "", "", 0, 0)
    Then("the answer is the same", cBare, cOld)
EndScenario()

Summary()

# -- batched-GET helpers -------------------------------------------------------

func NPfRecords(cJoined)
    _aR_ = @split(cJoined, char(30))
    _n_ = 0
    _nL_ = len(_aR_)
    for _i_ = 1 to _nL_
        if _aR_[_i_] != ""
            _n_++
        ok
    next
    return _n_

# Does the batch connect to the proxy the client was given?
#
# The URL points at an unroutable address, so a connection on the listener's port
# can only be the proxy setting having crossed. curl resets the socket when the
# request times out, which is why this asks whether a connection ARRIVED and not
# what it said.
#
# The wait is BOUNDED. With a plain AcceptOne() the no-proxy case never returns,
# so a regression would hang the suite instead of failing it -- which is exactly
# what happened the first time this check was written.
func BatchReachedProxy(bWithProxy)
    _nPort_ = 18420
    if bWithProxy
        _nPort_ = 18421
    ok
    _oSrv_ = new stzTcpServer()
    _oSrv_.Listen(_nPort_, "127.0.0.1")

    _oP_ = new stzHttpClient()
    if bWithProxy
        _oP_.SetProxy("http://127.0.0.1:" + _nPort_)
    ok
    _oP_.SetRequestTimeout(1200)
    _oP_.GetMany([ "http://10.255.255.1/a" ])

    _oConn_ = _oSrv_.AcceptOneWithin(700)
    _bGot_ = isObject(_oConn_)
    _oSrv_.Close()
    return _bGot_
