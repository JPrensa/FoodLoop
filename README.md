# FoodLoop

## Overview
FoodLoop is a SwiftUI iOS app (Xcode latest version, iOS 18+, Swift 5.9) for free sharing of food items and reducing food waste.

## 🌱 Project Description
FoodLoop – Food Sharing App forms a close-knit circle of chow enthusiasts dedicated to reducing food waste through sharing.  
FoodSharingApp – Your Platform Against Food Waste

![1000001478-2](https://github.com/user-attachments/assets/a0503525-5e99-4d0e-bb1d-6917d7a7a473)

## Architecture & Design
- MVVM structure:
  - Models (User, FoodItem, …)
  - ViewModels (AuthVM, HomeVM, UploadVM, MapVM, FavoritesVM, ProfileVM)
  - Views (LoginView, RegistrationView, HomeView, UploadView, MapView, FavoritesView, ProfileView)
  - Services (AuthService, FoodService, MapService, UserService)
  - Resources (Assets.xcassets, Colors, Images)
- Color palette: Green (#00A86B), White (#FFFFFF), Coffee (#6F4E37)
- Light/Dark Mode support

## Installation & Setup
1. Xcode (latest version), iOS 18+
2. Swift Package Manager:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
3. Copy `GoogleService-Info.plist` into the project directory
4. Imgur API:
   - Base URL: https://api.imgur.com
   - Client ID: `0eac2931bd2dc7e`
   - Store `Client ID` in `Info.plist` as `IMGUR_CLIENT_ID`

## Features
1. **Authentication**  
   - User registration & login via Firebase Auth (email, name, address, …)
2. **HomeView**  
   - Horizontal scroll lists:
     - Suggestions based on user preferences & location
     - Immediately available food items
3. **UploadView**  
   - Photo upload (Firebase Storage)  
   - Fields: receipt date, desired pickup time, location
4. **MapView**  
   - MapKit integration with annotations for available items  
   - Distance calculation
5. **FavoritesView**  
   - List of favorited food items (heart icon)
6. **ProfileView**  
   - User details, dark/light mode toggle  
   - Statistics of rescued food items
7. **Gamification**  
   - Badges, levels & push notifications to encourage users

## Running the App
1. Clone the repository  
2. Open the project in Xcode  
3. Resolve SwiftPM packages  
4. Run on simulator or device

## Developer / Author
[Jefferson Prensa](https://github.com/JPrensa)
