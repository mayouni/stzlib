

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

import cv2

# Load the pre-trained Haar Cascade classifiers
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_eye.xml")
smile_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_smile.xml")

# Load image
image = cv2.imread("face-color.jpg")

# Convert to grayscale for detection
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# Detect faces
faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

# Green color in BGR
green = (0, 255, 0)

# Process results and draw annotations
face_results = []
for i, (x, y, w, h) in enumerate(faces):
    # Draw green rectangle around face
    cv2.rectangle(image, (x, y), (x+w, y+h), green, 2)
    
    # Calculate and draw center point
    center_x = int(x + w/2)
    center_y = int(y + h/2)
    cv2.circle(image, (center_x, center_y), 5, green, 2)
    
    # Add face ID label
    cv2.putText(image, f"Face {i+1}", (x, y-10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, green, 2)
    
    # Add dimensions label
    cv2.putText(image, f"{w}x{h}", (x, y+h+20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, green, 1)
    
    # Region of interest for eyes and smile detection
    roi_gray = gray[y:y+h, x:x+w]
    roi_color = image[y:y+h, x:x+w]
    
    # Detect eyes within face region
    eyes = eye_cascade.detectMultiScale(roi_gray, scaleFactor=1.1, minNeighbors=10, minSize=(20, 20))
    eye_count = 0
    for (ex, ey, ew, eh) in eyes:
        cv2.rectangle(roi_color, (ex, ey), (ex+ew, ey+eh), green, 1)
        cv2.putText(roi_color, "Eye", (ex, ey-5), cv2.FONT_HERSHEY_SIMPLEX, 0.4, green, 1)
        eye_count += 1
    
    # Detect smile within face region
    smiles = smile_cascade.detectMultiScale(roi_gray, scaleFactor=1.8, minNeighbors=20, minSize=(25, 25))
    smile_detected = len(smiles) > 0
    if smile_detected:
        for (sx, sy, sw, sh) in smiles:
            cv2.rectangle(roi_color, (sx, sy), (sx+sw, sy+sh), green, 1)
            cv2.putText(roi_color, "Smile", (sx, sy-5), cv2.FONT_HERSHEY_SIMPLEX, 0.4, green, 1)
    
    face_results.append({
        "face_id": i + 1,
        "bbox": [int(x), int(y), int(w), int(h)],
        "center": [center_x, center_y],
        "eyes_detected": eye_count,
        "smile_detected": smile_detected
    })

# Save the annotated image
cv2.imwrite("face-color2.jpg", image)

res = {
    "total_faces": len(faces),
    "faces": face_results,
    "output_file": "face-color2.jpg"
}

print("Data before transformation:", res)
transformed = transform_to_ring(res)
print("Data after transformation:", transformed)
with open("pyresult.txt", "w") as f:
    f.write(transformed)
print("Data written to file")
