
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
            str_val = string(obj)
            # Check for scientific notation
            if occursin(r"e|E", str_val)
                return "\'$(str_val)\'"
            end
            return str_val
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
    
			transformed = transform_to_ring(res)
			println("Data before transformation: ", res)
			println("Data after transformation: ", transformed)
			open("temp\\jlresult_o460b52o.txt", "w") do f
			    write(f, transformed)
			end
			println("Data written to file")
			