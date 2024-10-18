#!/bin/bash

# به‌روزرسانی بسته‌ها
echo "Updating packages..."
sudo apt update -y

# نصب pip و کتابخانه‌های مورد نیاز
echo "Installing Python and required libraries..."
sudo apt install -y python3-pip python3-opencv build-essential
pip3 install face_recognition mysql-connector-python

# نصب CMake
echo "Installing CMake..."
sudo apt install -y cmake

# نصب dlib
echo "Installing dlib..."
pip3 install dlib

# نصب MySQL
echo "Installing MySQL Server..."
sudo apt install -y mysql-server

# راه‌اندازی MySQL و ساخت دیتابیس و کاربر
echo "Setting up MySQL database..."
sudo systemctl start mysql
sudo mysql -u root -e "CREATE DATABASE attendance_db;"
sudo mysql -u root -e "CREATE USER 'attendance_user'@'localhost' IDENTIFIED BY 'StrongPassword123';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON attendance_db.* TO 'attendance_user'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# ساخت فایل تنظیمات اتصال به دیتابیس
echo "Creating database configuration file..."
cat << EOF > /opt/attendance_system/db_config.py
db_config = {
    'host': 'localhost',
    'user': 'attendance_user',
    'password': 'StrongPassword123',
    'database': 'attendance_db'
}
EOF

# تنظیم پوشه پروژه و کلون کردن از گیت‌هاب
echo "Cloning project from GitHub..."
if [ -d "/opt/attendance_system" ]; then
    sudo rm -rf /opt/attendance_system
fi
sudo git clone https://github.com/sinazh/face.git /opt/attendance_system

# تنظیم فایل سرویس systemd
echo "Setting up systemd service..."
sudo bash -c 'cat << EOF > /etc/systemd/system/attendance_service.service
[Unit]
Description=Face Recognition Attendance System
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/attendance_system/main.py
Restart=always
User=root
WorkingDirectory=/opt/attendance_system
StandardOutput=inherit
StandardError=inherit
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

# فعال‌سازی سرویس
sudo systemctl daemon-reload
sudo systemctl enable attendance_service
sudo systemctl start attendance_service

echo "Installation complete!"
echo "The attendance system is now running as a service."
