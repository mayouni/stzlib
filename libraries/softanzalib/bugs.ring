load "stzlib.ring"

/*---- #ring

pron()

? @@( reverse([ "M", "A", "D", "A", "M" ]) )
#--> [ "M", "A", "D", "A", "M" ]

? @@( reverse([ "ب", "ا", "ب" ]) )
#o--> [ "ب", "ا", "ب" ]

proff()
# Executed in 0.02 second(s)

/*---- #ring #fix

pron()

? reverse("MADAM") # Ring function
#--> MADAM

? reverse("باب")
#o!--> �اب�

# Softanza fixes it:
? ""

? @Reverse("MADAM") # Softanza function
#--> MADAM

? @Reverse("باب")
#o--> باب

proff()
# Executed in 0.02 second(s)

/*---- #ring fix
*/
pron()

? isPalindrome("MADAM") # Ring function
#--> TRUE

? isPalindrome("باب")
#!--> FALSE
# Should be TRUE

# Softanza fixes it:

? @IsPalindrome("MADAM")
#--> TRUE

? @IsPalindrome("باب")
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*----

*/
pron()

? Q("madam").IsPalindrome()
#--> TRUE

? Q([ "M", "A", "D", "A", "M" ]).IsPalindrome()

#--

? Q("باب").IsPalindrome()
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*----

pron()

o1 = new stzString("Ri**ng program*ming lan*guage")
o1.RemoveCharsAt([ 3, 4, 15, 24 ])
? o1.Content()
#--> Ring programming language

proff()
# Executed in 0.02 second(s)

/*----
*/
pron()

? WordsIdentificationMode()
#--> :Quick

? StopWordsStatus()
#--> :MustNotBeRemoved

o1 = new stzText("A man a plan a canal Panama. Able was I ere I saw Elba. Do geese see God? Madam, in Eden, I'm Adam.")

? o1.WordsQ().YieldWX('@item', 'Q(@item).IsPalindrom()')

proff()

/*----
*/
text = "A man a plan a canal Panama. Able was I ere I saw Elba. Do geese see God? Madam, in Eden, I'm Adam."

TQ(text) {
    # First, think about the text as a collection of words
    words = Words()

    # Now, consider which words are palindromes
    palindromes = Q(words).FindWXT('{
        @item = Q(@item).Reversed() and
        len(@item) > 1
    }')

    # Among palindromes, which appear more than once?
    repeatedPalindromes = Q(palindromes).FindWXT('{
        This.NumberOfOccurrencesOf(@item) > 1
    }')

    # How many times does each repeated palindrome appear?
    result = Q(repeatedPalindromes).UniqueItemsQ().Yield('{
        [ @item, This.NumberOfOccurrencesOf(@item) ]
    }')

    return result
}

/*-----
*/

