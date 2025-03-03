
transform_to_ring <- function(data) {
  transform <- function(obj, depth = 0) {
    # Prevent excessive recursion
    if (depth > 100) {
      return("TOO_DEEP")
    }
    
    # Handle NULL and NA values explicitly
    if (is.null(obj)) {
      return("NULL")
    }
    
    # Handle lists or data frames
    if (is.list(obj) || is.data.frame(obj)) {
      items <- lapply(seq_along(obj), function(i) {
        key <- names(obj)[i]
        value <- transform(obj[[i]], depth + 1)
        if (!is.null(key)) {
          sprintf("['%s', %s]", key, value)
        } else {
          value
        }
      })
      return(paste0("[", paste(items, collapse=", "), "]"))
    }
    
    # Handle vectors or arrays
    if (is.vector(obj) || is.array(obj)) {
      if (length(obj) > 1) {
        items <- sapply(obj, function(x) {
          if (is.na(x)) return("NULL") # Changed from "NA" to "NULL"
          transform(x, depth + 1)
        })
        return(paste0("[", paste(items, collapse=", "), "]"))
      } else {
        if (is.na(obj)) return("NULL") # Changed from "NA" to "NULL"
      }
    }
    
    # Handle character strings
    if (is.character(obj)) {
      return(sprintf("'%s'", obj))
    }
    
    # Handle numeric values
    if (is.numeric(obj)) {
      # Check for scientific notation
      str_val <- as.character(obj)
      if (grepl("e", str_val, ignore.case = TRUE)) {
        return(sprintf("'%s'", str_val))
      }
      return(str_val)
    }
    
    # Handle logical values
    if (is.logical(obj)) {
      return(ifelse(obj, "TRUE", "FALSE"))
    }
    
    # Default case
    return(sprintf("'%s'", as.character(obj)))
  }
  
  transform(data, depth = 0)
}


			# Main code
			cat("R script starting...\n")
			
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

# Return results in the expected format for StzExtCodeXT
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
)
			transformed <- transform_to_ring(res)
			writeLines(transformed, "temp\\rresult_mfkt8g85.txt")
			cat("Data written to file\n")
			