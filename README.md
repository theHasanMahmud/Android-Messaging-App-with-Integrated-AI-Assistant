# 💬 Bondhu

![Flutter Version](https://img.shields.io/badge/Flutter-3.0.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**Bondhu** - A modern, feature-rich social chat application built with Flutter, implementing clean MVVM architecture, end-to-end encryption, and real-time messaging capabilities. This project demonstrates advanced Flutter development practices with robust state management and security features.

---

## ✨ Features

### 🔐 Authentication & Security
- **Phone Authentication**: Secure SMS-based authentication with Firebase
- **End-to-End Encryption**: AES-GCM encryption with X25519 key exchange
- **Secure Storage**: Encrypted local storage for sensitive data
- **Online Status Control**: Privacy settings for user visibility

### 💬 Messaging & Chat
- **Real-time Chat**: Instant messaging powered by Stream Chat SDK
- **Group Chats**: Create and manage group conversations
- **Message Reactions**: React to messages with emojis
- **Message Threads**: Organized conversation threads
- **Media Sharing**: Send photos and images in chats
- **Typing Indicators**: Real-time typing status

### 📊 Chat Management
- **Pin Chats**: Keep important conversations at the top
- **Archive Chats**: Organize conversations by archiving
- **Hide Chats**: Password-protected hidden chats feature
- **Block Users**: Block specific users from contacting you
- **Delete Chats**: Remove conversations permanently
- **Chat Search**: Find users and conversations quickly

### 👤 User Experience
- **User Discovery**: Search and find other users
- **Profile Management**: Customize your profile with photo and details
- **Presence System**: See who's online (with privacy controls)
- **Onboarding Flow**: Smooth user registration experience
- **Responsive UI**: Adaptive design for different screen sizes
- **Dark Mode Ready**: Theme system prepared for dark mode

### 🎥 Voice & Video Calls
- **Video Calls**: High-quality video calling with ZegoCloud
- **Voice Calls**: Crystal-clear voice communication
- **In-app Call UI**: Native Flutter call interface

---

## 🚀 Tech Stack

### Frontend
- **Flutter 3.0+** - Cross-platform mobile framework
- **Dart 3.0+** - Programming language
- **Stream Chat Flutter SDK** - Real-time messaging infrastructure
- **BLoC Pattern** - State management with flutter_bloc
- **GetIt** - Dependency injection
- **FPDart** - Functional programming utilities

### Backend & Services
- **Firebase Auth** - Phone authentication
- **Cloud Firestore** - User data and metadata storage
- **Stream Chat API** - Message delivery and synchronization
- **ZegoCloud** - Video/voice calling service

### Security
- **AES-GCM Encryption** - Message encryption
- **X25519 Key Exchange** - Asymmetric key agreement
- **Flutter Secure Storage** - Encrypted key storage
- **Custom Encryption Layer** - Two-layer encryption system

### Architecture
- **MVVM Architecture** - Clean separation of concerns
- **Repository Pattern** - Data layer abstraction
- **Dependency Injection** - Modular and testable code
- **Reactive Programming** - Stream-based state management

---

## 📱 Screenshots

### Authentication Flow
<table>
  <tr>
    <td align="center"><b>Landing Page</b></td>
    <td align="center"><b>Sign In</b></td>
    <td align="center"><b>SMS Verification</b></td>
    <td align="center"><b>Profile Setup</b></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/263c86d4-0d1e-4bf6-9a97-762f0baf8eb5" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/dfbbae03-a31d-414b-839d-adec763febc0" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/f9abe4f2-e41b-463a-ba0d-f2d6917f70f4" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/b392e820-00fe-4e49-93cf-2fd3534fd883" width="200"/></td>
  </tr>
</table>

### Main Features
<table>
  <tr>
    <td align="center"><b>Dashboard</b></td>
    <td align="center"><b>User Search</b></td>
    <td align="center"><b>Chat Options</b></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/c2e6c74c-4a94-4502-936d-295ef333f746" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/a4f3a5db-c060-4fcd-ae10-ef28c3ff2f35" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/b52a1363-dbf7-4500-8409-52e403031340" width="200"/></td>
  </tr>
</table>

### Chat Experience
<table>
  <tr>
    <td align="center"><b>Chat View</b></td>
    <td align="center"><b>Message Details</b></td>
    <td align="center"><b>Reactions</b></td>
    <td align="center"><b>Profile</b></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/480a9760-07be-4f78-9ded-904e0f7ce7ac" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/1dd38298-cf30-410a-a0c1-170a61d730d9" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/6005b3d5-2faa-495e-b11d-f0f8af38cf20" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/56061aff-c75f-4c16-bc01-71c0e6b6820a" width="200"/></td>
  </tr>
</table>

---

## 🏗️ Project Architecture

```
lib/
├── core/
│   ├── config/          # Environment and app configuration
│   ├── constants/       # App-wide constants and enums
│   ├── di/              # Dependency injection setup
│   ├── interfaces/      # Repository interfaces
│   ├── security/        # Encryption and key management
│   ├── services/        # Core services (preferences, etc.)
│   └── utils/           # Utility functions and helpers
├── data/
│   ├── extensions/      # Data model extensions
│   ├── remote/          # Remote API clients
│   └── repository/      # Repository implementations
│       ├── auth/        # Authentication repository
│       └── chat/        # Chat repository
├── domain/
│   └── models/          # Domain models
│       ├── auth/        # Auth user models
│       └── chat/        # Chat user models
└── presentation/
    ├── blocs/           # Business logic components
    │   ├── auth_session/
    │   ├── chat_management/
    │   ├── chat_session/
    │   ├── phone_number_sign_in/
    │   └── profile_management/
    ├── design_system/   # Reusable UI components
    │   ├── colors.dart
    │   └── widgets/
    ├── l10n/            # Localization files
    └── views/           # UI screens
        ├── archived_chats/
        ├── bottom_tab/
        ├── call/
        ├── chat/
        ├── create_chat/
        ├── dashboard/
        ├── hidden_chats/
        ├── landing/
        ├── onboarding/
        ├── profile/
        └── sign_in/
```

### Architecture Principles

**MVVM (Model-View-ViewModel)**
- **Model**: Domain models and data repositories
- **View**: Flutter widgets and UI components
- **ViewModel**: BLoC/Cubit for business logic

**Clean Architecture Benefits**
- ✅ Separation of concerns
- ✅ Testability and maintainability
- ✅ Scalability for future features
- ✅ Independent of frameworks
- ✅ Easy to understand and navigate

---

## 🔧 Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- Firebase account
- Stream Chat account
- ZegoCloud account (for video/voice calls)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/flutter_social_chat.git
cd flutter_social_chat
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your project
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - Enable **Phone Authentication** in Firebase Console
   - Set up **Cloud Firestore** database

4. **Stream Chat Setup**
   - Create an account at [Stream](https://getstream.io/)
   - Create a new Chat application
   - Note your API Key and API Secret

5. **ZegoCloud Setup** (for video/voice calls)
   - Create an account at [ZegoCloud](https://www.zegocloud.com/)
   - Create a new project
   - Note your App ID and App Sign

6. **Environment Configuration**

Create a `.env` file in the project root:

```env
# Stream Chat API Credentials
STREAM_CHAT_API_KEY=your_stream_chat_api_key
STREAM_CHAT_API_SECRET=your_stream_chat_api_secret

# ZegoCloud Credentials
ZEGO_APP_ID=your_zego_app_id
ZEGO_APP_SIGN=your_zego_app_sign

# Optional: OpenAI for AI features
OPENAI_API_KEY=your_openai_api_key
```

For detailed setup instructions, see [ENV_SETUP.md](ENV_SETUP.md)

7. **Run the app**
```bash
flutter run
```

---

## 🔐 Security Features

### End-to-End Encryption

This app implements a **two-layer encryption system**:

#### Layer 1: Device-Local Encryption
- AES-GCM encryption for messages
- Each device has unique encryption keys
- Keys stored in Flutter Secure Storage
- Automatic key generation on first use

#### Layer 2: Channel-Based Encryption
- X25519 elliptic curve key exchange
- Perfect forward secrecy
- Per-channel symmetric keys
- Encrypted key distribution via Firestore

### Privacy Controls
- Hide online status from other users
- Password-protected hidden chats
- Block users from contacting you
- Secure local storage for sensitive data

---

## 📦 Key Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.6              # State management
  stream_chat_flutter: ^9.19.0      # Chat SDK
  firebase_auth: ^5.3.3             # Authentication
  cloud_firestore: ^5.5.1           # Database
  flutter_secure_storage: ^9.2.2    # Secure storage
  get_it: ^8.0.2                    # Dependency injection
  fpdart: ^1.1.0                    # Functional programming
  go_router: ^14.6.2                # Navigation
  encrypt: ^5.0.3                   # Encryption
  cryptography: ^2.8.0              # Cryptographic operations
  zego_uikit_prebuilt_call: ^4.21.6 # Video/voice calls
```

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Check code coverage
flutter test --coverage
```

---

## 🚀 Build & Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📧 Contact

For questions or support, please open an issue in the repository.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Stream Chat](https://getstream.io/chat/) - Real-time messaging infrastructure
- [Firebase](https://firebase.google.com/) - Backend services
- [ZegoCloud](https://www.zegocloud.com/) - Video/voice calling

---

**Built with ❤️ using Flutter**
