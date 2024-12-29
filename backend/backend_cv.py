from flask import Flask, Response
import cv2
import numpy as np
import mediapipe as mp
from pyngrok import ngrok
from flask_cors import CORS

# Set your ngrok auth token
ngrok_auth_token = '2p2AOM2NyPHOR7xN86pwAwhPMt5_ZzkCenGhfHCAEVYsBaPG'  # Replace with your ngrok auth token
ngrok.set_auth_token(ngrok_auth_token)

# Initialize Flask app
app = Flask(__name__)  # Corrected name to __name_

# Enable CORS for frontend-backend communication
CORS(app)

# Initialize mediapipe pose module
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils

# Function to calculate angle between three points
def calculate_angle(a, b, c):
    a, b, c = np.array(a), np.array(b), np.array(c)
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    return angle if angle <= 180.0 else 360 - angle

# Video capture and exercise variables
cap = cv2.VideoCapture(0)
counter = 0
stage = None
exercise_type = None  # Define the current exercise type: "bicep_curl", "plank", "push_up", "squat"

# Function to detect exercise type and process pose
def process_pose(results, image):
    global counter, stage, exercise_type

    # Initialize variables
    landmarks = results.pose_landmarks.landmark
    height, width, _ = image.shape
    angles = {}

    try:
        coords = {
            "left_shoulder": [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x * width,
                              landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y * height],
            "right_shoulder": [landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].x * width,
                               landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].y * height],
            "left_elbow": [landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].x * width,
                           landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].y * height],
            "right_elbow": [landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW.value].x * width,
                            landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW.value].y * height],
            "left_wrist": [landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].x * width,
                           landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].y * height],
            "right_wrist": [landmarks[mp_pose.PoseLandmark.RIGHT_WRIST.value].x * width,
                            landmarks[mp_pose.PoseLandmark.RIGHT_WRIST.value].y * height],
            "left_hip": [landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].x * width,
                         landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].y * height],
            "right_hip": [landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].x * width,
                          landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].y * height],
            "left_knee": [landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].x * width,
                          landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].y * height],
            "right_knee": [landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].x * width,
                           landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].y * height],
            "left_ankle": [landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].x * width,
                           landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].y * height],
            "right_ankle": [landmarks[mp_pose.PoseLandmark.RIGHT_ANKLE.value].x * width,
                            landmarks[mp_pose.PoseLandmark.RIGHT_ANKLE.value].y * height]
        }

        # Calculate angles
        angles["left_arm"] = calculate_angle(coords["left_shoulder"], coords["left_elbow"], coords["left_wrist"])
        angles["right_arm"] = calculate_angle(coords["right_shoulder"], coords["right_elbow"], coords["right_wrist"])
        angles["left_leg"] = calculate_angle(coords["left_hip"], coords["left_knee"], coords["left_ankle"])
        angles["right_leg"] = calculate_angle(coords["right_hip"], coords["right_knee"], coords["right_ankle"])
        angles["hip"] = calculate_angle(coords["left_hip"], coords["right_hip"], coords["left_shoulder"])

        # Logic for bicep curls
        if exercise_type == "bicep_curl":
            if angles["left_arm"] > 160 and angles["right_arm"] > 160:
                stage = "down"
            if angles["left_arm"] < 30 and angles["right_arm"] < 30 and stage == "down":
                stage = "up"
                counter += 1

        # Logic for planks
        elif exercise_type == "plank":
            if angles["left_arm"] > 160 and angles["right_arm"] > 160 and angles["hip"] > 170:
                stage = "plank"
            elif stage == "plank":
                stage = "rest"
                counter += 1

        # Logic for push-ups
        elif exercise_type == "push_up":
            if angles["left_arm"] > 160 and angles["right_arm"] > 160:
                stage = "up"
            if angles["left_arm"] < 90 and angles["right_arm"] < 90 and stage == "up":
                stage = "down"
                counter += 1

        # Logic for squats
        elif exercise_type == "squat":
            if angles["left_leg"] > 160 and angles["right_leg"] > 160:
                stage = "up"
            if angles["left_leg"] < 90 and angles["right_leg"] < 90 and stage == "up":
                stage = "down"
                counter += 1

    except Exception as e:
        print("Error in processing pose:", e)

    return angles


# Video feed generator
def generate_frames(exercise_type):
    global counter, stage
    cap = cv2.VideoCapture(0)  # Reinitialize the camera capture for each route
    with mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5) as pose:
        while True:
            ret, frame = cap.read()
            if not ret:
                break

            # Recolor image to RGB
            image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            image.flags.writeable = False
            results = pose.process(image)

            # Recolor back to BGR
            image.flags.writeable = True
            image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

            # Process pose and overlay information
            if results.pose_landmarks:
                angles = process_pose(results, image)

                # Display angles on the screen
                y_offset = 30
                for key, value in angles.items():
                    cv2.putText(image, f"{key}: {int(value)}", (10, y_offset),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
                    y_offset += 20

            # Render pose landmarks
            mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)

            # Display counter and stage
            cv2.rectangle(image, (0, 0), (225, 73), (245, 117, 16), -1)
            cv2.putText(image, f"REPS: {counter}", (15, 40), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
            cv2.putText(image, f"STAGE: {stage}", (15, 70), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)

            # Encode and yield frame
            _, buffer = cv2.imencode('.jpg', image)
            yield (b'--frame\r\n' b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n')

    cap.release()  # Ensure the camera is released after use

# Update routes to pass the exercise_type to generate_frames
@app.route('/bicep_curl')
def bicep_curl():
    global exercise_type, counter, stage
    exercise_type = "bicep_curl"
    counter = 0
    stage = None
    return Response(generate_frames(exercise_type), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/plank')
def plank():
    global exercise_type, counter, stage
    exercise_type = "plank"
    counter = 0
    stage = None
    return Response(generate_frames(exercise_type), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/push_up')
def push_up():
    global exercise_type, counter, stage
    exercise_type = "push_up"
    counter = 0
    stage = None
    return Response(generate_frames(exercise_type), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/squat')
def squat():
    global exercise_type, counter, stage
    exercise_type = "squat"
    counter = 0
    stage = None
    return Response(generate_frames(exercise_type), mimetype='multipart/x-mixed-replace; boundary=frame')


@app.route('/status')
def status():
    return {"exercise": exercise_type, "reps": counter, "stage": stage}


@app.route('/stop', methods=['GET'])
def stop_camera():
    global cap
    if cap:
        cap.release()
    return "Camera stopped."



# Main app run
if __name__ == "__main__":
    # Open an ngrok tunnel to the localhost:7000
    url = ngrok.connect(7000)
    print("ngrok URL:", url)

    # Run Flask app on port 7000
    app.run(port=7000)