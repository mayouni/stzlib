const { transform_to_ring, writeResultToFile } = (() => {

const fs = require("fs");

function transform_to_ring(data) {
    return _transform(data, 0);
}

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
        if (Array.isArray(obj)) {
            // Transform array
            const items = obj.map(item => _transform(item, depth + 1));
            return "[" + items.join(", ") + "]";
        } else {
            // Transform object as key-value pairs
            const items = [];
            for (const key in obj) {
                if (Object.prototype.hasOwnProperty.call(obj, key)) {
                    items.push(`['${key}', ${_transform(obj[key], depth + 1)}]`);
                }
            }
            return "[" + items.join(", ") + "]";
        }
    }
    
    // Handle strings
    if (typeof obj === "string") {
        return `'${obj}'`;
    }
    
    // Handle numbers
    if (typeof obj === "number") {
        // Convert to string to check for scientific notation
        const strVal = String(obj);
        if (strVal.includes("e") || strVal.includes("E")) {
            return `'${strVal}'`;
        }
        return strVal;
    }
    
    // Handle booleans
    if (typeof obj === "boolean") {
        return obj ? "TRUE" : "FALSE";
    }
    
    // Default case
    return `'${String(obj)}'`;
}

// Function to write results to file
function writeResultToFile(data, filename) {
    const result = transform_to_ring(data);
    fs.writeFileSync(filename, result);
    console.log(`Result written to ${filename}`);
}

module.exports = {
    transform_to_ring,
    writeResultToFile
};

    return { transform_to_ring, writeResultToFile };
})();

console.log("NodeJS script starting...");


// Create a simple array
const res = [10, 20, 30, 40, 50];


console.log("Writing results to file...");
writeResultToFile(res, "temp\\jsresult_7azij0pi.txt");
console.log("Data written to file");
