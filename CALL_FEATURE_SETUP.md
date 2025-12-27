# Video/Voice Call Feature Setup

## ✅ What's Been Added

I've integrated **Zegocloud** video and voice calling - the easiest solution available!

### Files Created:
1. **lib/presentation/views/call/video_call_view.dart** - Video call screen
2. **lib/presentation/views/call/voice_call_view.dart** - Voice call screen

### Files Modified:
1. **pubspec.yaml** - Added Zegocloud packages
2. **lib/presentation/views/chat/chat_view.dart** - Added call buttons to chat header
3. **lib/core/config/env_config.dart** - Added Zegocloud config
4. **.env** - Added placeholder for Zegocloud credentials
5. **AndroidManifest.xml** - Added camera/microphone permissions

## 🔑 Get Your FREE Zegocloud Credentials

### Step 1: Sign Up
Go to: **https://console.zegocloud.com/**
- Sign up for a free account
- No credit card required
- Free tier includes 10,000 minutes/month

### Step 2: Create a Project
1. Click "Create Project"
2. Choose "UIKit" as product
3. Select "Live Video Call" scenario

### Step 3: Get Credentials
You'll get:
- **App ID** (a number like: 1234567890)
- **App Sign** (a long string like: abc123def456...)

### Step 4: Update .env File
Open your `.env` file and replace:
```
ZEGO_APP_ID=YOUR_APP_ID_HERE
ZEGO_APP_SIGN=YOUR_APP_SIGN_HERE
```

With your actual credentials:
```
ZEGO_APP_ID=1234567890
ZEGO_APP_SIGN=abc123def456...
```

## 📦 Install Dependencies

Run this command:
```bash
cd "/Users/professor/Documents/CSE489/CSE489 Final/flutter_social_chat" && flutter pub get
```

## ✨ How It Works

Once you add credentials and run `flutter pub get`:

1. **In one-on-one chats**, you'll see two new buttons in the app bar:
   - 📹 Video call button
   - 📞 Voice call button

2. **When you tap a button**, it will:
   - Request camera/microphone permissions
   - Open the call screen
   - Generate a unique call ID for the conversation
   - Connect when the other person joins

3. **The other person** needs to:
   - Join the same call using the same call ID
   - Or you can implement call notifications (more advanced)

## 🎨 Features Included

- ✅ One-on-one video calls
- ✅ One-on-one voice calls
- ✅ Pre-built UI (professional looking)
- ✅ Mute/unmute audio
- ✅ Enable/disable video
- ✅ Switch camera
- ✅ Hang up
- ✅ Auto-end when alone in room

## 🚀 Next Steps

After getting credentials:
1. Add them to `.env` file
2. Run `flutter pub get`
3. Run the app
4. Try calling yourself from another device!

## 📝 Notes

- For production, you'll want to add:
  - Call notifications (Firebase Cloud Messaging)
  - Call history
  - Missed call badges
  - User busy status
  
- Current implementation uses channel ID as call ID
- Both users must join the same call ID to connect

Need help setting up? Let me know! 🎉
