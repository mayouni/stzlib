load "stzlib.ring"

# Suppose you have a list of file names
o1 = new StzList([ "file1", "file2", "file3" ])
# And that you want to add them the .ring extension

# Well multiply the list by .ring
o1 * ".ring"

# Let's see the content of the list
? o1.Content()
