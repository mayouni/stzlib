
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
            _items_ = String[]
            for (key, value) in obj
                push!(_items_, "[\'$(key)\', $(_transform(value, depth + 1))]")
            end
            return "[" * join(_items_, ", ") * "]"
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
            _str_val_ = string(obj)
            # Check for scientific notation
            if occursin(r"e|E", _str_val_)
                return "\'$(str_val)\'"
            end
            return _str_val_
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

# 1. Fibonacci function
function fib(n)
    if n <= 1
        return n
    end
    
    a, b = 0, 1
    _a2n1_ = 2:n
    _n2n1Len_ = len(_a2n1_)
    for _iLoop2n1_ = 1 to _n2n1Len_
    	i = _a2n1_[_iLoop2n1_]
        a, b = b, a + b
    end
    return b
end

# 2. Quicksort implementation
function quicksort!(arr, low, high)
    if low < high
        # Partition the array
        pivot = arr[high]
        i = low - 1
        
        _aLowhigh11_ = low:(high-1)
        _nLowhigh11Len_ = len(_aLowhigh11_)
        for _iLoopLowhigh11_ = 1 to _nLowhigh11Len_
        	j = _aLowhigh11_[_iLoopLowhigh11_]
            if arr[j] < pivot
                i += 1
                arr[i], arr[j] = arr[j], arr[i]
            end
        end
        
        arr[i+1], arr[high] = arr[high], arr[i+1]
        
        partition = i + 1
        
        # Recursively sort the sub-arrays
        quicksort!(arr, low, partition - 1)
        quicksort!(arr, partition + 1, high)
    end
    return arr
end

# Performance benchmark
using Random
using LinearAlgebra

results = []

# 1. Fibonacci sequence benchmark
n = 450
start_time = time()
result = fib(n)
end_time = time()
fib_time = (end_time - start_time) * 1000  # Convert to milliseconds

push!(results, ["fibonacci", [
    ["n", n],
    ["result", result],
    ["time_ms", fib_time]
]])

# 2. Sorting benchmark
start_time = time()
array_size = 1000000  # One million elements
array = zeros(Int, array_size)

# Fill with random numbers
Random.seed!(42)  # Fixed seed for reproducibility
_a1array_size1_ = 1:array_size
_n1array_size1Len_ = len(_a1array_size1_)
for _iLoop1array_size1_ = 1 to _n1array_size1Len_
	i = _a1array_size1_[_iLoop1array_size1_]
    array[i] = rand(0:9999)
end

# Sort the array (using Julia built-in sort! for performance on large arrays)
sort!(array)
end_time = time()
sort_time = (end_time - start_time) * 1000  # Convert to milliseconds

push!(results, ["sorting", [
    ["array_size", array_size],
    ["time_ms", sort_time]
]])

# 3. Matrix multiplication benchmark
start_time = time()
matrix_size = 250

# Initialize matrices
Random.seed!(42)
matrix1 = rand(0:99, matrix_size, matrix_size)
matrix2 = rand(0:99, matrix_size, matrix_size)

# Matrix multiplication (using Julia built-in multiplication)
result_matrix = matrix1 * matrix2

end_time = time()
matrix_time = (end_time - start_time) * 1000  # Convert to milliseconds

push!(results, ["matrix", [
    ["matrix_size", matrix_size],
    ["time_ms", matrix_time]
]])

# Return results
res = Dict(
    "fibonacci" => Dict(
        "n" => n,
        "result" => result,
        "time_ms" => fib_time
    ),
    "sorting" => Dict(
        "array_size" => array_size,
        "time_ms" => sort_time
    ),
    "matrix" => Dict(
        "matrix_size" => matrix_size,
        "time_ms" => matrix_time
    )
)
_transformed_ = transform_to_ring(res)
println("Data before transformation: ", res)
println("Data after transformation: ", _transformed_)
open("jlresult.txt", "w") do f
    write(f, _transformed_)
end
println("Data written to file")
