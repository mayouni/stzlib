# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #12.
#ERR Error (R14) : Calling Method without definition: appendedwith

load "../../stzBase.ring"


# We asked Bard AI about a python code that performs the
# Google Diff Algortithm (comparing two strings and
# showing their differences)...

# Here is the code proposed by Bard:
'
def diff(old_string, new_string):
    """Returns a list of diffs between two strings."""
    diffs = []
    i = 0
    j = 0
    while i < len(old_string) and j < len(new_string):
        if old_string[i] == new_string[j]:
            diffs.append("=")
            i += 1
            j += 1
        elif old_string[i] < new_string[j]:
            diffs.append("<")
            i += 1
        else:
            diffs.append(">")
            j += 1
    return diffs

def main():
    old_string = "This is the old string."
    new_string = "This is the new string."
    diffs = diff(old_string, new_string)
    print(diffs)

'

# When executed in Python, the code output is:
#--> [
# 	'=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=',
# 	'>', '>',
# 	'<', '<', '<', '<', '<', '<', '<', '<', '<', '<'
# ]

# Using Softanza External Code facility, we can run quiet the same
# Python code in Ring:

pr()

def main()':' 
    old_string = "This is the old string."
    new_string = "This is the new string."

    diffs = diff(old_string, new_string)
    print( @@(diffs) )

    #--> [
    #	"=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=",
    #	">", ">", ">", ">", ">", ">", ">", ">", ">", ">"
    # ]
    #--> TODO: Check the difference in output between Python and Ring+Softanza
    #--> See the difference in meaning attributed by each language to
    #    string cmparaison operators =, < and >

pf()

def diff(old_string, new_string)':' # Here we put : between quotes
    """Returns a list of diffs between two strings."""

    diffs = []
    i = 1 # Here we changed 0 by 1
    j = 1 # Idem

    while i < len(old_string) and j < len(new_string)':' # Idem

        if old_string[i] = new_string[j]
            diffs = Q(diffs).appendedWith("=") # Here we changed the semantics
            i += 1
            j += 1
        but Q(old_string[i]) < new_string[j] # Here we used Q()
            diffs = Q(diffs).appendedWith("<") # Idem
            i += 1
        else':' # Idem
            diffs = Q(diffs).appendedWith(">") # Idem
            j += 1
        ok
    end

    return diffs

# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.08 second(s) in Ring 1.20
