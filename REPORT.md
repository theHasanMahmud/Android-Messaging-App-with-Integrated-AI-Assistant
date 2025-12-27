# 📱 Project Report

## Course: CSE489 Final Project
**Submitted By**: Hasan Mahmud Mazumder 
**Student ID**: ______ 
**Date**: December 10, 2025

---

## 📋 Project Title

**Bondhu: To Understand the Technology of Secure Real-Time Messaging Systems**

A comprehensive mobile application demonstrating modern messaging technologies including end-to-end encryption, real-time communication, and advanced privacy features.

---

## 🎯 Project Objectives

The primary objective of this project was to understand and implement:

1. **Authentication Technology**: Implementing secure phone-based authentication systems
2. **Real-time Communication**: Understanding WebSocket-based messaging protocols
3. **Encryption Technology**: Implementing end-to-end encryption for secure communications
4. **State Management**: Learning modern state management patterns in Flutter
5. **Database Architecture**: Understanding NoSQL database design and real-time synchronization

---

## ✨ Project Features

By the end of this course, the following features were successfully implemented:

### 1. Login System
- **Phone Authentication**: Firebase phone authentication with SMS verification
- **OTP Verification**: 6-digit code verification system
- **Session Management**: Persistent login using secure token storage
- **User Onboarding**: Profile creation flow for new users
- **Auto-login**: Automatic authentication on app restart

### 2. Messaging System
- **Real-time Chat**: Instant message delivery using Stream Chat SDK
- **Text Messages**: Support for text-based communication
- **Media Sharing**: Image, video, and file attachment support
- **Message Status**: Read receipts and delivery confirmations
- **Typing Indicators**: Real-time typing status updates

### 3. End-to-End Encryption
- **Two-Layer Encryption**: 
  - Device-local AES-GCM encryption
  - Channel-based X25519 key exchange encryption
- **Key Management**: Secure key generation and storage
- **Perfect Forward Secrecy**: Ephemeral keys for enhanced security
- **Encrypted Storage**: All encryption keys stored in Flutter Secure Storage

### 4. Chat Management System
- **Pin Chats**: Pin important conversations to the top
- **Archive Chats**: Archive old conversations for clean dashboard
- **Hide Chats**: Password-protected hidden chats feature
- **Block Users**: Block unwanted users from messaging
- **Delete Chats**: Permanently remove conversations

### 5. Privacy Features
- **Online Status Control**: Toggle online/invisible status
- **Last Seen Privacy**: Control visibility of activity status
- **Read Receipt Control**: Manage read receipt visibility
- **Profile Privacy**: Control who can view profile information

### 6. Voice & Video Calling
- **Voice Calls**: One-on-one voice calling using ZegoCloud
- **Video Calls**: Real-time video calling with WebRTC
- **Call Notifications**: Incoming call notifications

### 7. User Interface Features
- **Responsive Design**: Adaptive UI for different screen sizes
- **Dark/Light Theme**: Theme switching support
- **Animations**: Smooth transitions and loading animations
- **Search Functionality**: Search users and messages
- **Profile Management**: Edit profile, photo, and username

---

## 📸 Screenshots

### Authentication Flow
![Landing Screen](screenshots/landing.png)
![Sign In Screen](screenshots/signin.png)
![SMS Verification](screenshots/sms_verification.png)
![Onboarding Screen](screenshots/onboarding.png)

### Main Application
![Dashboard](screenshots/dashboard.png)
![Chat View](screenshots/chat_view.png)
![Profile Screen](screenshots/profile.png)
![Chat Management](screenshots/chat_management.png)

### Features
![Online Status Toggle](screenshots/online_status.png)
![Encryption Indicator](screenshots/encryption.png)
![Video Call](screenshots/video_call.png)

*Note: Screenshots are located in the `screenshots/` directory*

---

## 🛠️ Technology Stack

### Frontend Development
- **Flutter 3.0+**: Cross-platform mobile development framework
- **Dart 3.0+**: Programming language
- **Material Design**: UI component library

### State Management
- **flutter_bloc**: Reactive state management using BLoC pattern
- **hydrated_bloc**: State persistence for offline support
- **get_it**: Dependency injection

### Backend Services
- **Firebase Authentication**: Phone-based user authentication
- **Cloud Firestore**: NoSQL database for user data and metadata
- **Stream Chat SDK**: Real-time messaging infrastructure
- **ZegoCloud**: Video and voice calling services

### Security & Encryption
- **cryptography**: X25519 key exchange for channel encryption
- **encrypt**: AES-GCM encryption for message content
- **flutter_secure_storage**: Secure key storage on device

### Navigation & Routing
- **go_router**: Declarative routing and navigation

### Additional Libraries
- **image_picker**: Image and video selection
- **file_picker**: Document attachment support
- **connectivity_plus**: Network status monitoring
- **share_plus**: Content sharing functionality

---

## 🌐 Online Resources Used

### a) Reference Documentation

**Official Documentation:**
- Flutter Documentation - [docs.flutter.dev](https://docs.flutter.dev)
- Dart Language Documentation - [dart.dev](https://dart.dev)
- Firebase Documentation - [firebase.google.com/docs](https://firebase.google.com/docs)
- Stream Chat Documentation - [getstream.io/chat/docs](https://getstream.io/chat/docs)

**Learning Resources:**
- W3Schools for basic programming concepts - [w3schools.com](https://w3schools.com)
- MDN Web Docs for web technologies - [developer.mozilla.org](https://developer.mozilla.org)
- Dart Packages Repository - [pub.dev](https://pub.dev)

### b) Video Tutorials

**YouTube Channels & Videos:**
1. Flutter Official Channel - Flutter basics and best practices
2. Fireship - Quick tutorials on Flutter and Firebase
3. Reso Coder - Clean architecture and BLoC pattern
4. The Net Ninja - Flutter state management
5. Code With Andrea - Flutter testing and deployment

**Specific Tutorial Topics:**
- Phone Authentication with Firebase
- Implementing BLoC pattern in Flutter
- Real-time messaging with Stream Chat
- End-to-end encryption concepts
- Flutter navigation patterns

### c) Community Resources

**StackOverflow:**
- Questions about Flutter BLoC state management
- Firebase phone authentication issues
- Stream Chat SDK integration problems
- Flutter secure storage implementation
- Encryption key management in Flutter

**GitHub Repositories:**
- Flutter samples and examples
- Open-source Flutter projects for reference
- Stream Chat Flutter SDK repository
- Firebase Flutter plugins repository
- Cryptography package examples

**Discussion Forums:**
- Reddit r/FlutterDev community
- Flutter Discord server
- StackOverflow Flutter tag
- GitHub Issues for troubleshooting

---

## 🏗️ System Architecture

### Architecture Pattern
The project follows the **MVVM (Model-View-ViewModel)** architecture pattern with **Clean Architecture** principles:

```
┌─────────────────────────────────────────────┐
│         Presentation Layer (Views)          │
│     - UI Components & Screens               │
└─────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────┐
│      Business Logic Layer (BLoC/Cubit)      │
│     - State Management                      │
│     - Business Rules                        │
└─────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────┐
│         Data Layer (Repositories)           │
│     - Data Sources                          │
│     - API Calls                             │
└─────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────┐
│     External Services & Local Storage       │
│  - Firebase, Firestore, Stream Chat         │
│  - Secure Storage, Hydrated Storage         │
└─────────────────────────────────────────────┘
```

### Database Schema
- **Users Collection**: User profiles and authentication data
- **Channels Collection**: Chat rooms and group information
- **Messages Collection**: Message content and metadata
- **Preferences Collection**: User settings and privacy preferences
- **Device Keys Collection**: Encryption key management

### Security Implementation
1. **Two-Layer Encryption System**:
   - Layer 1: Device-local AES-GCM encryption (always active)
   - Layer 2: Channel-based X25519 encryption (for secure channels)

2. **Key Management**:
   - X25519 public/private key pairs for each device
   - AES-256 symmetric keys for message encryption
   - Secure storage using Flutter Secure Storage

---

## 🧪 Testing Approach

### Manual Testing
- Feature testing on Android and iOS devices
- User flow testing (authentication, messaging, calls)
- UI/UX testing for different screen sizes
- Network connectivity testing (offline/online scenarios)

### Test Cases Covered
1. **Authentication**: Phone number validation, OTP verification, session persistence
2. **Messaging**: Send/receive messages, encryption/decryption, media sharing
3. **Chat Management**: Pin, archive, hide, block, delete operations
4. **Privacy**: Online status toggle, read receipts, profile visibility
5. **Calls**: Voice and video call initiation and reception

---

## 📊 Project Statistics

- **Total Development Time**: 12 weeks
- **Lines of Code**: ~8,000+ (Dart)
- **Number of Screens**: 15+ screens
- **Number of Features**: 30+ features
- **Dependencies Used**: 40+ packages
- **Supported Platforms**: Android & iOS

---

## 🚀 Future Enhancements

Following enhancements can be added to the current system which will improve the functionality and user experience:

### 1. Advanced Messaging Features
- **Group Chat Support**: Create and manage group conversations
- **Message Reactions**: Add emoji reactions to messages
- **Reply & Forward**: Reply to specific messages and forward functionality
- **Voice Messages**: Record and send voice notes
- **Message Editing**: Edit sent messages within a time limit
- **Message Search**: Advanced search within conversations

### 2. Enhanced Security Features
- **Biometric Authentication**: Fingerprint and Face ID for app access
- **Self-Destructing Messages**: Auto-delete messages after set time
- **Screenshot Detection**: Notify when screenshots are taken
- **Two-Factor Authentication**: Additional security layer for login
- **Backup Encryption**: Encrypted cloud backup of messages

### 3. Improved User Experience
- **Multi-Device Support**: Sync across multiple devices
- **Desktop Application**: Web and desktop versions
- **Custom Themes**: User-created and community themes
- **Message Scheduling**: Schedule messages for later delivery
- **Smart Replies**: AI-powered quick reply suggestions
- **Read Later**: Bookmark messages for future reference

### 4. Social Features
- **Status Updates**: WhatsApp-style status/stories feature
- **User Profiles**: Enhanced profiles with bio and status
- **Contact Sync**: Automatically find friends from contacts
- **User Discovery**: Discover and connect with new users
- **QR Code Sharing**: Share profile via QR code

### 5. Media & File Management
- **Gallery View**: Browse all shared media in conversations
- **File Management**: Organized view of shared documents
- **Auto-Download Settings**: Control media auto-download
- **Cloud Storage Integration**: Google Drive, Dropbox integration
- **Compression Settings**: Image and video quality controls

### 6. Calling Enhancements
- **Group Voice Calls**: Conference calls with multiple participants
- **Group Video Calls**: Video conferencing up to 8 participants
- **Screen Sharing**: Share screen during video calls
- **Call Recording**: Record voice and video calls
- **Call History**: Detailed call logs with duration

### 7. Notifications & Alerts
- **Custom Notification Sounds**: Per-contact notification tones
- **Notification Categories**: Separate notification channels
- **Smart Notifications**: AI-based notification prioritization
- **Do Not Disturb**: Schedule quiet hours
- **In-App Notifications**: Non-intrusive in-app alerts

### 8. Performance Improvements
- **Message Pagination**: Load messages on demand
- **Image Caching**: Efficient image loading and caching
- **Battery Optimization**: Reduce background battery usage
- **Data Usage Monitoring**: Track and limit data consumption
- **Offline Mode**: Enhanced offline functionality

### 9. Analytics & Reporting
- **Usage Statistics**: Personal usage reports
- **Storage Analysis**: View storage usage by chat
- **Activity Tracking**: Track message frequency and patterns
- **Export Data**: Export chat history and media

### 10. Administrative Features
- **Report System**: Report inappropriate content or users
- **Content Moderation**: Automated content filtering
- **User Blocking**: Enhanced blocking with reasons
- **Account Recovery**: Better account recovery options
- **Data Privacy Controls**: GDPR compliance features

---

## 🎓 Learning Outcomes

Through this project, I gained comprehensive understanding of:

1. **Mobile Development**: Flutter framework and Dart programming language
2. **State Management**: BLoC pattern and reactive programming concepts
3. **Backend Integration**: Firebase services and real-time databases
4. **Cryptography**: End-to-end encryption implementation
5. **Clean Architecture**: Separation of concerns and maintainable code structure
6. **API Integration**: Working with third-party SDKs (Stream Chat, ZegoCloud)
7. **Security Best Practices**: Secure storage, authentication, and data protection
8. **UI/UX Design**: Material Design principles and responsive layouts
9. **Project Management**: Planning, development, and testing workflows
10. **Problem Solving**: Debugging and troubleshooting complex issues

---

## 🔧 Development Challenges & Solutions

### Challenge 1: Encryption Key Management
**Problem**: Managing multiple encryption keys across devices and channels  
**Solution**: Implemented a two-layer encryption system with device-local and channel-based keys, using Flutter Secure Storage for secure persistence

### Challenge 2: Real-time Synchronization
**Problem**: Keeping messages synchronized across offline/online states  
**Solution**: Used Stream Chat SDK with built-in offline support and Hydrated BLoC for state persistence

### Challenge 3: State Management Complexity
**Problem**: Managing complex application state across multiple features  
**Solution**: Adopted BLoC pattern with clear separation of concerns and dependency injection using get_it

### Challenge 4: Performance Optimization
**Problem**: App performance degradation with large message history  
**Solution**: Implemented pagination, lazy loading, and efficient caching strategies

---

## 📝 Conclusion

This project successfully demonstrates the implementation of a modern, secure messaging application using Flutter. The key achievements include:

✅ Fully functional authentication system with phone verification  
✅ Real-time messaging with end-to-end encryption  
✅ Comprehensive chat management features  
✅ Voice and video calling integration  
✅ Privacy-focused features with user controls  
✅ Clean, maintainable architecture following best practices  
✅ Professional documentation and code organization  

The project provided valuable hands-on experience with:
- Cross-platform mobile development
- Real-time communication technologies
- Cryptography and security implementations
- Modern state management patterns
- Cloud-based backend services
- Professional development workflows

This application serves as a solid foundation for understanding secure messaging technologies and can be extended with the proposed future enhancements to create a production-ready messaging platform.

---

## 📚 References

1. Flutter Documentation. (2025). *Flutter - Beautiful native apps in record time*. Retrieved from https://flutter.dev
2. Firebase Documentation. (2025). *Firebase Phone Authentication*. Retrieved from https://firebase.google.com/docs/auth/flutter/phone-auth
3. Stream. (2025). *Stream Chat Flutter SDK Documentation*. Retrieved from https://getstream.io/chat/docs/sdk/flutter/
4. Dart Language. (2025). *Dart Programming Language*. Retrieved from https://dart.dev
5. ZegoCloud Documentation. (2025). *Video Call SDK*. Retrieved from https://www.zegocloud.com
6. W3Schools. (2025). *Web Development Tutorials*. Retrieved from https://www.w3schools.com
7. StackOverflow. (2025). *Flutter Development Questions*. Retrieved from https://stackoverflow.com/questions/tagged/flutter
8. GitHub. (2025). *Open Source Flutter Projects*. Retrieved from https://github.com/topics/flutter

---

## 📧 Contact Information

For questions or feedback regarding this project:

- **Email**: [your.email@example.com]
- **GitHub**: [your-github-username]
- **Project Repository**: [repository-link]

---

**Project Completion Date**: December 28, 2025  
**Course**: CSE489 - Mobile Application Development  
**Institution**: [Your University Name]  
**Instructor**: [Professor Name]

---

*This report was prepared as part of the CSE489 Final Project submission.*
