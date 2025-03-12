load "../max/stzmax.ring"

/*---

pr()

Rx( pat(:NumbersInString) ) {

	Match("I have 150 dollars 90 centes")
	? Matches()
	#--> [ '150', '90' ]
}

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---
*/


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

for cItem in acData

	# Firing Softanza regex engine with rx() and feeding
	# it with the regex engine called by name using pat()

	rx( pat(:NumbersInString) ) {

		# If numbers are matched

		if Match(cItem)

			# Then add them to the result list

			for cMatch in Matches()

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

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*---

pr()

Lxu() {
    # Pattern definition with intuitive syntax
    Trigger(:ItemIsNumber =  pat(:number))
    Trigger(:ItemIsListOfNumbers = '[ @N+ ]')
    
    # Action definition with human-readable format
    @C( :When = :ItemIsNumber, :Do = '{
        @aResult + @item
    }')
    
    # Process and harvest results
    Process([12500, 10200, "14800"])
    ? @@( Harvest() )
    #--> [ 12500, 10200, "14800" ]

}

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*---
*/
# Example of using Listexuter to process sales data in different formats

pr()

    Lxu() {
        # 1) DEFINING PATTERNS
        # First we define the reactive strategy of our Listexuter by defining the regex
        # and listex patterns to be used by the matching engine (regexes for items that are
        # numbers and strings, and listex for items that are lists)
        
        # The following 2 triggers Will react to items that are Numbers and items
        # that are list of Numbers
        Trigger(:Number = pat(:numbersInString)) # Acts on any item of the list that is a number
/*        Trigger(:ItemIsListOfNumbers = '[ @N+ ]')
        
        # And the following 2 triggers will react to items that are numbers hosted in
        # strings and numbers in hashlists
       Trigger(:NumbersInString = pat(:numbersInString))
/*     Trigger(:ItemIsNumberInHashList = pat(:numbersAsValuesInHashlist) )
    
        # Finally we trigger texts that contain Numbers
       Trigger(:ItemIsTextContainingNumbers = pat(:NumbersInsideString))
        
        # 2) DESIGNING ACTIONS
        # Second, we define actions to be computed when each trigger is potentially fired
 */       
        # Case of items that are pure Numbers in the list
        @C(:Number, '{
            @aResult + @item
        }')
        
/*        # Case of items that are lists of numbers
        @C(:ItemIsListOfNumbers, '{
            for n in @item
                @aResult + n
            next
        }')
      
        # Cases of numbers that are hosted in strings
        @C(:NumbersInString, '{
            @aResult + @@(Matches())
        }')
 /*      
        # Case of numbers that are defined inside hashlists
        @C(:ItemIsNumberInHashList, '{
            anNumbers = StzHashListQ(@item).Values()
            for n in anNumbers
                @aResult + n
            next
        }')
        
/*        # Case of Numbers contained in a text narration
        @C(:ItemIsTextContainingNumbers, '{
            anNumbers = ToNumbers(MatchedValues())
            for n in anNumbers
                @aResult + n
            next
        }')
 */       
        # 3) FEEDING DATA TO THE LISTEXUTER AND HARVESTING RESULTS
        Process([
            12500,
            10200,
            "14800",
            [ 52700, 17100, 14400 ],
            [ :Europe = 87200, :Africa = 25200, :Asia = 16100],
            4520,
            "870",
            [ 18230 ],
            "We sailed 700 pieces in Tunisia, 840 in Canada, and 110 in Portugal.",
            "Salah achieved the target of 180 and then 220 pieces sold in Egypt"
        ])
        
        ? @@NL(Harvest())
        #--> [
        # Harvested by the 1st trigger 'ItemIsNumber'
        # 12500,
        # 10200,
        # 4520,
        # Harvested by 2nd trigger 'ItemIsListOfNumbers'
        # 52700,
        # 17100,
        # 14400,
        # 18230,
        # Harvested by 3rd trigger 'ItemIsNumberInString'
        # 14800,
        # 870,
        # Harvested by 4th trigger 'ItemIsNumberInHashList'
        # 87200,
        # 25200,
        # 16100
        # Harvested by the 5th trigger 'ItemIsTextContainingNumbers'
        # 700,
        # 840,
        # 110,
        # 180,
        # 220
        # ]
    }

proff()
