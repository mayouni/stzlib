load "../stzbase.ring"

/*========

pr()

# In Perl (Raku) language we write:
"
rand = 0.7;
say rand < 0.5 ?? 'Yes' !! 'No';
#--> No
"

# In Ring with Softanza we also write:

rand = 0.7;
say { b(rand < 0.5) '??' bt('Yes') '!!' bf('No') };
#--> No

# b ~> boolean condition
# bf ~> FALSE case
# bt ~> TRUE case

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21
