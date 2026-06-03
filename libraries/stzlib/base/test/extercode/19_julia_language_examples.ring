# Narrative
# --------
# #  JULIA LANGUAGE EXAMPLES  #
#
# Extracted from stzextercodetest.ring, block #19.

load "../../stzBase.ring"

#===========================#

pr()

J = new stzExterCode(:julia)
J { @('
    # Your Julia code here
    using Statistics
    
    # Example data
    data = [1, 2, 3, 4, 5]
    
    # Calculate statistics
    res = Dict(
        "mean" => mean(data),
        "median" => median(data),
        "std" => std(data),
        "min" => minimum(data),
        "max" => maximum(data)
    )
')
    Run()
    ? @@( Result() )

}
#--> [
#	[ "median", 3 ],
#	[ "max", 5 ],
#	[ "min", 1 ],
#	[ "mean", 3 ],
#	[ "std", 1.58 ]
# ]

pf()
# Executed in 1.42 second(s) in Ring 1.23
