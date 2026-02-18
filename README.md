# ExamEarn - Quiz & Earn Platform

Complete Educational Quiz & Earn platform with Website, Android App, and Admin Panel.

## 🚀 Features

### Admin Panel (Web)
- Quiz management interface
- Direct APK download functionality
- Admin-managed content (APK URL, hero text)

### Android App (Flutter)
- **50-Chapter System**: Level-wise locked chapters
- **Chapter 1**: 10 Questions, 20s timer, ₹20 Cash reward
- **Chapter 11-50**: 20 Questions, 10s timer, 15 Gold Coins reward
- **Cheat-Proof Logic**: Auto-fail on app switch/minimize
- **Categories**: 5-12th Class, SSC, RRB, Bank, IAS/PCS, Science, Math, History
- **Animations**: Spinning Wheel, Flying Coins
- **In-App Updates**: Check for updates within app

### Monetization
- **AdMob Integration**:
  - Rewarded Video Ads: Required for retry after failure
  - Interstitial Ads: Every 2 chapters
- **Withdrawal System**: 
  - Requires Chapter 50 completion
  - Requires 500 Gold Coins
  - Secure bank account details encryption

### Admin Panel
- Manage Categories & Chapters
- Upload Questions via Excel
- Manage Users
- Approve/Reject Withdrawals
- Update Website Settings (APK URL, Hero Text)

## 📁 Project Structure

```
ExamEarn/
├── app/                  # Flutter Android App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── providers/    # State management
│   │   ├── screens/      # UI screens
│   │   ├── models/       # Data models
│   │   └── utils/        # Utilities & config
│   └── pubspec.yaml
├── admin/                # Admin Panel
│   ├── index.html
│   ├── admin.css
│   └── admin.js
├── api/                  # API Configuration
│   └── config.js
├── public/               # Public assets
│   ├── config.js
│   └── downloads/       # APK downloads folder
├── package.json          # Node.js dependencies
├── vercel.json          # Vercel deployment config
└── README.md
```

## 🛠️ Setup Instructions

### 1. Firebase Setup
1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password, Phone)
3. Create Firestore database
4. Update Firebase config in:
   - `app/lib/utils/app_config.dart`
   - `admin/admin.js`

### 2. AdMob Setup
1. Create AdMob account
2. Create ad units (Rewarded, Interstitial)
3. Update ad unit IDs in `app/lib/utils/app_config.dart`

### 3. Flutter App Setup
```bash
cd app
flutter pub get
flutter run
```

### 4. Website & Admin Panel Deployment (Vercel - Recommended)

#### Quick Deploy (5 minutes):
1. Push code to GitHub
2. Connect to Vercel
3. Add environment variables
4. Deploy!

**Note**: Configure environment variables in Vercel dashboard

#### Environment Variables Needed:
```
APK_DOWNLOAD_URL=https://your-bucket.s3.amazonaws.com/examearn.apk
HERO_TEXT=Quiz Khelo, Knowledge Badhao, Paise Kamao!
FIREBASE_API_KEY=your_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
```

#### APK Storage Options:
- **AWS S3** (Recommended for large files)
- **Google Drive** (Free option)
- **Firebase Storage**
- **Vercel Public Folder** (For files < 100MB)

### 5. Alternative: Manual Website Setup
1. Update APK download URL in admin panel
2. Deploy `index.html` to your web server
3. Update Firebase config if needed

## 📱 App Configuration

### Quiz Rules
- **Chapter 1**: 10 questions, 20s per question, ₹20 cash reward
- **Chapter 11-50**: 20 questions, 10s per question, 15 gold coins
- **Passing Score**: 60% minimum
- **Cheat Detection**: App switch/minimize = Auto fail

### Withdrawal Rules
- Complete Chapter 50
- Have 500 Gold Coins
- Submit bank details (encrypted)

## 🔐 Security Features
- Wallet balance encryption
- Bank details encryption
- Cheat-proof quiz system
- Fake user detection

## 📝 Admin Features
- Add/Edit/Delete Categories
- Add/Edit/Delete Questions
- Upload questions via Excel
- View all users
- Approve/Reject withdrawals
- Update website settings

## 🎨 Theme
- **Colors**: Dark theme (#0B0E13) with lime green accent (#CBFE1C)
- **Fonts**: 
  - Headings: Days One
  - Body: Chakra Petch
- **Style**: Gaming/Esports theme

## 📄 License
This project is proprietary. All rights reserved.

## 👨‍💻 Developer Notes
- Replace Firebase config with your credentials
- Replace AdMob IDs with your ad units
- Update encryption keys in production
- Configure proper security rules in Firestore
- Set up proper hosting for APK downloads

---

**Built with ❤️ for ExamEarn Platform**

