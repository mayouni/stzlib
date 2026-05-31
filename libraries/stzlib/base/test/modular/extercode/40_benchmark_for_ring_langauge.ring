# Narrative
# --------
# #  BENCHMARK FOR RING LANGAUGE  #
#
# Extracted from stzextercodetest.ring, block #40.

load "../../../stzBase.ring"

#-------------------------------#

pr()

    results = []
    
    # 1. Fibonacci benchmark
    #------------------------

    n = 450
    startTime = clock()
    result = ringFib(n)
    endTime = clock()
    fibTime = (endTime - startTime) / clockspersecond() * 1000
    
    add(results, ["fibonacci", [
        ["n", n],
        ["result", result],
        ["time_ms", fibTime]
    ]])
    

    # 2. Sorting benchmark
    #----------------------

    startTime = clock()
    arraySize = 1000_000
    array = list(arraySize)
    
    # Fill with random numbers (using same seed as C)

    random(42)  // Set seed
    for i = 1 to arraySize
        array[i] = random(9999)
    next
    
    # Sort the array

    ringQuickSort(array, 1, arraySize)
    endTime = clock()
    sortTime = (endTime - startTime) / clockspersecond() * 1000
    
    add(results, ["sorting", [
        ["array_size", arraySize],
        ["time_ms", sortTime]
    ]])
    

    # 3. Matrix multiplication benchmark
    #------------------------------------

    startTime = clock()
    matrixSize = 250
    
    # Initialize matrices

    matrix1 = list(matrixSize)
    matrix2 = list(matrixSize)
    resultMatrix = list(matrixSize)
    
    for i = 1 to matrixSize
        matrix1[i] = list(matrixSize)
        matrix2[i] = list(matrixSize)
        resultMatrix[i] = list(matrixSize)
        
        for j = 1 to matrixSize
            matrix1[i][j] = random(99)
            matrix2[i][j] = random(99)
            resultMatrix[i][j] = 0
        next
    next
    
    # Matrix multiplication

    for i = 1 to matrixSize
        for j = 1 to matrixSize
            for k = 1 to matrixSize
                resultMatrix[i][j] += matrix1[i][k] * matrix2[k][j]
            next
        next
    next
    
    endTime = clock()
    matrixTime = (endTime - startTime) / clockspersecond() * 1000
    
    add(results, ["matrix", [
        ["matrix_size", matrixSize],
        ["time_ms", matrixTime]
    ]])
    
? @@( results )
#--> [
#	[
#		"fibonacci",
#		[ [ "n", 450 ], [ "result", 4953967011875060426190016040962563748574111464292417351569305200915826269230622714208530202624.00 ], [ "time_ms", 1 ] ]
#	],
#	[
#		"sorting",
#		[ [ "array_size", 1000000 ], [ "time_ms", 29923 ] ]
#	],
#	[
#		"matrix",
#		[ [ "matrix_size", 250 ], [ "time_ms", 7805 ] ]
#	]
# ]

pf()
# Executed in 25.63 second(s) in Ring 1.23

# Ring fibonacci implementation

func ringFib n
    if n <= 1 return n ok
    
    a = 0 b = 1
    for i = 2 to n
        temp = a + b
        a = b
        b = temp
    next
    return b

# Ring quicksort implementation

func ringQuickSort arr, low, high
    if low < high
        // Partition the array
        pivot = arr[high]
        i = low - 1
        
        for j = low to high - 1
            if arr[j] < pivot
                i++
                temp = arr[i]
                arr[i] = arr[j]
                arr[j] = temp
            ok
        next
        
        temp = arr[i + 1]
        arr[i + 1] = arr[high]
        arr[high] = temp
        
        partition = i + 1
        
        // Recursively sort the sub-arrays
        ringQuickSort(arr, low, partition - 1)
        ringQuickSort(arr, partition + 1, high)

   ok
