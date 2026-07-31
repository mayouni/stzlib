load "D:/GitHub/stzlib/libraries/stzlib/base/stzBase.ring"
_a_ = sysargv
_n_ = len(_a_)
_nTtl_ = number(_a_[_n_])
$cEvi = _a_[_n_-1]
$cSealKey = _a_[_n_-2]
$cKey = _a_[_n_-3]
_nPort_ = number(_a_[_n_-4])
StzOpenSecurityLedger(2048)
$oAuth = new stzAuth()
$oAuth.Register("victim", "correct-horse")
$oSigner = new stzRequestSigner("gate")
$oSigner.AddKey("drill", $cKey)
_oS_ = new stzAppServer()
_oS_.Get_("/health", func oReq, oResp { oResp.Text("ok") })
_oS_.Get_("/login", func oReq, oResp {
    _t_ = $oAuth.Login(oReq.Query("user"), oReq.Query("pass"))
    if _t_ = "" oResp.Status(401, "Unauthorized").Text("no") else oResp.Text("yes") ok })
_oS_.Get_("/signed", func oReq, oResp {
    _ok_ = $oSigner.VerifyNow(oReq.Query("kid"), "GET", "/signed", "",
        number(oReq.Query("ts")), oReq.Query("nonce"), oReq.Query("sig"), 60000)
    if _ok_ oResp.Text("verified") else oResp.Status(401, "Unauthorized").Text($oSigner.Why()) ok })
_oS_.Get_("/seal", func oReq, oResp {
    _oL_ = StzSecurityLedgerQ()
    _oL_.SealAttestedTo($cEvi, $cSealKey, "target-process")
    oResp.Text("sealed=" + fexists($cEvi) + " count=" + _oL_.Count()) })
_oS_.Start(_nPort_, "127.0.0.1")
_oS_.RunFor(_nTtl_)
_oS_.Stop()
