
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <variant>
#include <cmath>
#include <iomanip>
#include <sstream>

#define MAX_DEPTH 100

// Forward declaration
class Value;

// Types that can be stored in our Value container
using ValueType = std::variant<
    std::nullptr_t,                     // NULL
    int64_t,                            // Integer
    double,                             // Float
    std::string,                        // String
    bool,                               // Boolean
    std::vector<Value>,                 // Array
    std::map<std::string, Value>        // Object/Dict
>;

class Value {
private:
    ValueType data;

public:
    // Constructors for different types
    Value() : data(nullptr) {}
    Value(std::nullptr_t) : data(nullptr) {}
    Value(int val) : data(static_cast<int64_t>(val)) {}
    Value(int64_t val) : data(val) {}
    Value(double val) : data(val) {}
    Value(const char* val) : data(std::string(val)) {}
    Value(const std::string& val) : data(val) {}
    Value(bool val) : data(val) {}
    Value(const std::vector<Value>& val) : data(val) {}
    Value(const std::map<std::string, Value>& val) : data(val) {}

    // Type checking
    bool is_null() const { return std::holds_alternative<std::nullptr_t>(data); }
    bool is_int() const { return std::holds_alternative<int64_t>(data); }
    bool is_float() const { return std::holds_alternative<double>(data); }
    bool is_string() const { return std::holds_alternative<std::string>(data); }
    bool is_bool() const { return std::holds_alternative<bool>(data); }
    bool is_array() const { return std::holds_alternative<std::vector<Value>>(data); }
    bool is_object() const { return std::holds_alternative<std::map<std::string, Value>>(data); }

    // Value getters
    std::nullptr_t& as_null() { return std::get<std::nullptr_t>(data); }
    int64_t& as_int() { return std::get<int64_t>(data); }
    double& as_float() { return std::get<double>(data); }
    std::string& as_string() { return std::get<std::string>(data); }
    bool& as_bool() { return std::get<bool>(data); }
    std::vector<Value>& as_array() { return std::get<std::vector<Value>>(data); }
    std::map<std::string, Value>& as_object() { return std::get<std::map<std::string, Value>>(data); }

    // Const value getters
    const std::nullptr_t& as_null() const { return std::get<std::nullptr_t>(data); }
    const int64_t& as_int() const { return std::get<int64_t>(data); }
    const double& as_float() const { return std::get<double>(data); }
    const std::string& as_string() const { return std::get<std::string>(data); }
    const bool& as_bool() const { return std::get<bool>(data); }
    const std::vector<Value>& as_array() const { return std::get<std::vector<Value>>(data); }
    const std::map<std::string, Value>& as_object() const { return std::get<std::map<std::string, Value>>(data); }
};

// Transform function declarations
std::string transform_value_to_ring(const Value& value, int depth = 0);
std::string transform_array_to_ring(const std::vector<Value>& array, int depth);
std::string transform_object_to_ring(const std::map<std::string, Value>& object, int depth);

// Main transformation function
std::string transform_to_ring(const Value& value) {
    return transform_value_to_ring(value);
}

// Transform any value type to Ring string
std::string transform_value_to_ring(const Value& value, int depth) {
    // Prevent excessive recursion
    if (depth > MAX_DEPTH) {
        return "TOO_DEEP";
    }

    if (value.is_null()) {
        return "NULL";
    } 
    else if (value.is_int()) {
        return std::to_string(value.as_int());
    } 
    else if (value.is_float()) {
        std::ostringstream ss;
        ss << std::fixed << std::setprecision(15) << value.as_float();
        std::string str_val = ss.str();
        
        // Check for scientific notation
        if (str_val.find("e") != std::string::npos || str_val.find("E") != std::string::npos) {
            return "'" + str_val + "'";
        }
        
        // Trim trailing zeros and decimal point if there are no decimal digits
        size_t last_non_zero = str_val.find_last_not_of('0');
        if (last_non_zero != std::string::npos && str_val[last_non_zero] == '.') {
            str_val = str_val.substr(0, last_non_zero);
        } else if (last_non_zero != std::string::npos) {
            str_val = str_val.substr(0, last_non_zero + 1);
        }
        
        return str_val;
    } 
    else if (value.is_string()) {
        return "'" + value.as_string() + "'";
    } 
    else if (value.is_bool()) {
        return value.as_bool() ? "TRUE" : "FALSE";
    } 
    else if (value.is_array()) {
        return transform_array_to_ring(value.as_array(), depth + 1);
    } 
    else if (value.is_object()) {
        return transform_object_to_ring(value.as_object(), depth + 1);
    }
    
    return "NULL"; // Default fallback
}

// Transform an array to Ring string
std::string transform_array_to_ring(const std::vector<Value>& array, int depth) {
    std::string result = "[";
    
    for (size_t i = 0; i < array.size(); ++i) {
        result += transform_value_to_ring(array[i], depth);
        if (i < array.size() - 1) {
            result += ", ";
        }
    }
    
    result += "]";
    return result;
}

// Transform an object to Ring string
std::string transform_object_to_ring(const std::map<std::string, Value>& object, int depth) {
    std::string result = "[";
    size_t i = 0;
    
    for (const auto& [key, value] : object) {
        result += "['" + key + "', " + 
                  transform_value_to_ring(value, depth) + "]";
        
        if (i < object.size() - 1) {
            result += ", ";
        }
        ++i;
    }
    
    result += "]";
    return result;
}

// Write string to file
void write_to_file(const std::string& filename, const std::string& content) {
    std::ofstream file(filename);
    if (file.is_open()) {
        file << content;
        file.close();
    } else {
        std::cerr << "Error: Could not open file " << filename << std::endl;
    }
}

// Main transformation function used by Ring
void transform_to_ring(const Value& value, const std::string& filename) {
    std::string result = transform_value_to_ring(value);
    write_to_file(filename, result);
}

#include <iostream>
#include <string>
#include <vector>
#include <map>

int main() {
    std::cout << "C++ program starting..." << std::endl;
    
#include <iostream>
#include <vector>
#include <map>
#include <string>
#include <variant>

// Create and return an array of integers
Value create_int_array() {
    std::vector<Value> array;
    for (int i = 0; i < 5; i++) {
        array.push_back(Value(i * 10));
    }
    return Value(array);
}

// Main function to demonstrate transformation
int main() {
    Value result = create_int_array();
    transform_to_ring(result, "output.txt");
    return 0;
}

    transform_to_ring(res, "cppresult.txt");
    std::cout << "Data written to file." << std::endl;
    return 0;
}
