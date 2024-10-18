import subprocess

# اجرای بخش ثبت چهره یا شناسایی
while True:
    print("1. Add New Person")
    print("2. Recognize and Register Attendance")
    choice = input("Choose an option: ")

    if choice == '1':
        subprocess.run(["python3", "scripts/add_person.py"])
    elif choice == '2':
        subprocess.run(["python3", "scripts/recognize.py"])
    else:
        print("Invalid choice!")