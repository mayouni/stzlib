# Softanza’s rx() Function for Advanced Data Preparation

Your customer collects sales data in a hybrid structure, combining pure numbers, numbers embedded in strings, and numbers within JSON-like strings. The input data list is structured as follows:

```ring
aData = [

    # Pure numbers
    12500,
    10200,

    # Numbers in strings
    "14800",
    "870kg",

    # Numbers within a list
    [ 52700, 17100, "nothing", 14400 ],

    # Numbers as values in a dictionary
    [ :Europe = 87200, :Africa = 25200, :Asia = "undefined" ],

    # Numbers in text narrations
    "We sailed 700 kg in Tunisia, 840 in Canada, and 110 in Portugal.",
    "We also sailed 180 kg, and then 220 kg was sold in Egypt.",

    # Numbers in a JSON-like string
    '{
        Sales {
            NorthRegion {
                Day: 4520;
                Night: "120 and then 82 kg";
            }
            SouthRegion {
                Day = nothing;
                Night = 88 kg;
            }
        }
    }'
]
```

Your task is to analyze this sales data and compute key statistics: the total quantity sold, as well as the minimum, maximum, and mean values.

The Softanza library offers a powerful yet user-friendly regex engine, accessible through the `rx()` small function, to simplify this process. Let’s explore how it works…

```ring
# Converting the list items to strings for regex processing
acData = Stringify(aData)

# Processing each item with the :NumbersInString regex
anNumbers = []

for cItem in acData

    # Trying to match numbers in the curren string-item
    rx( pat(:NumbersInString) ) {

        # If numbers are matched
        
        if Match(cItem)

            # Add each match to the result list
            for cMatch in Matches()
                anNumbers + @number(cMatch)
            next
        ok
    }

end

# Checking the resulting list of numbers

? @@(anNumbers)
#--> [ 12500, 10200, 14800, 52700, 17100, 14400, 87200, 25200, 4520, 18230, 700, 840, 110, 180, 220 ]

# Converting the list to a stzListOfNumbers object for calculations
QQ(anNumbers) {
    ? Sum()     #--> 258900
    ? Max()     #-->  87200
    ? Min()     #-->    110
    ? Mean()    #-->  17260
}
```
Softanza includes a rich set of pre-built, well-tested, and **named** regex patterns. You can easily call them with the `pat()` function and use them directly in `rx(pat())`, as shown above.

Their complete list can be explored in the `stzRegexData.ring` file accessible [here](https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/data/stzRegexData.ring).

> NOTE:  `QQ()` creates a stzListOfNumbers object, unlike Q(), which creates a stzList.