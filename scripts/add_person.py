import cv2
import os

# ایجاد مسیر ذخیره تصاویر
face_dir = 'faces/'

# دریافت نام فرد
name = input("Enter the person's name: ")
person_dir = os.path.join(face_dir, name)

if not os.path.exists(person_dir):
    os.makedirs(person_dir)

# راه‌اندازی دوربین
cap = cv2.VideoCapture(0)

count = 0
while count < 3:
    ret, frame = cap.read()
    if not ret:
        print("Failed to capture image")
        break
    
    # نمایش تصویر
    cv2.imshow('Capture Image', frame)

    # ذخیره تصویر در سه جهت مختلف (سه عکس از فرد)
    if count < 3:
        img_path = os.path.join(person_dir, f'{name}_{count}.jpg')
        cv2.imwrite(img_path, frame)
        print(f'Image saved: {img_path}')
        count += 1
    
    # کلید 'q' برای خروج
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()