load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzStringText (word / sentence analysis).
# Deterministic.
#
# Regression guard (fixed this session): the engine word extractor
# (str_extract_words) only treated ASCII [a-zA-Z'] as word characters, so it
# SPLIT accented words ('café' -> 'caf'+'') and disagreed with NumberOfWords
# (which is whitespace-based). It now treats any byte >= 0x80 (a UTF-8 letter
# byte) as a word char, so accented/CJK words stay intact and the two agree.

Scenario("Words and sentences over ASCII text")
    Given("'The quick brown fox. It jumps!'")
    t = new stzStringText("The quick brown fox. It jumps!")
    Then("NumberOfWords is 6", t.NumberOfWords(), 6)
    Then("Words lists them (punctuation stripped)", ListEq(t.Words(), [ "The", "quick", "brown", "fox", "It", "jumps" ]), TRUE)
    Then("FirstWord is The", t.FirstWord(), "The")
    Then("NumberOfSentences is 2", t.NumberOfSentences(), 2)
    Then("Sentences splits on . and !", ListEq(t.Sentences(), [ "The quick brown fox.", "It jumps!" ]), TRUE)
EndScenario()

Scenario("Words keep accented (multibyte) letters intact")
    Given("accented words")
    w = new stzStringText("caf" + AccE() + " " + AccE() + "cole na" + AccI() + "ve")
    Then("NumberOfWords is 3", w.NumberOfWords(), 3)
    Then("Words counts 3 (no longer split at accents)", len(w.Words()), 3)
    Then("the first word is 'cafe-acute' intact", w.Words()[1], "caf" + AccE())
    Then("the second word is 'ecole' intact", w.Words()[2], AccE() + "cole")
    Then("the third word is 'naive' intact", w.Words()[3], "na" + AccI() + "ve")
EndScenario()

Scenario("Sentence count keeps multibyte content")
    Given("a two-sentence text whose 2nd sentence has an accent")
    s = new stzStringText("Bonjour. Caf" + AccE() + " ouvert!")
    Then("NumberOfSentences is 2", s.NumberOfSentences(), 2)
    Then("the 2nd sentence keeps its accented word", s.Sentences()[2], "Caf" + AccE() + " ouvert!")
EndScenario()

Summary()

func AccE   # e-acute U+00E9
    return char(195) + char(169)

func AccI   # i-diaeresis U+00EF
    return char(195) + char(175)

func ListEq aA, aE
    if len(aA) != len(aE) return FALSE ok
    nLen = len(aA)
    for i = 1 to nLen
        if isList(aA[i]) and isList(aE[i])
            if NOT ListEq(aA[i], aE[i]) return FALSE ok
        else
            if aA[i] != aE[i] return FALSE ok
        ok
    next
    return TRUE
