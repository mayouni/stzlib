# Softanza CSV Feature: Elegant Data Transformation

## A Common Programming Task

Sarah needs to convert a nested Ring data structure into CSV format for a client report. Her data represents a product catalog with headers and corresponding values:

```ring
load "../stzbase.ring"

aMyList = [
    [
        "product",
        ["Apple", "Orange", "Banana", "Grape", "Mango"]
    ],
    [
        "price", 
        ["$1.50", "$1.20", "$0.80", "$2.00", "$3.00"]
    ],
    [
        "stock",
        ["100", "150", "200", "80", "50"]
    ]
]

# Convert to CSV with custom separator
? ListToCSVXT(aMyList, ";")
```

**Output:**
```
product;price;stock
Apple;$1.50;100
Orange;$1.20;150
Banana;$0.80;200
Grape;$2.00;80
Mango;$3.00;50
```

The `ListToCSVXT()` function handles the transformation elegantly, transposing the column-oriented data structure into proper CSV rows with custom delimiters.

## Separator Flexibility

Softanza provides two approaches for CSV conversion:

**Custom separator (XT functions):**
```ring
# Specify custom separator explicitly
? ListToCSVXT(aMyList, ";")
? CSVToListXT(str, ";")
```

**Default separator (simpler forms):**
```ring
# Use default separator
? ListToCSV(aMyList)
? CSVToList(str)

# Check current default
? CSVSeparator()          # or DefaultCSVSeparator()

# Change default
SetCSVSeparator(",")      # or SetDefaultCSVSeparator(",")
```

This dual approach gives you flexibility: use XT functions when you need specific separators, or stick with the simpler forms and configure the default once for your entire application.

## The Reverse Operation

When Sarah receives the modified CSV back, she can parse it just as easily:

```ring
str = '
product;price;stock
Apple;$1.50;100
Orange;$1.20;150
Banana;$0.80;200
Grape;$2.00;80
Mango;$3.00;50
'

# Validate and convert
? IsCSV(trim(str))  # --> TRUE
? @@NL( CSVToList(str) )
```

**Output:**
```
[
    [
        "product",
        ["Apple", "Orange", "Banana", "Grape", "Mango"]
    ],
    [
        "price",
        ["$1.50", "$1.20", "$0.80", "$2.00", "$3.00"]
    ],
    [
        "stock",
        [100, 150, 200, 80, 50]  # Auto-converted to numbers
    ]
]
```

## What Makes This Notable

The interesting aspect here is the bidirectional transformation between Ring's nested list structure and standard CSV format. The library:

- Handles the transpose operation automatically (columns ↔ rows)
- Provides custom delimiter support
- Includes automatic type detection during parsing
- Validates CSV format before processing

This approach treats CSV not just as text manipulation, but as a structured data format with semantic meaning, making the conversion process both reliable and intuitive for Ring developers working with tabular data.