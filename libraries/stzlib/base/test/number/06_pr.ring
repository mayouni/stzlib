# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #6.

load "../../stzBase.ring"


# In number theory, a Wieferich prime is a prime number p
# such that p2 evenly divides 2(p − 1) − 1.

# Task: Find the Wieferich primes less than 5000

# In Ruby, one can find them with sutch a concise and
# expressive line of code:
'
puts Prime.each(5000).select{|p| 2.pow(p-1 ,p*p) == 1 }
'

# In Ring, with Softanza, it's even more expressive:

? PrimesUnderQ(5000).WXT(' isWeiferich(@number) ')
#--> [ 1093, 3511 ]

pf()
# Executed in 2.41 second(s) in Ring 1.21
