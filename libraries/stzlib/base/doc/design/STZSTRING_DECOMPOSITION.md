# stzString Decomposition Map

> Maps 15,887 methods (102K LOC) to 9 subclasses.
> Mechanism: **composition via delegate objects** (as prototyped
> in stzString2.ring). Each subclass is a standalone Ring class
> that holds a reference to the engine handle. stzString creates
> all delegates at init and exposes their methods directly.

---

## Mechanism

```ring
# stzString.ring -- shared base
class stzString from stzObject
    @pEngine
    def init(pcStr)
        @pEngine = StzEngineString(pcStr)
    def Content()
        return StzEngineStringData(@pEngine)
    def Size()
        return StzEngineStringLen(@pEngine)
    def Copy()
        return new stzString(This.Content())
    def Engine()
        return @pEngine

# stzStringFinder.ring -- standalone, usable alone
class stzStringFinder from stzString
    def FindFirst(pcSubStr)
        ...
    def FindAll(pcSubStr)
        ...

# stzString.ring -- full class, loads everything
load "stzString.ring"
load "stzStringFinder.ring"
load "stzStringSplitter.ring"
...

class stzString from stzObject
    @oCore
    @oFinder
    @oSplitter
    ...

    def init(pcStr)
        @oCore = new stzString(pcStr)
        @oFinder = new stzStringFinder(pcStr)
        @oSplitter = new stzStringSplitter(pcStr)
        ...

    # Delegation -- each method routes to its subclass
    # (Ring does not support method_missing, so delegation
    # must be explicit. But it can be generated.)
```

**Standalone usage:**
```ring
load "stzStringFinder.ring"
oFinder = new stzStringFinder("hello world")
? oFinder.FindFirst("world")  # 7
```

**Full usage (backward compatible):**
```ring
load "stzlib.ring"
o1 = new stzString("hello world")
? o1.FindFirst("world")  # 7 -- delegates to @oFinder
```

---

## The 9 Subclasses

### 1. stzString (root)

**LOC estimate:** ~2,000
**stzString2 delegates:** @oStringView, @oConstraint, @oLanguage,
@oObjectHistory, @oUpdater, @oResizer, @oTypeCast, @oTypeInfere

**Concern:** Lifecycle, content access, engine handle, constraints,
language, object history, type casting, copying.

**Sections from stzString.ring:**
- CHECKING CONSTRAINTS (line 68)
- GETTING CONTENT OF THE STRING (line 122)
- GETTING A COPY OF THE STRING OBJECT (line 213)
- GETTING THE CASE OF THE STRING (line 257)
- APPENDING THE STRING (line 344)
- EXTENDING THE STRING (lines 666-1165)
- SHRINKING THE STRING (line 1302)

### 2. stzStringFinder

**LOC estimate:** ~15,000
**stzString2 delegates:** @oFinder, @oFinderW, @oFinderXT,
@oFinderWXT, @oAntiFinder, @oVizFinder, @oVizFinderXT,
@oContains, @oContainsXT, @oCounter, @oCounterXT, @oCounterW,
@oCounterInStartEnd, @oCopare, @oDistance, @oDistanceXt

**Concern:** Finding substrings (first, last, all, nth),
conditional finding (W), extended finding (XT), anti-finding,
visual finding (VizFind), containing checks, counting occurrences,
comparing, distance.

**Sections from stzString.ring:**
- SUBSTRINGS - FINDING (line 3221+, 600+ methods)
- FINDING SUBSTRINGS EXCEPT (line 5029+, 56 methods)
- OCCURRENCE COUNTING (line 10027+, 120+ methods)
- SUBSTRINGS BY FREQUENCY (line 10334+, 45 methods)
- INVISIBLE CHARS finding (line 5825)

### 3. stzStringSplitter

**LOC estimate:** ~8,000
**stzString2 delegates:** @oSplitter, @oSplitterXT,
@oSplitsFinder, @oSplitsFinderXT, @oParts, @oPartsXT,
@oPartsFinder, @oPartsFinderXT, @oPartsClassifier,
@oPartsClassifierXT, @oDivider, @oHalves, @oHalvesXT

**Concern:** Splitting by separator, splitting by position,
splitting into parts, dividing, halving, classifying parts.

**Sections from stzString.ring:**
- SPLITTING operations (400+ methods)

### 4. stzStringReplacer

**LOC estimate:** ~8,000
**stzString2 delegates:** @oReplacer, @oReplacerXT, @oReplacerW,
@oReplacerWXT, @oInserter, @oInserterW, @oInserterXT,
@oInserterWXT, @oRemover, @oRemoverW, @oRemoverXT, @oRemoverWXT,
@oRemoverInStartEnd, @oRemoverInStartEndXT, @oSwapper, @oMover

**Concern:** Replacing substrings (all variants), inserting at
positions, removing substrings, swapping, moving.

**Sections from stzString.ring:**
- REPLACING operations (300+ methods)
- INSERTING operations
- REMOVING operations
- SWAPPING/MOVING operations

### 5. stzStringBounder

**LOC estimate:** ~6,000
**stzString2 delegates:** @oBounder, @oBetweener, @oSection,
@oAntiSection, @oMarquer, @oSubStrings, @oSubString,
@oSubStringXT, @oSubStringChecker

**Concern:** Sections, ranges, between operations, bounding,
marquers, substring management.

**Sections from stzString.ring:**
- BOUNDS AND BOUNDING (200+ methods)
- MARQUERS (500+ methods)
- SECTIONS operations

### 6. stzStringFormatter

**LOC estimate:** ~10,000
**stzString2 delegates:** @oAlign, @oAlignXT, @oJustify,
@oJustifyXT, @oSpaces, @oOverSpaces, @oSpacifier, @oSpacifierXT,
@oUnSpacifier, @oSimplifierXT, @oAppender, @oRepeater,
@oRepeaterXT, @oShortifier, @oShortifierXT, @oInterpolate,
@oFormatNumber

**Concern:** Case conversion (upper/lower/title/capital/fold),
alignment (left/right/center), justification, spacing,
simplification, padding, repeating, shortening, interpolation,
number formatting.

**Sections from stzString.ring:**
- CASE CONVERSION (lines 1388-3100, 217 methods)
- FORMATTING & ALIGNMENT (200+ methods)
- SPACING operations
- SIMPLIFICATION

### 7. stzStringVisualizer

**LOC estimate:** ~4,000
**stzString2 delegates:** @oShow, @oShowXT, @oBoxer, @oBoxerXT,
@oStringifier

**Concern:** Show(), Boxed(), VizFind(), Highlight(),
stringification, visual rendering.

**Sections from stzString.ring:**
- SHOW operations
- BOXING operations
- VIZFIND operations
- STRINGIFICATION

### 8. stzStringWalker

**LOC estimate:** ~3,000
**stzString2 delegates:** @oWalkers, @oCheckers, @oYielders,
@oPerformers, @oSitter

**Concern:** Walking the string (forward/backward/variable step),
checking with walkers, yielding values, performing operations,
sitting (cursor position).

**Sections from stzString.ring:**
- WALKING THE STRING (line 96740+)
- WALKER operations

### 9. stzStringChecker

**LOC estimate:** ~8,000
**stzString2 delegates:** @oChars, @oCharsCheker, @oCharsCheckerXT,
@oCharsW, @oCharsWXT, @oStartsEndsChecker, @oOnly,
@oCharCheker, @oMultipleChecker, @oOrientation,
@oAnagramChecker, @oPunctuation, @oPunctuationFinder,
@oPunctuationRemover, @oDotsRemover

**Concern:** Type checking (IsNumber, IsLetter, IsPalindrome...),
starts/ends checking, char-level checking, orientation (LTR/RTL),
anagram checking, punctuation operations.

**Sections from stzString.ring:**
- CHECKING operations (300+ methods)
- CHARS HANDLING (150+ methods)
- PUNCTUATION (line 97580+)
- TYPE CHECKING (line 10749+)

---

## Additional Specialized Classes (from stzString2)

These are smaller, more specialized concerns that sit alongside
the 9 main subclasses:

| Class | Delegates | Concern |
|-------|-----------|---------|
| stzStringEncoder | @oEncoder, @oHex, @oHexUnicode, @oUnicode | Encoding, hex, unicode |
| stzStringCrypto | @oHasher, @oEncryptor, @oCompressWithBinary | Hashing, encryption, compression |
| stzStringNumbers | @oNumberInString, @oBinaryNumberInString, @oOctalNumberInString, @oHexNumberInString, @oNumbers, @oNumbersExtractor, @oStartingTrailingNumber | Numbers in strings |
| stzStringLines | @oLines, @oLinesW, @oLinesWXT, @oEmptyLines | Line management |
| stzStringWords | @oWords, @oWordsFinders, @oItem | Word operations |
| stzStringDuplicates | @oDuplicates*, @oConsecutives*, @oDupSecutives* | Duplicate/consecutive management |
| stzStringLocale | @oLocale, @oLanguage, @oCountry, @oScript, @oCurrency | Locale operations |
| stzStringCode | @oRingCode, @oRingFunction, @oRingClass, @oExternalCode, @oNaturalCode, @oOperators | Code in strings |
| stzStringIO | @oImporter, @oExporter, @oURL | Import/export/URL |
| stzStringRandomizer | @oRandomizer | Random operations |

---

## Migration Strategy

1. **Phase A:** Create stzString with engine handle and
   core methods. Verify it works standalone.

2. **Phase B:** Extract stzStringFinder (biggest subclass,
   most independent). Move all Find*/Contains*/Count* methods.
   Verify backward compatibility via stzString delegation.

3. **Phase C:** Extract remaining subclasses one at a time,
   verifying after each extraction.

4. **Phase D:** Create method delegation in stzString (either
   hand-written or generated). Verify all existing tests pass.

5. **Phase E:** Update documentation and loading paths.

---

## Method Count Estimates

| Subclass | Methods | % of Total |
|----------|--------:|----------:|
| stzString | ~500 | 3% |
| stzStringFinder | ~2,500 | 16% |
| stzStringSplitter | ~1,500 | 9% |
| stzStringReplacer | ~1,800 | 11% |
| stzStringBounder | ~1,500 | 9% |
| stzStringFormatter | ~2,200 | 14% |
| stzStringVisualizer | ~800 | 5% |
| stzStringWalker | ~600 | 4% |
| stzStringChecker | ~2,000 | 13% |
| Specialized (10 classes) | ~2,487 | 16% |
| **Total** | **~15,887** | **100%** |
