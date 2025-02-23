


function transform_to_ring(data)
    if isa(data, Dict)
        items = []
        for (key, value) in data
            push!(items, "['" * string(key) * "', " * transform_to_ring(value) * "]")
        end
        return "[" * join(items, ", ") * "]"
    elseif isa(data, Array)
        return "[" * join([transform_to_ring(item) for item in data], ", ") * "]"
    elseif isa(data, String)
        return "'" * replace(data, "'" => "\\'") * "'"
    elseif isa(data, Number)
        return string(data)
    elseif isa(data, Bool)
        return string(data)
    else
        return "'" * string(data) * "'"
    end
end


# Main code


data = Dict("key1" => [1, 2, 3], "key2" => "value")


transformed = transform_to_ring(data)

# Write data to file without printing to console
open("' + @cDataFile + '", "w") do f
    write(f, transformed)
end
