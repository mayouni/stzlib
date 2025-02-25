
function transform_to_ring(data)
    function _transform(obj, depth=0)
        # Prevent excessive recursion
        if depth > 100
            return "TOO_DEEP"
        end
        
        # Handle nothing/missing values
        if obj === nothing
            return "NULL"
        end
        
        # Handle dictionaries
        if isa(obj, Dict)
            items = String[]
            for (key, value) in obj
                push!(items, "[\'$(key)\', $(_transform(value, depth + 1))]")
            end
            return "[" * join(items, ", ") * "]"
        end
        
        # Handle arrays
        if isa(obj, AbstractArray)
            return "[" * join([_transform(item, depth + 1) for item in obj], ", ") * "]"
        end
        
        # Handle strings
        if isa(obj, AbstractString)
            return "\'$(obj)\'"
        end
        
        # Handle numeric values
        if isa(obj, Number)
            return string(obj)
        end
        
        # Handle boolean values
        if isa(obj, Bool)
            return obj ? "TRUE" : "FALSE"
        end
        
        # Default case: convert to string
        return "\'$(string(obj))\'"
    end
    
    return _transform(data)
end

# Main code
println("Julia script starting...")

    using DataFrames, Statistics, Dates

    # Create a sample dataset
    df = DataFrame(
        date = Date.(2023, 1, 1:10),
        sales = [120, 145, 132, 168, 175, 190, 208, 216, 192, 223],
        costs = [80, 85, 90, 88, 94, 96, 98, 103, 110, 115],
        region = repeat(["North", "South", "East", "West"], 2, outer=true)[1:10]
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
    
transformed = transform_to_ring(res)
println("Data before transformation: ", res)
println("Data after transformation: ", transformed)
open("jlresult.txt", "w") do f
    write(f, transformed)
end
println("Data written to file")
