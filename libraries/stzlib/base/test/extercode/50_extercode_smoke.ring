load "../../stzBase.ring"

# Language registry smoke test (no Execute -- L99 guardrail).

oP = new stzExterCode(:python)
? oP.IsLanguageSupported("python") = TRUE
? oP.IsLanguageSupported("Python") = TRUE         # case-insensitive query
? oP.IsLanguageSupported("ringx") = FALSE
? oP.IsLanguageSupported("R") = TRUE
? oP.IsLanguageSupported("julia") = TRUE
? oP.IsLanguageSupported("prolog") = TRUE
? oP.IsLanguageSupported("c") = TRUE
? oP.IsLanguageSupported("nodejs") = TRUE

# Code roundtrip
oP.SetCode("print(2+2)")
? oP.Code() = "print(2+2)"

# Verbose flag toggle (no side effects in test mode)
oP.SetVerbose(1)

# Wrappers construct without raising
oPy = py()
? isObject(oPy)
oPy.SetCode("x = 1")
? oPy.Code() = "x = 1"

? "DONE 12"
