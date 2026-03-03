# Employee Attendance Regulator (Flutter)

A Flutter-based **offline employee attendance management app** designed to help organizations track and control employee attendance efficiently.

## 📱 Features

- Manage employees (add, update, delete)
- Mark daily attendance using checkboxes
- Prevent duplicate attendance for the same day
- View attendance history per employee
- Monthly attendance overview
- Offline-first (no internet required)

## 🗄️ Local Storage

- Uses **Drift (SQLite)** for local database storage
- Relational structure for employees and attendance records
- Ensures data consistency and prevents duplicate entries

## 📅 Ethiopian Calendar Support

- Attendance dates are displayed using the **Ethiopian Calendar**
- Gregorian dates are stored internally and converted for UI display
- Uses the `ethiopian_datetime` package

## 🧩 Architecture & Tools

- Flutter
- Drift (SQLite)
- GoRouter for navigation
- Provider for dependency injection
- Ethiopian calendar date formatting

## 🚀 Use Case

This app is suitable for:
- Small organizations
- Offices with offline environments
- Daily employee attendance regulation

## © Copyright

© 2026 Dawit Misgna. All rights reserved.
Unauthorized copying, modification, or redistribution without permission is prohibited.
