
import os

// We will use string manipulation since direct type matching in V can be tricky
fn transform_to_ring(value any) string {
    if isnil(value) {
        return 'NULL'
    }
    
    type_name := typeof(value).name
    
    // Handle standard types
    if type_name == 'string' {
        str_val := value.str()
        escaped := str_val.replace("'", "''") // Escape single quotes
        return "'${escaped}'"
    }
    
    // Handle numeric types
    if type_name in ['int', 'i8', 'i16', 'i32', 'i64', 'u8', 'u16', 'u32', 'u64'] {
        return value.str()
    }
    
    if type_name in ['f32', 'f64'] {
        str_val := value.str()
        // Handle scientific notation
        if str_val.contains('e') || str_val.contains('E') {
            return "'${str_val}'"
        }
        return str_val
    }
    
    // Handle boolean
    if type_name == 'bool' {
    	str_val := '$value'
    	return if str_val.trim_space() == 'true' { 'TRUE' } else { 'FALSE' }
    }    

    // Handle arrays (assumed to be []any)
    if type_name.starts_with('array_') {
        return transform_array(value)
    }
    
    // Handle maps (assumed to be map[string]any)
    if type_name.starts_with('map[string]') {
        return transform_map(value)
    }
    
    // Handle structs by trying to convert to JSON
    if type_name != '' && !type_name.starts_with('fn ') {
        return transform_struct(value)
    }
    
    // Default fallback
    return "'${value.str()}'"
}

// Transform arrays using reflection-like approach
fn transform_array(arr any) string {
    // Try to access array elements by string representation
    str_repr := arr.str()
    
    // If it's a simple array, convert manually
    if str_repr.starts_with('[') && str_repr.ends_with(']') {
        // For simple demonstration, assume array items separated by comma
        content := str_repr[1..str_repr.len-1].trim_space()
        
        if content == '' {
            return '[]' // Empty array
        }
        
        // Simple splitting - not perfect for nested structures but works for simple cases
        items := content.split(',')
        mut transformed := []string{}
        
        for item in items {
            item_val := item.trim_space()
            // Recurse for each item, with simplistic type detection
            if item_val.starts_with("'") && item_val.ends_with("'") {
                // Likely a string
                transformed << "'${item_val[1..item_val.len-1]}'"
            } else if item_val == 'true' {
                transformed << 'TRUE'
            } else if item_val == 'false' {
                transformed << 'FALSE'
            } else if item_val.int() != 0 || item_val == '0' {
                // Likely an integer
                transformed << item_val
            } else {
                // Default case
                transformed << "'${item_val}'"
            }
        }
        
        return '[' + transformed.join(', ') + ']'
    }
    
    // Fallback for complex arrays
    return "'${str_repr}'"
}

// Transform maps using string representation and parsing
fn transform_map(m any) string {
    str_repr := m.str()
    
    // Simple map detection
    if str_repr.starts_with('{') && str_repr.ends_with('}') {
        content := str_repr[1..str_repr.len-1].trim_space()
        
        if content == '' {
            return '[]' // Empty map
        }
        
        // Split by key-value pairs (simplified, not handling nested structures properly)
        pairs := content.split(':')
        mut items := []string{}
        
        for i := 0; i < pairs.len-1; i += 2 {
            key := pairs[i].trim_space().trim("'\"")
            value := pairs[i+1].trim_space().trim(",")
            
            // Simple type detection for value
            if value.starts_with("'") && value.ends_with("'") {
                items << "['${key}', '${value[1..value.len-1]}']"
            } else if value == 'true' {
                items << "['${key}', TRUE]"
            } else if value == 'false' {
                items << "['${key}', FALSE]"
            } else if value.int() != 0 || value == '0' {
                items << "['${key}', ${value}]"
            } else {
                items << "['${key}', '${value}']"
            }
        }
        
        return '[' + items.join(', ') + ']'
    }
    
    // Fallback
    return "'${str_repr}'"
}

// Handle structs by converting to map-like representation
fn transform_struct(s any) string {
    // In V, structs don't have native reflection, so we rely on string representation
    str_repr := s.str()
    
    // Try to parse struct string representation
    if str_repr.contains('{') && str_repr.contains('}') {
        start_idx := str_repr.index('{') or { return "'${str_repr}'" }
        end_idx := str_repr.last_index('}') or { return "'${str_repr}'" }
        
        content := str_repr[start_idx+1..end_idx].trim_space()
        if content == '' {
            return '[]' // Empty struct
        }
        
        // Split by fields (this is simplified and won't handle complex nested structs perfectly)
        fields := content.split(' ')
        mut items := []string{}
        
        for field in fields {
            if field.contains(':') {
                parts := field.split(':')
                if parts.len >= 2 {
                    key := parts[0].trim_space()
                    value := parts[1].trim_space().trim(',')
                    
                    // Simple type detection
                    if value.starts_with("'") && value.ends_with("'") {
                        items << "['${key}', '${value[1..value.len-1]}']"
                    } else if value == 'true' {
                        items << "['${key}', TRUE]"
                    } else if value == 'false' {
                        items << "['${key}', FALSE]"
                    } else if value.int() != 0 || value == '0' {
                        items << "['${key}', ${value}]"
                    } else {
                        items << "['${key}', '${value}']"
                    }
                }
            }
        }
        
        return '[' + items.join(', ') + ']'
    }
    
    // Fallback
    return "'${str_repr}'"
}

// Example function to use in Ring integration
fn process_result_to_ring(result any, output_file string) {
    transformed := transform_to_ring(result)
    os.write_file(output_file, transformed) or {
        println('Error writing to file: ${err}')
        return
    }
    println('Successfully wrote result to ${output_file}')
}

fn main() {
    println("V program starting...")
    
    
    res := "Hello from V!"

    
    // Use result variable and transform it
    transformed := transform_to_ring(res)
    println("Data transformed to Ring format")
    
    // Write to output file
    os.write_file("vresult.txt", transformed) or {
        eprintln("Error writing result: ${err}")
        exit(1)
    }
    
    println("Data written to file: vresult.txt")
}
