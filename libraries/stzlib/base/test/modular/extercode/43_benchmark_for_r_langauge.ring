# Narrative
# --------
# #  BENCHMARK FOR R LANGAUGE  #
#
# Extracted from stzextercodetest.ring, block #43.

load "../../../stzBase.ring"

#----------------------------#

cRCode = '
# 1. Fibonacci function
fib <- function(n) {
  if (n <= 1) return(n)
  
  a <- 0
  b <- 1
  for (i in 2:n) {
    temp <- a + b
    a <- b
    b <- temp
  }
  return(b)
}

# 2. Quicksort implementation
quicksort <- function(arr, low, high) {
  if (low < high) {
    # Partition the array
    pivot <- arr[high]
    i <- low - 1
    
    for (j in low:(high-1)) {
      if (arr[j] < pivot) {
        i <- i + 1
        temp <- arr[i]
        arr[i] <- arr[j]
        arr[j] <- temp
      }
    }
    
    temp <- arr[i + 1]
    arr[i + 1] <- arr[high]
    arr[high] <- temp
    
    partition <- i + 1
    
    # Recursively sort the sub-arrays
    arr <- quicksort(arr, low, partition - 1)
    arr <- quicksort(arr, partition + 1, high)
  }
  return(arr)
}

# Performance benchmark
results <- list()

# 1. Fibonacci sequence benchmark
n <- 450
start_time <- proc.time()
result <- fib(n)
end_time <- proc.time()
fib_time <- (end_time - start_time)[3] * 1000  # Convert to milliseconds

results$fibonacci <- list(
  n = n,
  result = result,
  time_ms = fib_time
)

# 2. Sorting benchmark
start_time <- proc.time()
array_size <- 1000000  # One million elements
array <- numeric(array_size)

# Fill with random numbers
set.seed(42)  # Fixed seed for reproducibility
for (i in 1:array_size) {
  array[i] <- floor(runif(1, 0, 10000))
}

# Note: For large arrays, we will use R built-in sort for performance
# but measure the time regardless
array <- sort(array)
end_time <- proc.time()
sort_time <- (end_time - start_time)[3] * 1000  # Convert to milliseconds

results$sorting <- list(
  array_size = array_size,
  time_ms = sort_time
)

# 3. Matrix multiplication benchmark
start_time <- proc.time()
matrix_size <- 250

# Initialize matrices
set.seed(42)
matrix1 <- matrix(floor(runif(matrix_size * matrix_size, 0, 100)), nrow = matrix_size)
matrix2 <- matrix(floor(runif(matrix_size * matrix_size, 0, 100)), nrow = matrix_size)

# Matrix multiplication (using R built-in operator)
result_matrix <- matrix1 %*% matrix2

end_time <- proc.time()
matrix_time <- (end_time - start_time)[3] * 1000  # Convert to milliseconds

results$matrix <- list(
  matrix_size = matrix_size,
  time_ms = matrix_time
)

# Return results in the expected format for stzExterCode
res <- list(
  list("fibonacci", list(
    list("n", n),
    list("result", result),
    list("time_ms", fib_time)
  )),
  list("sorting", list(
    list("array_size", array_size),
    list("time_ms", sort_time)
  )),
  list("matrix", list(
    list("matrix_size", matrix_size),
    list("time_ms", matrix_time)
  ))
)'

R = new stzExterCode(:R)
R.SetCode(cRCode)
R.Run()
? @@( R.Result() )
#--> [
#	[ 'fibonacci', [['n', 450], ['result', 4.95396701187506e+93], ['time_ms', 20]]],
# 	['sorting', [['array_size', 1e+06], ['time_ms', 690]]],
#	['matrix', [['matrix_size', 250], ['time_ms', 10]]]
# ]

pf()
# Executed in 4.53 second(s) in Ring 1.22
