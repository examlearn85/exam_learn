# Web Quiz Feature - Complete Guide

## Overview
ExamEarn website अब एक full web app है जहाँ users laptop/desktop से भी quiz खेल सकते हैं। Mobile app और web app दोनों same Firebase database use करते हैं, इसलिए progress sync रहता है।

## Features Implemented

### 1. **Login/Signup System**
- Email/Password authentication
- Firebase Authentication integration
- User data stored in Firestore
- Cross-platform sync (Mobile + Web)

### 2. **User Dashboard**
- Real-time stats display:
  - Cash Balance (₹)
  - Gold Coins
  - Current Chapter
  - Completed Chapters count
- Category selection
- Chapter list with lock/unlock status
- Start quiz button

### 3. **Web Quiz Interface**
- **Full Screen Mode**: Compulsory fullscreen to prevent cheating
- **Timer System**:
  - Chapter 1: 20 seconds per question
  - Chapter 11-50: 10 seconds per question
- **Question Count**:
  - Chapter 1: 10 questions
  - Chapter 11-50: 20 questions
- **Cheat Detection**:
  - Auto-fail on window switch/tab change
  - Auto-fail on fullscreen exit
  - Visibility API detection
- **Progress Bar**: Visual progress indicator
- **Result Modal**: Shows score and rewards

### 4. **Reward System**
- Chapter 1: ₹20 Cash (on passing)
- Chapter 11-50: 15 Gold Coins (on passing)
- Minimum 60% required to pass
- Rewards automatically added to wallet

## File Structure

```
ExamEarn/
├── index.html          # Updated with Login button
├── login.html          # Login/Signup page
├── dashboard.html      # User dashboard
├── quiz.html           # Quiz interface (fullscreen)
├── js/
│   ├── auth.js         # Firebase authentication
│   ├── dashboard.js    # Dashboard functionality
│   └── quiz.js         # Quiz logic with cheat detection
└── public/
    └── config.js       # Configuration loader
```

## Setup Instructions

### 1. Firebase Configuration
Ensure Firebase is configured in `public/config.js` or via environment variables:
- `FIREBASE_API_KEY`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_PROJECT_ID`

### 2. Firestore Database Structure

#### Users Collection
```javascript
users/{userId} {
  uid: string,
  email: string,
  name: string,
  phone: string,
  currentChapter: number,
  completedChapters: array,
  goldCoins: number,
  cashBalance: number,
  totalEarnings: number,
  platform: 'web' | 'mobile',
  createdAt: timestamp,
  lastLogin: timestamp
}
```

#### Categories Collection
```javascript
categories/{categoryId} {
  name: string,
  description: string,
  order: number
}
```

#### Chapters Collection
```javascript
categories/{categoryId}/chapters/{chapterId} {
  chapterNumber: number,
  title: string
}
```

#### Questions Collection
```javascript
categories/{categoryId}/chapters/{chapterId}/questions/{questionId} {
  question: string,
  options: array,
  correctAnswer: number (0-3)
}
```

### 3. Enable Firebase Authentication
1. Go to Firebase Console
2. Enable Email/Password authentication
3. Add authorized domains (your website domain)

### 4. Firestore Security Rules
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
      allow write: if false; // Only admin can write
    }
  }
}
```

## Usage Flow

1. **User visits website** → Sees Login button in header
2. **Clicks Login** → Redirected to `login.html`
3. **Signs up/Logs in** → Firebase authentication
4. **Redirected to Dashboard** → Sees stats and categories
5. **Selects Category** → Chapters list appears
6. **Clicks Start Quiz** → Redirected to `quiz.html`
7. **Fullscreen Mode** → Automatically enters fullscreen
8. **Takes Quiz** → Timer, questions, options
9. **Completes Quiz** → Result modal with score and reward
10. **Returns to Dashboard** → Updated stats

## Cheat Prevention Features

### 1. Fullscreen Mode
- Automatically enters fullscreen when quiz starts
- Quiz fails if user exits fullscreen
- Warning message if fullscreen not available

### 2. Window Blur Detection
- Detects tab switch or window minimize
- Auto-fails quiz on blur
- Uses `visibilitychange` API

### 3. Timer Enforcement
- Strict timer per question
- Auto-submits wrong answer if time runs out
- Visual warnings (red color) when time is low

## Ad Integration (Web)

For web version, use **Google AdSense** instead of AdMob:

```html
<!-- Add to quiz.html or dashboard.html -->
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXX"
     crossorigin="anonymous"></script>
```

## Testing Checklist

- [ ] Login/Signup works
- [ ] Dashboard loads user data
- [ ] Categories and chapters load correctly
- [ ] Quiz enters fullscreen mode
- [ ] Timer works correctly
- [ ] Cheat detection triggers on tab switch
- [ ] Rewards are added correctly
- [ ] Progress syncs with mobile app
- [ ] Result modal displays correctly

## Browser Compatibility

- Chrome/Edge: Full support
- Firefox: Full support
- Safari: Full support (may need user gesture for fullscreen)
- Mobile browsers: Responsive design works

## Future Enhancements

1. **Leaderboard**: Show top users
2. **Achievements**: Badge system
3. **Social Sharing**: Share quiz results
4. **Dark/Light Theme**: User preference
5. **Offline Mode**: Service worker for offline quiz
6. **Push Notifications**: Remind users to play

## Troubleshooting

### Fullscreen not working
- Check browser permissions
- Some browsers require user gesture
- Safari may need explicit permission

### Firebase errors
- Check API keys in config
- Verify Firestore rules
- Check network connectivity

### Quiz not loading
- Check Firestore structure
- Verify category/chapter IDs
- Check browser console for errors

## Security Notes

1. **Never expose Firebase Admin SDK** in client code
2. **Use Firestore Security Rules** to protect data
3. **Validate user input** on server side
4. **Encrypt sensitive data** (wallet, bank details)
5. **Rate limiting** for API calls
6. **Monitor for abuse** (multiple accounts, etc.)

---

**Built with ❤️ for ExamEarn Platform**

