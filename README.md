# 🚚 Bring And Take (Jib W Ddi): Transportation & Logistics Solution

**Academic Project** | Built with **Flutter** & **Firebase** & **Google Cloud**

---

## 📌 Overview

**Bring And Take**, also known as **Jib W Ddi**, is a transportation and logistics solution inspired by Uber Freight. The system connects clients who wish to send goods with verified transporters using two cross-platform mobile applications and a web-based admin panel.

Developed as part of an academic project, this platform demonstrates the integration of mobile development, geolocation services, and cloud infrastructure to build a real-time logistics experience.

---

## 📘 Full Project Report – Bring & Take Transportation & Logistics Solution

| Action       | Link                                                                                                                                                              |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Download** | [Download PDF](https://github.com/ayoubboulidam/Bring-And-Take-Transportation-Logistics-Solution/raw/main/Bring_And_Take_Transportation_&_Logistics_Solution.pdf) |

---

## 📱 Applications & Features by Role

### 👤 **Client Mobile App**

- View nearby transporters on the map
- Select departure and destination points
- Confirm and send delivery requests
- Track shipments in real time
- Receive push notifications about trip updates
- View delivery history and past orders

### 🚚 **Driver Mobile App**

- Go online/offline to indicate availability
- View and respond to client requests on map
- Accept or reject delivery requests
- Start, update, and complete delivery trips
- Confirm delivery completion and payment status

### 🧑‍💼 **Admin Web Panel**

- Manage transporter accounts (add/edit/suspend)
- Define and update trip pricing rules
- Monitor all client-driver interactions
- View usage analytics and system reports
- Block or unblock client/driver accounts

### 🧠 **System Features**

- Log and archive all client and driver actions
- Calculate distances, durations, and pricing for trips
- Provide real-time location updates for all users
- Handle system-wide push notifications using Firebase

---

## 🛠️ Technologies Used

### 📱 Frontend

- Flutter (Dart)
- Material Design

### ☁️ Backend / Cloud

- Firebase Authentication
- Firebase Realtime Database
- Firebase Cloud Messaging (FCM)
- Firebase Installations API

### 🗺️ Map & Location Services

- Google Maps SDK
- Google Directions API
- Places API
- Geocoding API

---

## 🏗️ Architecture

```
📁 bring-and-take/
├── clients_app/       # Flutter app for clients
├── drivers_app/       # Flutter app for drivers
├── admin_web/         # Web admin dashboard
└── Bring_And_Take_Transportation_&_Logistics_Solution.pdf
```

### Domain-Driven Structure

- **Core Domain**: Trip logic, booking, pricing calculations
- **Supporting Domain**: Matching logic, real-time updates, notifications
- **Generic Domain**: Authentication, user and role management

---

## ✅ Test Scenarios

- ✔️ Delivery request and confirmation
- ✔️ Trip tracking and location updates
- ✔️ Push notifications (via FCM)
- ✔️ Form validation and input handling
- ✔️ Admin account blocking

---

## ▶️ Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project configured
- Google Maps API Key

### Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/bring-and-take.git
   ```

2. **Install Dependencies**

   ```bash
   cd clients_app    # or drivers_app, or admin_web
   flutter pub get
   ```

3. **Run the App**

   ```bash
   flutter run
   ```

4. **Configure Firebase**
   - Add `google-services.json` to Android project folders
   - Add `GoogleService-Info.plist` to iOS project folders
   - Enable Firebase Auth, Realtime Database, and Cloud Messaging

---

## 👨‍💻 Contributors

- **Ayoub BOULIDAM**
- **Abdessamad Manssour**
- **Meryem El Hamdi**
- **Zineb SENHAJI**

---

## 📧 Contact

For academic or demonstration inquiries, feel free to reach out or open an issue.

---
