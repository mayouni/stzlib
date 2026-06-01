
function transform_to_ring(data) {
    function _transform(obj, depth = 0) {
        // Prevent excessive recursion
        if (depth > 100) {
            return "TOO_DEEP";
        }
        
        // Handle null and undefined
        if (obj === null || obj === undefined) {
            return "NULL";
        }
        
        // Handle objects (including arrays)
        if (typeof obj === "object") {
            // Handle arrays
            if (Array.isArray(obj)) {
                const items = obj.map(item => _transform(item, depth + 1));
                return "[" + items.join(", ") + "]";
            }
            
            // Handle plain objects (dictionaries)
            const items = [];
            for (const [key, value] of Object.entries(obj)) {
                items.push("['" + key + "', " + _transform(value, depth + 1) + "]");
            }
            return "[" + items.join(", ") + "]";
        }
        
        // Handle strings
        if (typeof obj === "string") {
            return "'" + obj + "'";
        }
        
        // Handle numbers
        if (typeof obj === "number") {
            const str_val = obj.toString();
            // Check for scientific notation
            if (str_val.includes("e") || str_val.includes("E")) {
                return "'" + str_val + "'";
            }
            return str_val;
        }
        
        // Handle booleans
        if (typeof obj === "boolean") {
            return obj ? "TRUE" : "FALSE";
        }
        
        // Default case
        return "'" + String(obj) + "'";
    }
    
    return _transform(data);
}

// Main code
console.log("NodeJS script starting...");


// Fibonacci function

function fib(n) {
    if (n <= 1) return BigInt(n);
    let a = BigInt(0);
    let b = BigInt(1);
    for (let i = 2; i <= n; i++) {
        let temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}

// Quicksort function

function quicksort(arr, low, high) {
    if (low < high) {
        let pivot = arr[high];
        let i = low - 1;
        for (let j = low; j < high; j++) {
            if (arr[j] < pivot) {
                i++;
                [arr[i], arr[j]] = [arr[j], arr[i]];
            }
        }
        [arr[i + 1], arr[high]] = [arr[high], arr[i + 1]];
        let partition = i + 1;
        quicksort(arr, low, partition - 1);
        quicksort(arr, partition + 1, high);
    }
}

// Matrix creation and multiplication

function createMatrix(size, randFunc) {
    let matrix = [];
    for (let i = 0; i < size; i++) {
        matrix[i] = [];
        for (let j = 0; j < size; j++) {
            matrix[i][j] = randFunc();
        }
    }
    return matrix;
}

function matrixMultiply(matrix1, matrix2) {
    let size = matrix1.length;
    let result = Array.from({ length: size }, () => Array(size).fill(0));
    for (let i = 0; i < size; i++) {
        for (let j = 0; j < size; j++) {
            for (let k = 0; k < size; k++) {
                result[i][j] += matrix1[i][k] * matrix2[k][j];
            }
        }
    }
    return result;
}

// Seeded random number generator

function createSeededRandom(seed) {
    let state = seed;
    const a = 1664525;
    const c = 1013904223;
    const m = 2**32;
    return function() {
        state = (a * state + c) % m;
        return state / m;
    };
}

function randomInt(min, max, rand) {
    return min + Math.floor(rand() * (max - min + 1));
}

// 1. Fibonacci Benchmark

const n = 450;
let startTime = process.hrtime.bigint();
const fibResult = fib(n);
let endTime = process.hrtime.bigint();
const fibTime = Number(endTime - startTime) / 1e6; // nanoseconds to milliseconds

// 2. Sorting Benchmark

const arraySize = 1000000;
let rand = createSeededRandom(42); // Set seed for reproducibility
const array = [];

for (let i = 0; i < arraySize; i++) {
    array.push(randomInt(0, 9999, rand));
}

startTime = process.hrtime.bigint();
quicksort(array, 0, arraySize - 1);
endTime = process.hrtime.bigint();
const sortTime = Number(endTime - startTime) / 1e6;

// 3. Matrix Multiplication Benchmark

const matrixSize = 250;
rand = createSeededRandom(42); // Reset seed for reproducibility
const matrix1 = createMatrix(matrixSize, () => randomInt(0, 99, rand));
const matrix2 = createMatrix(matrixSize, () => randomInt(0, 99, rand));
startTime = process.hrtime.bigint();
const resultMatrix = matrixMultiply(matrix1, matrix2);
endTime = process.hrtime.bigint();
const matrixTime = Number(endTime - startTime) / 1e6;

// Collect results in the expected format

const res = [
    ["fibonacci", [["n", n], ["result", fibResult.toString()], ["time_ms", fibTime]]],
    ["sorting", [["array_size", arraySize], ["time_ms", sortTime]]],
    ["matrix", [["matrix_size", matrixSize], ["time_ms", matrixTime]]]
];

console.log("Data before transformation:", res);
const transformed = transform_to_ring(res);
console.log("Data after transformation:", transformed);
require("fs").writeFileSync("jsresult.txt", transformed);
console.log("Data written to file");
