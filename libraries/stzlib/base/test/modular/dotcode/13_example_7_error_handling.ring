# Narrative
# --------
# #  Example 7: Error Handling  #
#
# Extracted from stzdotcodetest.ring, block #13.

load "../../../stzBase.ring"

#-----------------------------#

pr()

Dot = new stzDotCode()

Dot.SetCode('
digraph Invalid {
    # Missing closing brace to demonstrate error handling
    a -> b
')  # Intentionally invalid DOT code

try
	Dot.Execute()
catch
	? "Caught error as expected:"
	? CatchError()
	? ""
	? "Log file content:"
	? Dot.Log() #ERR #TODO // See why it is empty!
done

? ""
? "Cleanup demonstration..."
Dot.CleanupAll()
? "Temporary files cleaned up."

pf()
# Executed in 0.05 second(s) in Ring 1.24 (after using stzsystemCall class)
# Executed in 0.34 second(s) in Ring 1.24
