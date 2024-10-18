import face_recognition
import cv2
import os
import mysql.connector
from datetime import datetime
from db_config import db_config

# اتصال به دیتابیس
conn = mysql.connector.connect(**db_config)
cursor = conn.cursor()

# لود کردن تصاویر افراد ثبت شده
known_faces = []
known_names = []

face_dir = 'faces/'

for person_name in os.listdir(face_dir):
    person_dir = os.path.join(face_dir, person_name)
    for img_name in os.listdir(person_dir):
        img_path = os.path.join(person_dir, img_name)
        image = face_recognition.load_image_file(img_path)
        encoding = face_recognition.face_encodings(image)[0]
        known_faces.append(encoding)
        known_names.append(person_name)

# راه‌اندازی دوربین
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # شناسایی چهره در فریم دوربین
    face_locations = face_recognition.face_locations(frame)
    face_encodings = face_recognition.face_encodings(frame, face_locations)

    for face_encoding in face_encodings:
        matches = face_recognition.compare_faces(known_faces, face_encoding)
        name = "Unknown"

        if True in matches:
            match_index = matches.index(True)
            name = known_names[match_index]

            # ذخیره ساعت حضور در دیتابیس
            now = datetime.now()
            current_time = now.strftime("%Y-%m-%d %H:%M:%S")
            cursor.execute("INSERT INTO attendance (name, time) VALUES (%s, %s)", (name, current_time))
            conn.commit()
            print(f'{name} checked in at {current_time}')

    # نمایش تصویر دوربین
    cv2.imshow('Attendance', frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
cursor.close()
conn.close()