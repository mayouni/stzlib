# Narrative
# --------
# MULTILINE WITH PROPER FORMATTING
#
# Extracted from stznaturaltest.ring, block #35.

load "../../stzBase.ring"


pr()

#TODO #ERR// if we add "." after "rounded" it fails

Naturally("
    Create a string with 'softanza'
    
    Uppercase it
    Spacify it
    
    @Box it rounded
    Display the result
    1. Create a string with 'softanza'
    2. Uppercase it
    3. Spacify it
    4. @Box it
    5. The box@ should be rounded
    6. Display the result
    7. Thanks!
")
#-->
# ╭─────────────────╮
# │ S O F T A N Z A │
# ╰─────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24
