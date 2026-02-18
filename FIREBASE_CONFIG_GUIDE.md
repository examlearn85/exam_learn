# Firebase Configuration Guide - ExamEarn

## Complete Firebase Config Required

Web app और Mobile app दोनों के लिए Firebase configuration की जरूरत है।

### 🔑 Required Firebase Config Values

```javascript
firebaseConfig: {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "your-project-id.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project-id.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890",
  measurementId: "G-XXXXXXXXXX" // Optional (for Analytics)
}
```

### 📋 Detailed Explanation

#### 1. **apiKey** (Required)
- **What it is:** Firebase API Key
- **Where to find:** Firebase Console → Project Settings → General → Your apps
- **Format:** `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
- **Security:** Public key, safe to expose in client-side code

#### 2. **authDomain** (Required)
- **What it is:** Authentication domain
- **Format:** `your-project-id.firebaseapp.com`
- **Example:** `examearn-12345.firebaseapp.com`
- **Auto-generated** from project ID

#### 3. **projectId** (Required)
- **What it is:** Your Firebase project ID
- **Where to find:** Firebase Console → Project Settings → General
- **Format:** Alphanumeric, lowercase, no spaces
- **Example:** `examearn-12345`

#### 4. **storageBucket** (Required for file uploads)
- **What it is:** Firebase Storage bucket
- **Format:** `your-project-id.appspot.com`
- **Example:** `examearn-12345.appspot.com`
- **Used for:** APK storage, images, etc.

#### 5. **messagingSenderId** (Required for Push Notifications)
- **What it is:** Cloud Messaging Sender ID
- **Where to find:** Firebase Console → Project Settings → Cloud Messaging
- **Format:** Numeric (12 digits)
- **Example:** `123456789012`

#### 6. **appId** (Required)
- **What it is:** Firebase App ID
- **Where to find:** Firebase Console → Project Settings → Your apps
- **Format:** `1:123456789012:web:abcdef1234567890`
- **Unique** for each app platform

#### 7. **measurementId** (Optional - for Analytics)
- **What it is:** Google Analytics Measurement ID
- **Where to find:** Firebase Console → Analytics → Settings
- **Format:** `G-XXXXXXXXXX`
- **Optional** but recommended for tracking

---

## 🔧 How to Get Firebase Config

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `ExamEarn`
4. Enable Google Analytics (optional)
5. Create project

### Step 2: Add Web App
1. In Firebase Console, click Web icon (</>)
2. Register app name: `ExamEarn Web`
3. Copy the config object

### Step 3: Add Android App (for Mobile)
1. Click Android icon
2. Enter package name: `com.examearn.app`
3. Download `google-services.json`
4. Place in `app/android/app/`

---

## 📝 Vercel Environment Variables

Vercel deployment के लिए ये environment variables add करें:

```bash
# Firebase Config
FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_APP_ID=1:123456789012:web:abcdef1234567890

# OAuth (Google Sign-In)
OAUTH_CLIENT_ID=531991202663-92qvrma2jg8juh792n80a84ivupi5oia.apps.googleusercontent.com

# Other Config
APK_DOWNLOAD_URL=https://your-bucket.s3.amazonaws.com/examearn.apk
HERO_TEXT=Quiz Khelo, Knowledge Badhao, Paise Kamao!
```

---

## 🔐 Firebase Services to Enable

### 1. **Authentication**
- Go to: Authentication → Sign-in method
- Enable:
  - ✅ Email/Password
  - ✅ Phone (for mobile app)
  - ✅ Google (optional)

### 2. **Cloud Firestore**
- Go to: Firestore Database
- Create database
- Choose mode: **Production** (for security rules)
- Location: Choose nearest region (e.g., `asia-south1` for India)

### 3. **Storage** (Optional)
- Go to: Storage
- Get started
- Rules: Set security rules

### 4. **Cloud Messaging** (for Push Notifications)
- Go to: Cloud Messaging
- Get Server Key (for backend)
- Get Sender ID (for config)

---

## 📊 Firestore Database Structure

### Collections Needed:

```
users/
  {userId}/
    - uid: string
    - email: string
    - name: string
    - phone: string
    - currentChapter: number
    - completedChapters: array
    - goldCoins: number
    - cashBalance: number
    - totalEarnings: number
    - createdAt: timestamp
    - lastLogin: timestamp

categories/
  {categoryId}/
    - name: string
    - description: string
    - order: number
    - chapters/
      {chapterId}/
        - chapterNumber: number
        - title: string
        - questions/
          {questionId}/
            - question: string
            - options: array
            - correctAnswer: number

withdrawals/
  {withdrawalId}/
    - userId: string
    - amount: number
    - status: string
    - bankDetails: object (encrypted)
    - createdAt: timestamp
```

---

## 🛡️ Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Categories and questions are readable by authenticated users
    match /categories/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Only admin can write via Admin SDK
    }
    
    // Withdrawals
    match /withdrawals/{withdrawalId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 📱 Mobile App Config (Flutter)

Flutter app में Firebase config `google-services.json` file में होता है:

**Location:** `app/android/app/google-services.json`

**For iOS:** `app/ios/Runner/GoogleService-Info.plist`

---

## ✅ Configuration Checklist

- [ ] Firebase project created
- [ ] Web app added in Firebase Console
- [ ] Android app added (for mobile)
- [ ] Firebase config copied
- [ ] Environment variables set in Vercel
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created
- [ ] Security rules configured
- [ ] Storage enabled (if needed)
- [ ] Cloud Messaging enabled (for push notifications)

---

## 🔍 Where to Find Each Value

### Firebase Console Navigation:

1. **Project Settings** → General tab
   - Project ID
   - Web API Key
   - App ID

2. **Project Settings** → General tab → Your apps
   - Click on Web app → Config object
   - All values in one place

3. **Authentication** → Sign-in method
   - Enable providers here

4. **Firestore Database**
   - Create database
   - Set security rules

5. **Storage**
   - Get started
   - Storage bucket URL

6. **Cloud Messaging**
   - Sender ID
   - Server Key (for backend)

---

## 🚨 Important Notes

1. **Never commit** Firebase config with sensitive data to public repos
2. **Use environment variables** for production
3. **Rotate API keys** if compromised
4. **Set proper security rules** in Firestore
5. **Enable only needed services** to reduce costs
6. **Monitor usage** in Firebase Console

---

## 📞 Support

अगर कोई issue हो:
1. Firebase Console में check करें
2. Browser console में errors देखें
3. Network tab में API calls check करें
4. Firebase documentation देखें

---

**Last Updated:** $(date)
**Project:** ExamEarn

