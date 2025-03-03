
import re
import ast

def transform_to_ring(data):
    """
    Transform any Python data structure to Ring language format.
    Handles string escaping with proper Ring syntax.
    """
    def _transform(obj):
        if isinstance(obj, dict):
            items = []
            for key, value in obj.items():
                # Escape key if it's a string
                if isinstance(key, str):
                    escaped_key = key.replace("'", "' + char(39) + '")
                    items.append(f"['{escaped_key}', {_transform(value)}]")
                else:
                    items.append(f"['{key}', {_transform(value)}]")
            return "[" + ", ".join(items) + "]"
        elif isinstance(obj, list):
            return "[" + ", ".join(_transform(item) for item in obj) + "]"
        elif isinstance(obj, str):
            # Check if the string looks like JSON
            stripped = obj.strip()
            if (stripped.startswith("{") and stripped.endswith("}")) or \
               (stripped.startswith("[") and stripped.endswith("]")):
                try:
                    import json
                    json_obj = json.loads(stripped)
                    return _transform(json_obj)
                except Exception:
                    pass
            
            # Escape single quotes in the string for Ring compatibility
            escaped_str = obj.replace("'", "' + char(39) + '")
            return f"'{escaped_str}'"
        elif isinstance(obj, (int, float)):
            str_val = str(obj)
            if "e" in str_val.lower():  # Check for scientific notation
                return f"'{str_val}'"
            return str_val
        elif obj is None:
            return "NULL"
        elif isinstance(obj, bool):
            return str(obj).upper()  # Convert True/False to TRUE/FALSE
        else:
            # For any other type, convert to string and escape quotes
            str_val = str(obj)
            escaped_str = str_val.replace("'", "' + char(39) + '")
            return f"'{escaped_str}'"
    
    return _transform(data)


# ===== SPECIALIZED EXTRACTOR FUNCTIONS =====
# Collection of helper functions to extract data from various API responses

def transform_api_response(input_string):
    
    # Transform API response strings into a more readable Ring list format.
    
    # Args:
    #   input_string: A string representation of an API response
        
    # Returns:
    #    A string formatted as a Ring list with proper indentation and structure

    # Step 1: Parse the input string to identify structure
    # First, lwe handle the content field which might contain nested arrays

    content_pattern = re.compile(r"content='(.*?)',", re.DOTALL)
    content_match = content_pattern.search(input_string)
    
    content_placeholder = "CONTENT_PLACEHOLDER"
    content_value = None
    
    if content_match:
        content_value = content_match.group(1).strip()
        # Replace content with placeholder to simplify parsing
        input_string = input_string.replace(content_match.group(0), f"content='{content_placeholder}',")

    # Step 2: Add newlines for better parsing
    # Add newlines before each top level attribute

    formatted = re.sub(r'([a-zA-Z_]+)=', r'\n\1=', input_string)
    # Add newlines before opening brackets/parens
    formatted = re.sub(r'(\[|\()', r'\n\1', formatted)
    # Add newlines after closing brackets/parens
    formatted = re.sub(r'(\]|\))', r'\1\n', formatted)
    
    # Step 3: Parse the class structure
    # Find class names and their parameters

    class_pattern = re.compile(r'([A-Z][a-zA-Z0-9_]*)\(')
    classes = class_pattern.findall(formatted)
    
    # Step 4: Replace class names with appropriate Ring list markers

    for class_name in classes:
        formatted = formatted.replace(f"{class_name}(", "[")
    
    # Replace closing parentheses with brackets
    formatted = formatted.replace(")", "]")
    
    # Step 5: Format attributes

    # Convert attribute=value to :attribute = value
    formatted = re.sub(r'([a-zA-Z_]+)=', r':\1 = ', formatted)
    
    # Step 6: Handle special values

    # Convert None to Null
    formatted = formatted.replace(" = None", " = Null")
    
    # Step 7: Handle content restoration

    if content_value:
        try:
            # Try to parse content as Python object if it looks like a list
            if content_value.strip().startswith('[') and content_value.strip().endswith(']'):
                # Clean up the content for proper parsing
                clean_content = content_value.replace("\n", "").replace("  ", "").strip()
                content_list = ast.literal_eval(clean_content)
                
                # Format the content list with proper indentation
                content_str = "[\n"
                for item in content_list:
                    content_str += f"    {item},\n"
                content_str = content_str.rstrip(",\n") + "\n]"
                
                # Replace the placeholder with the properly formatted content
                formatted = formatted.replace(f"'{content_placeholder}'", content_str)
        except (SyntaxError, ValueError):
            # If parsing fails, keep the original content
            formatted = formatted.replace(f"'{content_placeholder}'", content_value)
    
    # Step 8: Clean up and format the final output

    # Remove extra commas before closing brackets
    formatted = re.sub(r',\s*\]', r'\n]', formatted)
    
    # Add proper indentation

    lines = formatted.split('\n')
    result = []
    indent_level = 0
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        if line.endswith(']') and indent_level > 0:
            indent_level -= 1
            
        if line.startswith(':message'):
            result.append(f"{'    ' * indent_level}{line.split(' = ')[0]} = [ # Note how Message(content= is ignored")
            indent_level += 1
            continue
            
        if line.startswith(':choices'):
            result.append(f"{'    ' * indent_level}{line.split(' = ')[0]} = [ # Note how Choices( is ignored and that :choices is its self a hashlist")
            indent_level += 1
            continue
            
        if line.startswith(':usage'):
            result.append(f"{'    ' * indent_level}{line.split(' = ')[0]} = [ # note how Usage( is ignored")
            indent_level += 1
            continue
            
        if line.startswith('[') and not line.endswith(']'):
            result.append(f"{'    ' * indent_level}[ # Note how ModelRespons( is ignored")
            indent_level += 1
            continue
        
        if line == '[':
            result.append(f"{'    ' * indent_level}{line}")
            indent_level += 1
        elif line.startswith('['):
            result.append(f"{'    ' * indent_level}{line}")
        else:
            result.append(f"{'    ' * indent_level}{line}")
            
        if line.startswith('[') and line.endswith(']') and line != '[]':
            pass
        elif line.endswith(']'):
            pass
            
    # Step 9: Final formatting touches

    final_result = "\n".join(result)
    
    # Add comments for numeric arrays

    final_result = re.sub(r'(\[\'[^\']+\', \d+, \d+\])', r'\1 # note how single qot is use instead of double quote', final_result)
    final_result = re.sub(r'(:system_fingerprint = Null)', r'\1 # Note how None is casted to Null', final_result)
    
    # Clean up any remaining artifacts

    final_result = final_result.replace("'[", "[").replace("]'", "]")
    
    return final_result

def extract_from_litellm_response(response):

    # Extract content from LiteLLM completion API response using string parsing.
    # This handles string representations of nested objects without complex object manipulation.

    # If response is already a string, use it directly
    if isinstance(response, str):
        response_str = response
    else:
        # Convert object to string representation
        response_str = str(response)
    
    # Simple function to convert Python-style representation to Ring format
    def convert_to_ring_format(text):
        # Replace class names and parentheses
        for class_name in ['ModelResponse', 'Choices', 'Message', 'Usage']:
            text = text.replace(f"{class_name}(", "[")
        
        # Replace closing parentheses with brackets
        text = text.replace(")", "]")
        
        # Replace None with NULL
        text = text.replace("None", "NULL")
        
        # Replace equals with Ring format
        text = text.replace("=", " = ")
        
        # Add colons before attribute names
        import re
        text = re.sub(r'([a-zA-Z_][a-zA-Z0-9_]*) =', r':\1 =', text)
        
        return text
    
    # Convert the response string to Ring format
    ring_formatted = convert_to_ring_format(response_str)
    
    return ring_formatted

def extract_from_openai_response(response):
    """Extract content from OpenAI API response."""
    try:
        if hasattr(response, 'choices') and response.choices:
            return response.choices[0].message.content
        return response
    except Exception as e:
        print(f"OpenAI extraction error: {e}")
        return response

def extract_from_anthropic_response(response):
    """Extract content from Anthropic Claude API response."""
    try:
        if hasattr(response, 'content') and response.content:
            for content_block in response.content:
                if content_block.get('type') == 'text':
                    text = content_block.get('text', '')
                    # Try to parse as JSON if applicable
                    if (text.startswith("{") and text.endswith("}")) or \
                       (text.startswith("[") and text.endswith("]")):
                        try:
                            import json
                            return json.loads(text)
                        except:
                            return text
                    return text
        return response
    except Exception as e:
        print(f"Anthropic extraction error: {e}")
        return response

# Add more extractors as needed for other APIs
# def extract_from_mistral_response(response):
#     # Implementation here
#     pass

# ===== MAIN EXTRACTOR FUNCTION =====

def extract_content(response, source_type=None):

    # Main extractor function that determines the type of response
    # and calls the appropriate specialized extractor.
    
    # Args:
    #    response: The API response object
    #   source_type: Optional string to specify the source API
    #               ("litellm", "openai", "anthropic", etc.)
    
    # Returns:
    #    Extracted content in the appropriate format

    # If source_type is specified, use the corresponding extractor

    if source_type:
        if source_type.lower() == 'litellm':
//            return extract_from_litellm_response(response)
	    return transform_api_response(response)

        elif source_type.lower() == 'openai':
            return extract_from_openai_response(response)

        elif source_type.lower() == 'anthropic':
            return extract_from_anthropic_response(response)

        # Add more source types as needed

        # elif source_type.lower() == "mistral":
        #     return extract_from_mistral_response(response)
    
    # If source_type is not specified, try to guess based on class name or attributes

    class_name = response.__class__.__name__ if hasattr(response, '__class__') else ''
    
    if 'ModelResponse' in class_name or 'litellm' in str(type(response)).lower():
        return extract_from_litellm_response(response)

    elif 'ChatCompletion' in class_name or 'openai' in str(type(response)).lower():
        return extract_from_openai_response(response)

    elif 'Message' in class_name and hasattr(response, 'content') and 'anthropic' in str(type(response)).lower():
        return extract_from_anthropic_response(response)
    
    # If no specific format is recognized, return the response as is
    return response

# Main code
print("Python script starting...")

from litellm import completion
import os

# set ENV variables
os.environ["OPENROUTER_API_KEY"] = "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"

res = completion(
  model="openrouter/google/palm-2-chat-bison",
  messages = [{
	"content": "Population of the 3 biggest towns in tunisia. Give just the data in a json-like list of the form: [ <town>, <population>, <yearOfLastEstimate> ], without any other description or text narration","role": "user"}],
)


print("Data before transformation:", res)
transformed = transform_to_ring(res)
print("Data after transformation:", transformed)
with open("temp\\pyresult_7uo4dmgn.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
