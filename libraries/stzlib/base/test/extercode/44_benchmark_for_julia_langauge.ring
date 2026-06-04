# Narrative
# --------
# #  BENCHMARK FOR JULIA LANGAUGE  #
#
# Extracted from stzextercodetest.ring, block #44.

load "../../stzBase.ring"

#--------------------------------#

pr()

cJuliaCode = '
# 1. Fibonacci function
function fib(n)
    if n <= 1
        return n
    end
    
    a, b = 0, 1
    _a2n1_ = 2:n
    _n2n1Len_ = ring_len(_a2n1_)
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
        _nLowhigh11Len_ = ring_len(_aLowhigh11_)
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
_n1array_size1Len_ = ring_len(_a1array_size1_)
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
)'

J = new stzExterCode(:Julia)
J.SetCode(cJuliaCode)
J.Run()
? @@( J.Result() )
#--> [
#	[
#		"fibonacci",
#		[ [ "n", 450 ], [ "time_ms", 11.00 ], [ "result", -8044227546631567360.00 ] ]
#	],
#	[
#		"matrix",
#		[ [ "time_ms", 255.00 ], [ "matrix_size", 250 ] ]
#	],
#	[
#		"sorting",
#		[ [ "time_ms", 944.00 ], [ "array_size", 1000000 ] ]
#	]
# ]

pf()
# Executed in 4.18 second(s) in Ring 1.22 : AFTER FIRST STARTUP
# Executed in 2.04 second(s) in Ring 1.22 : AFTER WARM-UP
