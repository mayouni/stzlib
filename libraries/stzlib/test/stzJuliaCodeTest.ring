load "../max/stzmax.ring"

/*--- Basic example in Julia

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

proff()
# Executed in 1.35 second(s) in Ring 1.22

/*------------------------------------------------#
#  Julia in Ring - Data Analysis with DataFrames  #
#-------------------------------------------------#
*/
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

proff()

/*---------------------------------------------#
#  Julia in Ring - Machine Learning with Flux  #
#----------------------------------------------#

J = new stzExtCodeXT(:julia)
J { @('
    using Flux, Statistics

    # Generate synthetic data
    x_train = collect(Float32, range(0, 10, length=100))
    y_train = 2 .* x_train .+ 1 .+ 0.2 .* randn(Float32, 100)
    
    # Define a simple linear model
    model = Dense(1 => 1)
    
    # Loss function
    loss(x, y) = Flux.mse(model(x), y)
    
    # Training data
    data = [(reshape(x_train[i:i], 1, 1), y_train[i:i]) for i in 1:length(x_train)]
    
    # Optimization
    opt = Descent(0.01)
    
    # Training loop
    losses = Float32[]
    for epoch in 1:100
        Flux.train!(loss, Flux.params(model), data, opt)
        current_loss = mean([loss(reshape([x], 1, 1), [y]) for (x, y) in zip(x_train, y_train)])
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
')
    Run()
    ? Result()
}

/*----------------------------------------------------#
#  Julia in Ring - Scientific Computing and DataViz   #
#-----------------------------------------------------#

J = new stzExtCodeXT(:julia)
J { @('
    using DifferentialEquations, LinearAlgebra, Statistics

    # Define the Lorenz system
    function lorenz!(du, u, p, t)
        σ, β, ρ = p
        du[1] = σ * (u[2] - u[1])
        du[2] = u[1] * (ρ - u[3]) - u[2]
        du[3] = u[1] * u[2] - β * u[3]
    end
    
    # Parameters and initial conditions
    p = [10.0, 8/3, 28.0]  # σ, β, ρ
    u0 = [1.0, 0.0, 0.0]
    tspan = (0.0, 20.0)
    
    # Solve the ODE
    prob = ODEProblem(lorenz!, u0, tspan, p)
    sol = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)
    
    # Sample points for visualization (reduced for simplicity)
    t_samples = range(tspan[1], tspan[2], length=100)
    points = sol(t_samples)
    
    # Extract coordinates
    x_coords = [point[1] for point in points]
    y_coords = [point[2] for point in points]
    z_coords = [point[3] for point in points]
    
    # Calculate some statistics
    function lyapunov_estimate(trajectory, dt)
        n = length(trajectory) - 1
        diffs = [norm(trajectory[i+1] - trajectory[i]) for i in 1:n]
        return sum(log.(diffs ./ dt)) / n
    end
    
    # Prepare return data
    res = Dict(
        "parameters" => Dict(
            "sigma" => p[1],
            "beta" => p[2],
            "rho" => p[3]
        ),
        "trajectory" => Dict(
            "t" => collect(t_samples),
            "x" => x_coords,
            "y" => y_coords,
            "z" => z_coords
        ),
        "statistics" => Dict(
            "x_mean" => mean(x_coords),
            "y_mean" => mean(y_coords),
            "z_mean" => mean(z_coords),
            "x_std" => std(x_coords),
            "y_std" => std(y_coords),
            "z_std" => std(z_coords),
            "estimated_lyapunov" => lyapunov_estimate(points, t_samples[2] - t_samples[1])
        ),
        "type" => "lorenz_attractor"
    )
')
    Run()
    ? Result()
}

/*-----------------------------------------------------------------#
#  Julia in Ring - Text Analysis and Natural Language Processing   #
#------------------------------------------------------------------#

J = new stzExtCodeXT(:julia)
J { @('
    # Simple text analysis without external packages
    
    sample_text = """
    Julia is a high-level, high-performance, dynamic programming language. 
    While it is a general-purpose language and can be used to write any application, 
    many of its features are well suited for numerical analysis and computational science.
    
    Distinctive aspects of Julia's design include a type system with parametric polymorphism 
    and multiple dispatch as its core programming paradigm. It allows concurrent, 
    parallel and distributed computing, and direct calling of C and Fortran libraries without glue code.
    
    Julia is garbage-collected, uses eager evaluation, and includes efficient libraries for 
    floating-point calculations, linear algebra, random number generation, and regular expression matching.
    """
    
    # Tokenize text
    function tokenize(text)
        # Convert to lowercase and replace non-alphanumeric with spaces
        processed = lowercase(replace(text, r"[^a-zA-Z0-9\s]" => " "))
        # Split by whitespace and filter out empty strings
        return filter(s -> length(s) > 0, split(processed, r"\s+"))
    end
    
    tokens = tokenize(sample_text)
    
    # Count word frequencies
    function word_frequencies(tokens)
        freqs = Dict{String, Int}()
        for token in tokens
            freqs[token] = get(freqs, token, 0) + 1
        end
        return freqs
    end
    
    word_counts = word_frequencies(tokens)
    
    # Sort by frequency
    sorted_words = sort(collect(word_counts), by=x->x[2], rev=true)
    
    # Calculate some basic statistics
    total_words = length(tokens)
    unique_words = length(word_counts)
    avg_word_length = mean(length.(tokens))
    
    # Text complexity metrics
    sentences = split(sample_text, r"[.!?]+")
    words_per_sentence = mean([length(tokenize(s)) for s in sentences if length(s) > 0])
    
    # Get top words and their frequencies
    top_n = 10
    top_words = Dict(word => count for (word, count) in sorted_words[1:min(top_n, length(sorted_words))])
    
    # Prepare results
    res = Dict(
        "text_stats" => Dict(
            "total_words" => total_words,
            "unique_words" => unique_words,
            "lexical_diversity" => round(unique_words / total_words * 100, digits=2),
            "avg_word_length" => round(avg_word_length, digits=2),
            "words_per_sentence" => round(words_per_sentence, digits=2)
        ),
        "top_words" => top_words,
        "sample" => Dict(
            "text" => sample_text[1:min(100, length(sample_text))] * "...",
            "tokens" => tokens[1:min(20, length(tokens))]
        )
    )
')
    Run()
    ? Result()
}
