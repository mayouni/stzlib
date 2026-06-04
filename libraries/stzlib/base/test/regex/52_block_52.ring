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

# Applying the :NumbersInString regex to each item

_nAcData1Len_ = ring_len(acData)
for _iLoopAcData1_ = 1 to _nAcData1Len_
	cItem = acData[_iLoopAcData1_]
	# Firing Softanza regex engine with rx() and feeding
	# it with the regex engine called by name using pat()

	rx( pat(:NumbersInString) ) {

		# If numbers are matched

		if Match(cItem)

			# Then add them to the result list

			_aMatches1_ = Matches()
			_nMatches1Len_ = ring_len(_aMatches1_)
			for _iLoopMatches1_ = 1 to _nMatches1Len_
				cMatch = _aMatches1_[_iLoopMatches1_]
				anNumbers + @number(cMatch)

				# The number is matched by the regex engine
				# as a number in string, so we use @number()
				# to cast it form string to a native number

			next
		ok
	}

end

? @@(anNumbers) + NL
#--> [ 12500, 10200, 14800, 52700, 17100, 14400, 87200, 25200, 4520, 18230, 700, 840, 110, 180, 220 ]

# Elevating the list of numbers ot a stzListOfNumbers object to
# make the calculations on it (we use QQ() because Q() alone will
# elevate it to just a stzList and not a stzListOfNumbers)

QQ(anNumbers) {
	? Sum()		#--> 258900
	? Max()		#-->  87200
	? Min()		#-->    110
	? Mean()	#-->  17260
}

pf()
# Executed in 0.06 second(s) in Ring 1.22
