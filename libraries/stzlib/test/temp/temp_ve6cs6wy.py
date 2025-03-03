
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

function extract_from_litellm_response(response) {
    // Convert to string if not already a string
    const responseStr = typeof response === 'string' ? response : String(response);
    
    // Simple function to convert JS object string representation to Ring format
    function convertToRingFormat(text) {
        // Replace class names and opening parentheses
        const classNames = ['ModelResponse', 'Choices', 'Message', 'Usage'];
        let result = text;
        
        classNames.forEach(className => {
            result = result.replace(new RegExp(`${className}\\(`, 'g'), '[');
        });
        
        // Replace closing parentheses with brackets
        result = result.replace(/\)/g, ']');
        
        // Replace null/undefined with NULL
        result = result.replace(/null|undefined/g, 'NULL');
        
        // Replace equals with Ring format
        result = result.replace(/=/g, ' = ');
        
        // Add colons before attribute names
        result = result.replace(/([a-zA-Z_][a-zA-Z0-9_]*) = /g, ':$1 = ');
        
        return result;
    }
    
    // Convert the response string to Ring format
    const ringFormatted = convertToRingFormat(responseStr);
    
    return ringFormatted;
}

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
            return extract_from_litellm_response(response)

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
with open("temp\\pyresult_ve6cs6wy.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
