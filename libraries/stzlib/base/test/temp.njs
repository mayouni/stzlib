
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


// Create a simple array
const res = [10, 20, 30, 40, 50];


console.log("Data before transformation:", res);
const transformed = transform_to_ring(res);
console.log("Data after transformation:", transformed);
require("fs").writeFileSync("jsresult.txt", transformed);
console.log("Data written to file");
