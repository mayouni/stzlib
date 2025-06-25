load "../stzmax.ring"

/*--- Basic example in Julia
*/
pr()

jl() { @('
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
    ') # end of the Julia code

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
# Executed in 1.35 second(s) in Ring 1.22

/*------------------------------------------------#
#  Julia in Ring - Data Analysis with DataFrames  #
#-------------------------------------------------#

pr()

jl() { @('
    using DataFrames, Statistics, Dates

    # Create a sample dataset with corrected region assignment
    regions = ["North", "South", "East", "West", "North", "South", "East", "West", "North", "South"]
    
    df = DataFrame(
        date = Date.(2023, 1, 1:10),
        sales = [120, 145, 132, 168, 175, 190, 208, 216, 192, 223],
        costs = [80, 85, 90, 88, 94, 96, 98, 103, 110, 115],
        region = regions
    )
    
    # Add calculated columns
    df.profit = df.sales .- df.costs
    df.margin = round.(df.profit ./ df.sales .* 100, digits=2)
    
    # Group by region
    by_region = combine(groupby(df, :region), 
        :sales => sum => :total_sales,
        :profit => sum => :total_profit,
        :margin => mean => :avg_margin
    )
    
    # Find best performing region
    best_region = by_region[argmax(by_region.total_profit), :region]
    
    # Aggregate metrics
    res = Dict(
        "summary" => Dict(
            "total_sales" => sum(df.sales),
            "total_profit" => sum(df.profit),
            "avg_margin" => mean(df.margin),
            "best_region" => best_region
        ),
        "by_region" => Dict(
            by_region.region[i] => Dict(
                "sales" => by_region.total_sales[i],
                "profit" => by_region.total_profit[i],
                "margin" => by_region.avg_margin[i]
            ) for i in 1:nrow(by_region)
        ),
        "daily" => Dict(
            "dates" => string.(df.date),
            "profits" => df.profit
        )
    )
')
    Run()
    ? @@NL( Result() )
}
#--> [
#	[
#		"summary",
#		[
#			[ "best_region", "South" ],
#			[ "avg_margin", 44.62 ],
#			[ "total_sales", 1769 ],
#			[ "total_profit", 810 ]
#		]
#	],
#	[
#		"by_region",
#		[
#			[
#				"East",
#				[ [ "sales", 340 ], [ "profit", 152 ], [ "margin", 42.35 ] ]
#			],
#			[
#				"West",
#				[ [ "sales", 384 ], [ "profit", 193 ], [ "margin", 49.97 ] ]
#			],
#			[
#				"North",
#				[ [ "sales", 487 ], [ "profit", 203 ], [ "margin", 40.78 ] ]
#			],
#			[
#				"South",
#				[ [ "sales", 558 ], [ "profit", 262 ], [ "margin", 46.43 ] ]
#			]
#		]
#	],
#	[
#		"daily",
#		[
#			[ "dates", [ "2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04", "2023-01-05", "2023-01-06", "2023-01-07", "2023-01-08", "2023-01-09", "2023-01-10" ] ],
#			[ "profits", [ 40, 60, 42, 80, 81, 94, 110, 113, 82, 108 ] ]
#		]
#	]
# ]

pf()
# Executed in 3.30 second(s) in Ring 1.22

/*---------------------------------------------#
#  Julia in Ring - Machine Learning with Flux  #
#----------------------------------------------#

pr()

jl() { @('
	using Flux, Statistics, Optimisers
	
	# Generate synthetic data
	x_train = collect(Float32, range(0, 10, length=100))
	y_train = 2 .* x_train .+ 1 .+ 0.2 .* randn(Float32, 100)
	
	# Reshape data for Flux
	x_batched = reshape(x_train, 1, :)
	y_batched = reshape(y_train, 1, :)
	
	# Define a simple linear model
	model = Dense(1 => 1)
	
	# Set up optimizer with the modern approach
	optimizer = Optimisers.setup(Optimisers.Descent(0.01), model)
	
	# Training loop
	losses = Float32[]
	for epoch in 1:100
	    # Define loss function
	    function loss_fn(m)
	        pred = m(x_batched)
	        return Flux.mse(pred, y_batched)
	    end
	    
	    # Compute gradient
	    gs = Flux.gradient(m -> loss_fn(m), model)
	    
	    # Update parameters with optimizers - declare variables as global
	    global optimizer, model = Optimisers.update(optimizer, model, gs[1])
	    
	    # Record loss
	    current_loss = loss_fn(model)
	    push!(losses, current_loss)
	end
	
	# Extract learned parameters
	slope = model.weight[1]
	intercept = model.bias[1]
	
	# Make predictions
	x_test = collect(Float32, range(0, 10, length=10))
	predictions = vec(model(reshape(x_test, 1, :)))
	
	# Return results
	res = Dict(
	    "model_params" => Dict(
	        "slope" => slope,
	        "intercept" => intercept
	    ),
	    "training" => Dict(
	        "initial_loss" => losses[1],
	        "final_loss" => losses[end],
	        "improvement_pct" => round((1 - losses[end]/losses[1]) * 100, digits=2)
	    ),
	    "predictions" => Dict(
	        "x" => x_test,
	        "y" => predictions,
	        "actual_function" => "y = 2x + 1"
	    )
	)
	') # End of julia code

	# Back to Ring

	Run()
	? @@( Result() )
}
#--> [
#	[
#		"model_params",
#		[ [ "slope", 2.08 ], [ "intercept", 0.50 ] ]
#	],
#	[
#		"predictions",
#		[
#			[ "actual_function", "y = 2x + 1" ],
#			[ "x", [ 0, 1.11, 2.22, 3.33, 4.44, 5.56, 6.67, 7.78, 8.89, 10 ] ],
#			[ "y", [ 0.50, 2.81, 5.12, 7.43, 9.73, 12.04, 14.35, 16.66, 18.97, 21.27 ] ]
#		]
#	],
#	[
#		"training",
#		[ [ "initial_loss", 8.86 ], [ "final_loss", 0.09 ], [ "improvement_pct", 99.04 ] ]
#	]
# ]

pf()
# Executed in 14.36 second(s) in Ring 1.22
