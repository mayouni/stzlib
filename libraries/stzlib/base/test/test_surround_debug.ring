load "../stzBase.ring"

o = new stzString("hello")
? "content before: " + o.Content()
_oSrReplacer_ = new stzStringReplacer(o)
? "replacer created"
_oSrReplacer_.Surround("[", "]")
? "surround done"
? "content after: " + o.Content()
