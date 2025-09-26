# EasyDrive - Car Rental Mobile Application 🚗

![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

A modern, cross-platform car rental application built with Flutter and Firebase, designed to provide seamless vehicle booking experiences for customers and efficient fleet management for administrators.

## 📱 Features

### 👥 Customer Features

* **User Authentication** - Secure registration and login system
* **Car Browsing** - Browse available vehicles with filters
* **Real-time Availability** - Check car availability for specific dates
* **Booking System** - Easy booking with payment integration
* **Profile Management** - Personal information and booking history
* **Customer Support** - Real-time chat with administrators
* **Multi-language** - Support for English and Arabic

### 👨‍💼 Admin Features

* **Fleet Management** - Add, edit, and manage vehicles
* **Booking Management** - View and manage all bookings
* **Payment Tracking** - Monitor payment status and confirm payments
* **Revenue Reports** - Generate financial reports and analytics
* **Customer Support** - Respond to customer inquiries via chat

## 🏗️ Architecture

### Tech Stack

* **Frontend**: Flutter 3.35.4 (Dart)
* **Backend**: Firebase (Firestore, Auth, Storage)
* **State Management**: Provider Pattern
* **Architecture**: MVVM (Model-View-ViewModel)

### Project Structure

```
lib/
├── models/          # Data models (Entities)
├── services/        # Business logic and Firebase services
├── providers/       # State management (ViewModels)
├── screens/         # UI components (Views)
├── widgets/         # Reusable UI components
└── utils/           # Utilities and constants
```

## 🚀 Getting Started

### Prerequisites

* Flutter SDK 3.35.4 or higher
* Dart 3.9.2 or higher
* Firebase project
* Android Studio or VS Code

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/HasanSammour/Easy-Drive_Car-Rental-App.git
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Firebase Setup**

   * Create a new Firebase project
   * Enable Authentication (Email/Password)
   * Create Firestore Database
   * Enable Storage
   * Download configuration files:

     * `google-services.json` (Android)
     * `GoogleService-Info.plist` (iOS)

4. **Configure Firebase**

   * Place configuration files in appropriate directories
   * Update Firebase security rules (provided below)

5. **Run the application**

```bash
flutter run
```

## 🔧 Configuration

### Firebase Security Rules

#### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if isAdmin();
    }
    
    // Cars: Anyone can read, only admins can write
    match /cars/{carId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Bookings: Users can access their own bookings
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null &&
        (resource.data.userId == request.auth.uid || isAdmin());
    }
    
    // Chats: Users can access their conversations
    match /chats/{chatId} {
      allow read, write: if request.auth != null &&
        (resource.data.userId == request.auth.uid ||
         resource.data.adminId == request.auth.uid);
    }
    
    function isAdmin() {
      return request.auth != null &&
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

#### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📊 Database Schema

### Collections Overview

#### Users Collection

```dart
{
  id: string,
  email: string,
  name: string,
  phone: string?,
  driverLicense: string?,
  profileImageUrl: string?,
  isAdmin: boolean,
  createdAt: timestamp
}
```

#### Cars Collection

```dart
{
  id: string,
  brand: string,
  model: string,
  type: string,
  pricePerDay: number,
  description: string,
  features: string[],
  imageUrls: string[],
  isAvailable: boolean,
  status: 'Available' | 'Booked' | 'Maintenance',
  averageRating: number?,
  totalReviews: number
}
```

#### Bookings Collection

```dart
{
  id: string,
  userId: string,
  carId: string,
  carModel: string,
  startDate: timestamp,
  endDate: timestamp,
  totalPrice: number,
  status: 'Pending' | 'Confirmed' | 'Completed' | 'Cancelled',
  createdAt: timestamp,
  isPaid: boolean,
  paymentDate: timestamp?,
  paymentMethod: string?,
  rating: number?,
  review: string?
}
```
