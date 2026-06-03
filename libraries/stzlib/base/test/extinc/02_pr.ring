# Narrative
# --------
# pr()
#
# Extracted from stzextinctest.ring, block #2.

load "../../stzBase.ring"


# Ternary operator in C-style languages (C, C#, Java, Javascript, PHP...)
# variable = (condition) ? value1 : value2;

'
n = -12;
sign = (n > 0) ? "postive" : "negative";
printf(sign);
#--> negative
'

# The same syntax in Ring (with Softanza)

n = -12;
vr(:sign) '=' b(n > 0) '?' bt("positive") ':' bf("negative");
printf( v(:sign) );
#--> negative

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21
