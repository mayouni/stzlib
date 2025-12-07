load "../stzbase.ring"

#===========================================#
#  SOFTANZA NATURAL MARKUP LANGUAGE TESTS  #
#===========================================#

/*---

? StzStringQ(`
	#<
	Create a {+fruits:list 1~} using {#1 ["banana", "apple", "cherry"]}.
	{?how-many} item we've just added?
	{Show} them on the screen.
	Thanks a lot!
	#>

	#<
	#>
`).Uppercased()

pf()

/*---
*/
pr()

o1 = new stzNaturalMarkup('
	#<
	Create a {+list:fruits 1~} using {#1 ["banana", "apple", "cherry"]}.
	{?how-many} item we`ve just added?
	{Show} them on the screen.
	Thanks a lot!
	#>

	#<
	Make a {+string 1~} with "Ring+Softanza" inside it
	{Uppercase} it
	{Replace 2~} the {#1 "+"} sign with the lovely {#2 ^heart} char
	#>
')

? @@NL( o1.Blocks() )

? @@NL( o1.DynamicParts() )

pf()

/*--- Basic list creation and queries

pr()

cMarkup = `
Create a {+fruits:list ~1} and fill it with {#1 ["banana", "apple", "cherry"]}.
{?how-many} item we've just added?
{Show} them on the screen.
Thanks a lot!
 `

oNML = new stzNaturalMarkup(cMarkup)
oNML.Run()

#--> fruits
#--> 3

pf()

/*--- List transformation and uppercase

pr()

cMarkup = `
I made an {+other:list} and {fill-it-with ~1} {#1 ["one", "two", "three"]}.
Now {uppercase} them because LOUD IS BETTER!
Here they are: {?content}
`

oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> ["ONE", "TWO", "THREE"]

pf()

/*--- Global function with parameter order independence
*/
pr()

cMarkup = `
{^joinXT ~2} the strings in {#1 ["alpha", "beta", "gamma"]} using {#2 " | "}
What type is that? {?type}
{show} it
`

oNML = new stzNaturalMarkup(cMarkup)
oNML.Run()

pf()

/*--- Global function with parameter order independence
*/
pr()

cMarkup = `
Let me {^joinXT ~2} using {#2 " | "} as separator with {#1 ["alpha", "beta", "gamma"]}.
What type is that? {?type}
{show} it
`

oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> STRING
#--> alpha | beta | gamma

pf()

/*--- String creation and manipulation

	cMarkup = '
	Let me work with {+greeting:string ~1} containing {#1 "  hello world  "}.
	First, {trim-0it} to clean up spaces.
	Then {capitalize} the {greeting:string}.
	Finally {show-0it}!
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> Hello World

proff()

/*--- Method chaining with dot notation

	cMarkup = '
	Create {+data:list ~1} with {#1 ["first", "second", "third"]}.
	Get the {data:list..content..count}.
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> 3

proff()

/*--- Cross-block context references

	cMarkup = '
	I will create {+fruits:list ~1} with {#1 ["apple", "banana", "cherry"]}.
	
	Much later in my narrative...
	
	Remember {@fruits} from before? Let us {reverse} {@fruits} now.
	Show me the result: {show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> ["cherry", "banana", "apple"]

proff()

/*--- Parameter position binding with ~N declaration

	cMarkup = '
	I want to {^replace ~3} in text where {#2 "old"} becomes {#3 "new"} using {#1 "This is old text"}.
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> This is new text

proff()

/*--- Unnamed object creation

	cMarkup = '
	Create an {+list} with default empty content.
	{fill-it-with ~1} these values: {#1 ["a", "b", "c"]}.
	{show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> ["a", "b", "c"]

proff()

/*--- Complex narrative with multiple transformations

	cMarkup = '
	Yesterday I made a {+fruits:list ~1} with {#1 ["banana", "apple", "cherry"]}.
	What did I call them? {?name}
	How many are there? {?count}
	
	Actually, let me make an {+other:list} and {fill-it-with ~1} the same items as in {#1 fruits:list..content}.
	Now {uppercase} that {other:list} because LOUD FRUITS ARE BETTER!
	Here they are: {show-0it}
	
	Wait...
	What if I {^joinXT ~2} the {#1 other:list} I made above using {#2 " | "} as a separator?
	What type is that? {?type}
	Beautiful: {show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> fruits
#--> 3
#--> ["BANANA", "APPLE", "CHERRY"]
#--> STRING
#--> BANANA | APPLE | CHERRY

proff()

/*--- Testing generated code inspection

	cMarkup = '
	Create {+numbers:list ~1} with {#1 [1, 2, 3]}.
	{show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()
	
	? "Generated Ring code:"
	? oNML.GeneratedCode()

#--> [1, 2, 3]
#--> Generated Ring code:
#--> onumbers = new stzList([1, 2, 3])
#--> onumbers.Show()

proff()

/*--- SmartSplit test - preserving lists and strings

	cMarkup = 'create {+list ~1} with {#1 ["one", "two"]} and "hello" then show'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oStr = new stzString(cMarkup)
	
	? "SmartSplit result:"
	? oNML.SmartSplit(oStr)

#--> ["create", "{+list", "~1}", "with", "{#1", ["one", "two"], "}", "and", "hello", "then", "show"]

proff()

/*--- Void operator removing noise words

	cMarkup = '
	Create {+data:list ~1} with {#1 ["x", "y", "z"]}.
	Now {show-0it-0on-0screen}!
	{what-0is-0the-0name}?
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> ["x", "y", "z"]
#--> data

proff()

/*--- Multiple parameters in any order

	cMarkup = '
	Process data with {^compute ~3} where {#3 "fast"} mode is set, using {#1 [10, 20, 30]} and {#2 "sum"} operation.
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> [computed result based on parameters]

proff()

/*--- Nested lists in literals

	cMarkup = '
	Create {+matrix:list ~1} with {#1 [["a", "b"], ["c", "d"]]}.
	{show-0it}
	'
	
	oNML = new stzNaturalMarkup(cMarkup)
	oNML.Run()

#--> [["a", "b"], ["c", "d"]]

proff()
