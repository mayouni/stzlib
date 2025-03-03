
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
with open("temp\\pyresult_43hdj2ek.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
