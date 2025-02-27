

def transform_to_ring(data):
    def _transform(obj):
        if isinstance(obj, dict):
            items = []
            for key, value in obj.items():
                items.append(f"['{key}', {_transform(value)}]")
            return "[" + ", ".join(items) + "]"
        elif isinstance(obj, list):
            return "[" + ", ".join(_transform(item) for item in obj) + "]"
        elif isinstance(obj, str):
            # Check if the string looks like a Python dictionary
            if obj.startswith("{") and obj.endswith("}"):
                try:
                    # Try to convert the string back to a dictionary using eval
                    # This is safe here because we know the source is from get_params()
                    dict_obj = eval(obj)
                    if isinstance(dict_obj, dict):
                        # If successful, transform the dictionary
                        return _transform(dict_obj)
                except:
                    # If eval fails, just treat it as a normal string
                    pass
            return f"'{obj}'"
        elif isinstance(obj, (int, float)):
            # Convert to string first to check for scientific notation
            str_val = str(obj)
            if "e" in str_val.lower():  # Check for scientific notation
                return f"'{str_val}'"
            return str_val
        elif obj is None:
            return "NULL"
        elif isinstance(obj, bool):
            return str(obj).upper()  # Convert True/False to TRUE/FALSE
        else:
            return f"'{str(obj)}'"
    return _transform(data)

# Main code
print("Python script starting...")

import time
import random

# 1. Fibonacci benchmark
def fib(n):
    if n <= 1:
        return n
    
    a, b = 0, 1
    for i in range(2, n + 1):
        a, b = b, a + b
    return b

# 2. Quicksort implementation
def quicksort(arr, low, high):
    if low < high:
        # Partition the array
        pivot = arr[high]
        i = low - 1
        
        for j in range(low, high):
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
for i in range(array_size):
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

for i in range(matrix_size):
    matrix1.append([0] * matrix_size)
    matrix2.append([0] * matrix_size)
    result_matrix.append([0] * matrix_size)
    
    for j in range(matrix_size):
        matrix1[i][j] = random.randint(0, 99)
        matrix2[i][j] = random.randint(0, 99)

# Matrix multiplication
for i in range(matrix_size):
    for j in range(matrix_size):
        for k in range(matrix_size):
            result_matrix[i][j] += matrix1[i][k] * matrix2[k][j]

end_time = time.time()
matrix_time = (end_time - start_time) * 1000  # Convert to milliseconds

results.append(["matrix", [
    ["matrix_size", matrix_size],
    ["time_ms", matrix_time]
]])

# Return results
res = results
print("Data before transformation:", res)
transformed = transform_to_ring(res)
print("Data after transformation:", transformed)
with open("pyresult.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
