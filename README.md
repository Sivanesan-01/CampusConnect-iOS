# 🎓 CampusConnect

> A modern college event & communication iOS application built using UIKit, Storyboard, Core Data, Firebase Authentication, and MapKit.
---

# 📱 About The Project

CampusConnect is a student-focused iOS application designed to simplify campus communication and event management.

Students can:

* 🎉 Discover campus events
* ❤️ Save favorite events
* 🏛️ Create clubs
* 📅 Host events
* 📍 View event locations on map
* 🔔 Receive notifications
* 👤 Manage profiles
* 💳 Enroll in events

The application centralizes all campus-related activities into one modern mobile experience.

---

# ✨ Features

## 🔐 Authentication

* Firebase Email Authentication
* Sign In / Sign Up
* OTP Verification Popup
* Persistent Login Session using UserDefaults

## 🏠 Home Feed

* Search events & clubs
* Category filtering
* Featured events
* Event cards with modern UI
* Favorite functionality

## 🏛️ Club Management

* Create clubs
* Upload club images
* Add and publish events

## 📅 Event System

* Event detail page
* Participation flow
* Schedule section
* Enrollment system
* Payment UI

## ❤️ Favorites

* Save favorite events

## 🔔 Notifications

* Event reminders
* Club updates
* Notice board system

## 🗺️ Map Integration

* Event location annotations using MapKit
* View enrolled event locations

## 💾 Local Storage

* Core Data persistence
* Offline event storage
* User profile storage

---

# 🛠️ Tech Stack

| Technology              | Usage                |
| ----------------------- | -------------------- |
| UIKit                   | User Interface       |
| Storyboard              | UI Design            |
| Swift                   | Programming Language |
| Core Data               | Local Database       |
| Firebase Authentication | User Authentication  |
| MapKit                  | Event Locations      |
| MVC Architecture        | App Structure        |
| UITableView             | Event Feed           |
| UICollectionView        | Categories           |
| UserDefaults            | Session Management   |

---

# 🧠 Architecture

The application follows the **MVC (Model-View-Controller)** architecture pattern.

```text
View → Controller → Model
```

This structure keeps the application scalable, modular, and beginner-friendly.

---

# 📂 Project Structure

```text
CampusConnect
│
├── App
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│
├── Controllers
│   ├── Auth
│   ├── Main
│   ├── Payment
│   ├── Tabs
│
├── Managers
│   ├── AuthManager.swift
│   ├── CoreDataManager.swift
│   ├── SessionManager.swift
│   ├── MainTabBarController.swift
│
├── Resources
│   ├── Assets.xcassets
│   ├── GoogleService-Info.plist
│
├── Storyboards
│   ├── Auth.storyboard
│   ├── Main.storyboard
│   ├── LaunchScreen.storyboard
│
├── Views
│   ├── Cells
│   ├── Components
│
└── Package Dependencies
```

---

# 📸 Screens Included

* 🚀 Splash Screen
* 🔑 Sign In
* 📝 Sign Up
* 🔐 OTP Verification
* 🏠 Home
* 🎫 Event Details
* 🏛️ Club Formation
* ➕ Add Event
* ❤️ Favorites
* 📜 Participation History
* 💳 Payment
* 🔔 Notifications
* 🗺️ Map
* 👤 Profile

---

# 🎨 UI/UX Design

The application follows modern iOS UI principles:

* Soft purple/blue theme
* Rounded cards
* Minimal design
* SF Pro typography
* Smooth spacing & alignment
* Apple Human Interface Guidelines

### 🎨 Color Palette

| Purpose    | Hex       |
| ---------- | --------- |
| Primary    | `#4F46E5` |
| Secondary  | `#818CF8` |
| Background | `#F8FAFC` |
| Text       | `#111827` |

---

# 🔥 Firebase Setup

Firebase Authentication is integrated for:

* Email Sign In
* Email Sign Up
* OTP Verification

### Installed Using Swift Package Manager:

```text
https://github.com/firebase/firebase-ios-sdk
```

---

# 💾 Core Data

Core Data is used for:

* Event persistence
* Favorite events
* Participation history
* User profile storage
* Notifications
* Club details

---


