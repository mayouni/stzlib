# Narrative
# --------
#
# Extracted from stzpythoncodeTest.ring, block #9.

load "../../../stzBase.ring"

View("images/face.jpg")

py() {

# Python code
@('
import cv2

# Load the pre-trained Haar Cascade classifier
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")

# Load image
image = cv2.imread("images/face.jpg")

# Convert to grayscale for detection
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# Detect faces
faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

# Process results and draw on image
face_results = []
for i, (x, y, w, h) in enumerate(faces):
    # Draw orange rectangle (BGR format: orange is approximately (0, 165, 255))
    cv2.rectangle(image, (x, y), (x+w, y+h), (0, 165, 255), 2)
    
    # Calculate and draw center point
    center_x = int(x + w/2)
    center_y = int(y + h/2)
    cv2.circle(image, (center_x, center_y), 5, (0, 165, 255), 2)
    
    face_results.append({
        "face_id": i + 1,
        "bbox": [int(x), int(y), int(w), int(h)],
        "center": [center_x, center_y]
    })

# Save the annotated image
cv2.imwrite("images/face2.jpg", image)

res = {
    "total_faces": len(faces),
    "faces": face_results,
    "output_file": "images/face2.jpg"
}
')
# End of Python code

Execute()
? @@NL(Result())
View("images/face2.jpg")

}

pf()
# Executed in 5.98 second(s) in Ring 1.24
