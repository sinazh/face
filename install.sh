#!/bin/bash

# به روزرسانی و نصب ابزارهای ضروری
echo "Updating package lists..."
sudo apt update

echo "Installing essential build tools..."
sudo apt install -y build-essential cmake python3-dev python3-pip python3-venv git mysql-server

# بررسی نصب CMake
echo "Checking if CMake is installed..."
if ! command -v cmake &> /dev/null; then
    echo "CMake not found, installing..."
    sudo apt install -y cmake
else
    echo "CMake is already installed."
fi

# کلون کردن پروژه از گیت‌هاب
echo "Cloning project from GitHub..."
if [ -d "face" ]; then
    echo "Project already exists, pulling latest changes..."
    cd face && git pull
else
    git clone https://github.com/sinazh/face.git
    cd face
fi

# نصب pipx در صورت نیاز
echo "Installing pipx..."
sudo apt install -y pipx

# تلاش برای نصب dlib از مخازن apt
echo "Attempting to install dlib via apt..."
sudo apt install -y python3-dlib

# بررسی موفقیت نصب dlib از apt
if ! python3 -c "import dlib" &> /dev/null; then
    echo "dlib not available via apt. Creating virtual environment..."
    
    # ایجاد محیط مجازی
    python3 -m venv myenv
    source myenv/bin/activate

    # ارتقاء pip و نصب dlib در محیط مجازی
    echo "Upgrading pip and installing dlib in virtual environment..."
    pip install --upgrade pip
    pip install dlib

    # بررسی نصب dlib در محیط مجازی
    if ! python -c "import dlib" &> /dev/null; then
        echo "Failed to install dlib in virtual environment."
        deactivate
        exit 1
    else
        echo "dlib successfully installed in virtual environment."
    fi
    
    deactivate
else
    echo "dlib successfully installed via apt."
fi

# نصب سایر کتابخانه‌های مورد نیاز Python
echo "Installing other Python dependencies..."
pip install -r requirements.txt

# راه‌اندازی و پیکربندی MySQL
echo "Setting up MySQL..."
sudo systemctl start mysql
sudo systemctl enable mysql

# ایجاد دیتابیس و کاربر MySQL
echo "Creating MySQL database and user..."
mysql -u root -p <<EOF
CREATE DATABASE attendance_system;
CREATE USER 'attendance_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON attendance_system.* TO 'attendance_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# اجرای برنامه
echo "Running the application..."
python3 app.py

echo "Installation and setup complete!"
