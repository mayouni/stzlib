load "stzlib.ring"

/*----
*/
pron()

o1 = new stzString("Ri**ng program*ming lan*guage")
o1.RemoveCharsAt([ 3, 4, 15, 24 ])
? o1.Content()
#--> Ring programming language

proff()
# Executed in 0.02 second(s)

/*----

text = "A man a plan a canal Panama. Able was I ere I saw Elba. Do geese see God? Madam, in Eden, I'm Adam."

TQ(text) {
    # First, think about the text as a collection of words
    words = WordsQ()

    # Now, consider which words are palindromes
    palindromes = words.FindWXT('{
        @item = Q(@item).Reversed() and
        len(@item) > 1
    }')

    # Among palindromes, which appear more than once?
    repeatedPalindromes = palindromes.FindWXT('{
        This.NumberOfOccurrencesOf(@item) > 1
    }')

    # How many times does each repeated palindrome appear?
    result = repeatedPalindromes.UniqueItemsQ().MapW('{
        [ @item, This.NumberOfOccurrencesOf(@item) ]
    }')

    return result
}

/*-----
*/

