# Narrative
# --------
# pr()
#
# Extracted from stzextinctest.ring, block #1.

load "../../../stzBase.ring"


n = -12;
vr(:sign) '=' b(n > 0) '?' bt("positive") '!!' bf("negative");
printf( v(:sign) );
#--> negative

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20
