# Firebase Project Information - ExamEarn

## Project Details

**Project Name:** ExamEarns  
**Project ID:** examearns  
**Project Number:** 531991202663  
**Public-facing Name:** Exam Earn  
**Support Email:** examlearn85@gmail.com  

## Firebase Config Values

Based on your project details, here are the config values you'll need:

### Web App Config
```javascript
firebaseConfig: {
  apiKey: "AIzaSyAl21BbE84_9pntd_O-y3Nn5YflNUFMI1",
  authDomain: "examearns.firebaseapp.com",
  projectId: "examearns",
  storageBucket: "examearns.appspot.com",
  messagingSenderId: "531991202663",
  appId: "1:531991202663:web:be7e857c71f4316d8d3dc2",
  measurementId: "G-XXXXXXXXXX" // Optional
}
```

### OAuth Client ID
```
531991202663-92qvrma2jg8juh792n80a84ivupi5oia.apps.googleusercontent.com
```

## Vercel Environment Variables

Add these in Vercel Dashboard → Settings → Environment Variables:

```bash
# Firebase Config
FIREBASE_API_KEY=AIzaSyAl21BbE84_9pntd_O-y3Nn5YflNUFMI1
FIREBASE_AUTH_DOMAIN=examearns.firebaseapp.com
FIREBASE_PROJECT_ID=examearns
FIREBASE_STORAGE_BUCKET=examearns.appspot.com
FIREBASE_MESSAGING_SENDER_ID=531991202663
FIREBASE_APP_ID=1:531991202663:web:be7e857c71f4316d8d3dc2

# OAuth
OAUTH_CLIENT_ID=531991202663-92qvrma2jg8juh792n80a84ivupi5oia.apps.googleusercontent.com

# Other
APK_DOWNLOAD_URL=https://your-bucket.s3.amazonaws.com/examearn.apk
HERO_TEXT=Quiz Khelo, Knowledge Badhao, Paise Kamao!
```

## How to Get Missing Values

### 1. API Key & App ID
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **ExamEarns**
3. Click ⚙️ Settings → Project settings
4. Scroll to "Your apps" section
5. Click on Web app (or add new if not exists)
6. Copy `apiKey` and `appId` from config object

### 2. Storage Bucket
- Default: `examearns.appspot.com`
- Or check: Storage → Settings

### 3. Measurement ID (Optional)
- Go to: Analytics → Settings
- Copy Measurement ID (starts with `G-`)

## Next Steps

1. ✅ Project created: **examearns**
2. ⏳ Add Web app in Firebase Console
3. ⏳ Add Android app (for mobile)
4. ⏳ Enable Authentication (Email/Password)
5. ⏳ Create Firestore database
6. ⏳ Set security rules
7. ⏳ Add environment variables in Vercel

---

**Last Updated:** $(date)

