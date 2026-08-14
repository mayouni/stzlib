# Narrative
# --------
# #narration
#
# Extracted from stzRegexTest.ring, block #52.

load "../../stzBase.ring"


func main

pr()

# Your customer gathers data about his sales in
# hubrid structure, mixing pure numbers, numbers
# in strings, and numbers in JSON-like string

# The input data list looks like this:

aData = [

	# Pure numbers
	12500,
	10200,

	# Number-in-string

	"14800",
	"870kg",

	# Numbers inside a list

	[ 52700, 17100, "nothing", 14400 ],

	# Numbers as values in a hashlist

	[ :Europe = 87200, :Africa = 25200, :Asia = "undefined"],

	# Numbers inside text narrations

	"We sailed 700 kg in Tunisia, 840 in Canada, and 110 in Portugal.",
	"We also sailed 180 and then 220 kg sold in Egypt",

	# Numbers inside a JSON string

	'{
		Sales {
			NorthRegion {
				Day: 4520;
				Night: "120 and then 82 kg";
			}
			SothRegion {
				Day = nothing;
				Night = 88 kg;
			}
		}
	}'

]

# Your goal is to calculate various statistics about his sales,
# namely, the total quantity sold, the min, max, and mean values.

# Softanza can help you do this, easilty and efficiently, using
# it's advanced regex engine. Let us see how...

# Stringifying the list so we can regex it

acData = Stringify(aData)

# A container for our extracted numbers

anNumbers = []

# ONE PASS OVER THE WHOLE STRINGIFIED DATA.
#
# This used to loop `for i = 1 to len(acData)` and take acData[i] as an item
# -- but Stringify() returns a STRING, not a list. So the loop walked it one
# CHARACTER at a time, every digit matched the number pattern on its own, and
# anNumbers came out [ 1, 2, 5, 0, 0, 1, ... ]: sixty-nine digits instead of
# seventeen numbers. Sum() then answered 171 rather than 258,860.
#
# MatchFirst(), not Match(): Match() ANCHORS -- it asks whether the WHOLE
# subject is a number, which a page of sales data is not. MatchFirst()
# searches, and Matches() then answers every occurrence it found.

rx( pat(:NumbersInString) ) {

	if MatchFirst(acData)

		_aM_ = Matches()
		_nM_ = len(_aM_)
		for _i_ = 1 to _nM_
			# The engine hands back each number AS A STRING, so cast it
			anNumbers + @number(_aM_[_i_])
		next
	ok
}

? @@(anNumbers) + NL
#--> [ 12500, 10200, 14800, 52700, 17100, 14400, 87200, 25200, 700, 840, 110, 180, 220, 4520, 120, 82, 88 ]
#
# SEVENTEEN, not the fifteen this line used to claim. The old list was
# written by hand and never produced by a run: it omitted the 120, 82 and
# 88 that sit in `Night: "120 and then 82 kg"` and `Night = 88 kg`, and it
# carried an 18230 that appears nowhere in the data at all.

# Elevating the list of numbers ot a stzListOfNumbers object to
# make the calculations on it (we use QQ() because Q() alone will
# elevate it to just a stzList and not a stzListOfNumbers)

QQ(anNumbers) {
	? Sum()		#--> 240960
	? Max()		#--> 87200
	? Min()		#--> 82
	? Mean()	#--> 14174.12
}

pf()
# Executed in 0.06 second(s) in Ring 1.22
