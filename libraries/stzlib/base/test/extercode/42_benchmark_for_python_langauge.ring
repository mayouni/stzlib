# Narrative
# --------
# #  BENCHMARK FOR PYTHON LANGAUGE  #
#
# Extracted from stzextercodetest.ring, block #42.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#---------------------------------#

pr()

cPythonCode = '
import time
import random

# 1. Fibonacci benchmark
def fib(n):
    if n <= 1:
        return n
    
    a, b = 0, 1
    _aRange2n11_ = range(2, n + 1):
    _nRange2n11Len_ = len(_aRange2n11_)
    for _iLoopRange2n11_ = 1 to _nRange2n11Len_
    	i = _aRange2n11_[_iLoopRange2n11_]
        a, b = b, a + b
    return b

# 2. Quicksort implementation
def quicksort(arr, low, high):
    if low < high:
        # Partition the array
        pivot = arr[high]
        i = low - 1
        
        _aRangelowhigh1_ = range(low, high):
        _nRangelowhigh1Len_ = len(_aRangelowhigh1_)
        for _iLoopRangelowhigh1_ = 1 to _nRangelowhigh1Len_
        	j = _aRangelowhigh1_[_iLoopRangelowhigh1_]
            if arr[j] < pivot:
                i += 1
                arr[i], arr[j] = arr[j], arr[i]
        
        arr[i + 1], arr[high] = arr[high], arr[i + 1]
        
        partition = i + 1
        
        # Recursively sort the sub-arrays
        quicksort(arr, low, partition - 1)
        quicksort(arr, partition + 1, high)

# Performance benchmark
results = []

# 1. Fibonacci sequence benchmark
n = 450
start_time = time.time()
result = fib(n)
end_time = time.time()
fib_time = (end_time - start_time) * 1000  # Convert to milliseconds

results.append(["fibonacci", [
    ["n", n],
    ["result", result],
    ["time_ms", fib_time]
]])

# 2. Sorting benchmark
start_time = time.time()
array_size = 1000000  # One million elements
array = []

# Fill with random numbers
random.seed(42)  # Fixed seed for reproducibility
_aRangearray_size1_ = range(array_size):
_nRangearray_size1Len_ = len(_aRangearray_size1_)
for _iLoopRangearray_size1_ = 1 to _nRangearray_size1Len_
	i = _aRangearray_size1_[_iLoopRangearray_size1_]
    array.append(random.randint(0, 9999))

# Sort the array
quicksort(array, 0, array_size - 1)
end_time = time.time()
sort_time = (end_time - start_time) * 1000  # Convert to milliseconds

results.append(["sorting", [
    ["array_size", array_size],
    ["time_ms", sort_time]
]])

# 3. Matrix multiplication benchmark
start_time = time.time()
matrix_size = 250

# Initialize matrices
matrix1 = []
matrix2 = []
result_matrix = []

_aRangematrix_size5_ = range(matrix_size):
_nRangematrix_size5Len_ = len(_aRangematrix_size5_)
for _iLoopRangematrix_size5_ = 1 to _nRangematrix_size5Len_
	i = _aRangematrix_size5_[_iLoopRangematrix_size5_]
    matrix1.append([0] * matrix_size)
    matrix2.append([0] * matrix_size)
    result_matrix.append([0] * matrix_size)
    
    _aRangematrix_size4_ = range(matrix_size):
    _nRangematrix_size4Len_ = len(_aRangematrix_size4_)
    for _iLoopRangematrix_size4_ = 1 to _nRangematrix_size4Len_
    	j = _aRangematrix_size4_[_iLoopRangematrix_size4_]
        matrix1[i][j] = random.randint(0, 99)
        matrix2[i][j] = random.randint(0, 99)

# Matrix multiplication
_aRangematrix_size3_ = range(matrix_size):
_nRangematrix_size3Len_ = len(_aRangematrix_size3_)
for _iLoopRangematrix_size3_ = 1 to _nRangematrix_size3Len_
	i = _aRangematrix_size3_[_iLoopRangematrix_size3_]
    _aRangematrix_size2_ = range(matrix_size):
    _nRangematrix_size2Len_ = len(_aRangematrix_size2_)
    for _iLoopRangematrix_size2_ = 1 to _nRangematrix_size2Len_
    	j = _aRangematrix_size2_[_iLoopRangematrix_size2_]
        _aRangematrix_size1_ = range(matrix_size):
        _nRangematrix_size1Len_ = len(_aRangematrix_size1_)
        for _iLoopRangematrix_size1_ = 1 to _nRangematrix_size1Len_
        	k = _aRangematrix_size1_[_iLoopRangematrix_size1_]
            result_matrix[i][j] += matrix1[i][k] * matrix2[k][j]

end_time = time.time()
matrix_time = (end_time - start_time) * 1000  # Convert to milliseconds

results.append(["matrix", [
    ["matrix_size", matrix_size],
    ["time_ms", matrix_time]
]])

# Return results
res = results'

py = new stzExterCode(:Python)
py.setCode(cPythonCode)

py.Run()
? @@( py.Result() )
#--> [
#	[
#		"fibonacci",
#		[ [ "n", 450 ], [ "result", 4953967011875066910547013330669507468549271950815257134688446476787412478855327157343790039040.00 ], [ "time_ms", 0 ] ]
#	],
#	[
#		"sorting",
#		[ [ "array_size", 1000000 ], [ "time_ms", 3896.04 ] ]
#	],
#	[
#		"matrix",
#		[ [ "matrix_size", 250 ], [ "time_ms", 2512.93 ] ]
#	]
# ]

pf()
# Executed in 8.51 second(s) in Ring 1.22
