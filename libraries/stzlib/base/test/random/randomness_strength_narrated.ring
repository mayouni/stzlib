# The randomness ceiling is gone, and one seed governs the library.
#
# Ring's builtin random() is 15-BIT on Windows: measured max of
# random(2_000_000_000) over 100,000 draws was 32767, and 40 library call
# sites drew through it -- so RandomItem() on a 40,000-item list could
# never pick past position ~32768 (measured: 200 picks, max 32605), and
# big shuffles were far from uniform. It survived because SMALL ranges
# look perfectly flat -- every small-fixture test was green about the
# wrong thing.
#
# All 40 sites now route to the engine (Xoshiro256++, full-range,
# unbiased), and SeedRandom()/StzSRandom() seed BOTH generators so "seed
# once" means what it says.
#
# Scene 1 is the assertion that could not have passed before the fix.
# Scene 2 pins the seed contract ACROSS MODULES -- number, list, string --
# because the old world was reproducible-in-patches: it depended on which
# generator a given method happened to reach.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the 32767 ceiling is gone --"
# Direct engine draw: 100 draws from 1..999,999,999. Under the old builtin
# every draw capped at 32767; under a true full-range uniform the chance that
# ALL 100 stay below 32768 is (32768/1e9)^100 ~ 10^-450.
nMaxDirect = 0
for i = 1 to 100
	v = RandomNumber()
	if v > nMaxDirect nMaxDirect = v ok
next
chk("a direct draw exceeds the old 15-bit ceiling", nMaxDirect > 32767)

# And through a LIST, which is where users met the bug: picks from
# 1:40000. Under the pre-fix builtin the max pick was 32605 in 200 draws;
# a true uniform fails this band with probability 0.8192^150 ~ 1e-13.
oBig = new stzList(1:40000)
nMaxPick = 0
for i = 1 to 150
	v = oBig.RandomItem()
	if v > nMaxPick nMaxPick = v ok
next
chk("a list pick reaches past position 32768", nMaxPick > 32768)
? "   (max direct " + nMaxDirect + ", max pick " + nMaxPick + ")"

? ""
? "-- Scene 2: ONE seed governs number, list, and string draws --"
SeedRandom(42)
a1 = []
for i = 1 to 3 a1 + StzRandom(1000000) next
oL1 = new stzList("A":"J")
c1 = oL1.RandomItem() + oL1.RandomItem()
aSh1 = oL1.Shuffled()

SeedRandom(42)
a2 = []
for i = 1 to 3 a2 + StzRandom(1000000) next
oL2 = new stzList("A":"J")
c2 = oL2.RandomItem() + oL2.RandomItem()
aSh2 = oL2.Shuffled()

bNums = TRUE
for i = 1 to 3 if a1[i] != a2[i] bNums = FALSE ok next
chk("number draws repeat under the same seed", bNums)
chk("list picks repeat under the same seed", c1 = c2)
bShuf = TRUE
for i = 1 to len(aSh1) if aSh1[i] != aSh2[i] bShuf = FALSE ok next
chk("a shuffle repeats under the same seed", bShuf)

# The NEGATIVE sibling: without reseeding, the stream moves on. A guard
# that can only say yes guards nothing.
a3 = []
for i = 1 to 3 a3 + StzRandom(1000000) next
bSame = TRUE
for i = 1 to 3 if a2[i] != a3[i] bSame = FALSE ok next
chk("without reseeding, the sequence does NOT repeat", NOT bSame)

? ""
? "-- Scene 3: the engine's uniformity, banded from measurement --"
# 60k d6 draws measured 10153/9802/10113/9998/9975/9959 -- within 2%.
# The band is 6%: far outside anything a healthy generator produces,
# far inside what a broken one (or a 15-bit modulo artifact) would show.
aH = [0,0,0,0,0,0]
for i = 1 to 60000
	aH[StzEngineRandomInt(1,6)]++
next
bFlat = TRUE
for i = 1 to 6
	if aH[i] < 9400 or aH[i] > 10600 bFlat = FALSE ok
next
chk("60k d6 histogram stays inside the 6% band", bFlat)
? "   " + @@(aH)

? ""
? "-- Scene 4: seeding remains honest across the string module --"
oRz = new stzStringRandomizer("abcdefghij")
SeedRandom(7)
c1 = oRz.Shuffled()
SeedRandom(7)
c2 = oRz.Shuffled()
chk("a string shuffle repeats under the same seed", c1 = c2)
chk("...and it is a full-length permutation", StzLen(c1) = 10)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
