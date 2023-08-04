
#TODO: stzTable add (all) excel functions
# Some common used functions are:

Sure, here's the updated table with the "Output" column added:

| Function Name     | Short Description           | Example               | Output               |
|-------------------|-----------------------------|-----------------------|----------------------|
| SUM               | Sums up a range of cells    | =SUM(A1:A10)          | 55                   |
| AVERAGE           | Calculates the average      | =AVERAGE(B1:B10)      | 23.5                 |
| COUNT             | Counts the number of cells  | =COUNT(C1:C10)        | 7                    |
| MAX               | Returns the maximum value   | =MAX(D1:D10)          | 98                   |
| MIN               | Returns the minimum value   | =MIN(E1:E10)          | 12                   |
| CONCATENATE       | Joins text strings together | =CONCATENATE("Hello", " ", "World") | Hello World |
| IF                | Checks a condition and returns one value if true, another if false | =IF(A1>10, "Yes", "No") | Yes |
| VLOOKUP           | Searches for a value in the first column of a range and returns a value from the same row in a specified column | =VLOOKUP("apple", A1:B10, 2, FALSE) | Red |
| INDEX             | Returns the value of a cell in a specified row and column number | =INDEX(C1:E10, 3, 2) | 75 |
| MATCH             | Searches for a value in a range and returns its relative position | =MATCH("apple", A1:A10, 0) | 3 |
| SUMIF             | Sums cells that meet a certain condition | =SUMIF(F1:F10, ">50") | 167 |
| COUNTIF           | Counts cells that meet a certain condition | =COUNTIF(G1:G10, "Yes") | 3 |
| AVERAGEIF         | Calculates the average of cells that meet a certain condition | =AVERAGEIF(H1:H10, "<>0") | 26.4 |
| IFERROR           | Returns a value if a formula results in an error; otherwise, returns the result of the formula | =IFERROR(I1/J1, "Error") | Error |
| TEXT              | Converts a value to text using a specified format | =TEXT(NOW(), "dd-mmm-yyyy") | 04-Aug-2023 |
| RAND              | Generates a random number between 0 and 1 | =RAND() | 0.8742356 |

# Other excel functions:
SUMPRODUCT
COUNTIFS
AVERAGEIFS
IFNA
ROUND
TEXTJOIN
LEFT
RIGHT
MID
TODAY
NOW
NETWORKDAYS
RANK
OFFSET
INDIRECT
