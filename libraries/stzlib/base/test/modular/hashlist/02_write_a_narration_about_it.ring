# Narrative
# --------
# #ring #bug #todo write a narration about it
#
# Extracted from stzhashlisttest.ring, block #2.

load "../../../stzBase.ring"


pr()

# Ring autoadds an entry in a hashlist when you call it wit aHash[:key] and
# that key does not exists, which leads to subtle errors hardly debuggable
# like the fellowing example:

aHash = [
	:name = "john",
	:type = "person"
]

? @@NL( aHash )
#-->
'
[
	[ "name", "john" ],
	[ "type", "person" ]
]
'

if aHash[:age] = "" # Adds an entry implicitely which is not logical!
	aHash + [ "age", 35 ] # we explictly add the entry
ok

? @@NL( aHash )
#-->
'
[
	[ "name", "john" ],
	[ "type", "person" ],
	[ "age", "" ], # added implictely by Ring condition
	[ "age", 35 ]
]
'

? @@( aHash[:age] ) #--> captures ""! because it is the first in the list

# Softanza solves this by a quick way using Haskey(aHash, cKey) that you
# can use to check the existence of a key without any side effects:

if NOT HasKey(aHash, "age")
	aHash + [ "age", 35 ]
ok

# or by radically using a stzHashList object that offers a robuts and
# secure way to work with hashlists (does not accept duplicated keys,
# has self containmeent chechs, etx)

o1 = new stzHashList([
	[ "name", "john" ],
	[ "type", "person" ]
])

//o1.Add(:name = "ali")
#--> Can't add the pair! the key you provided already exists.
 
o1.Add(:age = 25)
? @@NL( o1.Content() )
#-->
'
[
	[ "name", "john" ],
	[ "type", "person" ],
	[ "age", 25 ]
]
'

# So you are protected, but you can enforce the check exmplicitely
# for more defensive style like this:

if NOT o1.HasKey(:job)
	o1.Add(:job = "prgrammer") # or Add([ "job", "programmer" ])
ok

? @@NL( o1.Content() )
#-->
'
[
	[ "name", "john" ],
	[ "type", "person" ],
	[ "age", 25 ],
	[ "job", "prgrammer" ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.24
