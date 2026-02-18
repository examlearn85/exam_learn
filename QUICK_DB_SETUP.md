# Quick Database Setup - User Login Data Storage

## ✅ Step 1: Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **ExamEarns**
3. Click **Authentication** in left menu
4. Click **Get started**
5. Go to **Sign-in method** tab
6. Click on **Email/Password**
7. **Enable** Email/Password
8. Click **Save**

---

## ✅ Step 2: Create Firestore Database

1. Click **Firestore Database** in left menu
2. Click **Create database**
3. Choose **Production mode**
4. Select location: **asia-south1** (Mumbai)
5. Click **Enable**

---

## ✅ Step 3: Set Security Rules

1. In Firestore Database, go to **Rules** tab
2. Copy the rules from `firestore.rules` file
3. Paste in the rules editor
4. Click **Publish**

**Rules allow:**
- ✅ Users to create their own document on signup
- ✅ Users to read/write their own data
- ✅ Users to update lastLogin on login

---

## ✅ Step 4: Test Login/Signup

### Sign Up Test:
1. Go to: `exam-learn85.vercel.app/login.html`
2. Click "Sign Up"
3. Enter:
   - Name: Test User
   - Email: test@example.com
   - Password: test123456
4. Click "Sign Up"

### Expected Result:
- ✅ User document created in Firestore
- ✅ Redirected to dashboard
- ✅ User data visible in Firebase Console

### Check in Firebase Console:
1. Go to **Firestore Database** → **Data** tab
2. You should see `users` collection
3. Click on the user document
4. Verify these fields:
   ```json
   {
     "uid": "user-id-here",
     "email": "test@example.com",
     "name": "Test User",
     "currentChapter": 1,
     "completedChapters": [],
     "goldCoins": 0,
     "cashBalance": 0,
     "totalEarnings": 0,
     "isVerified": false,
     "platform": "web",
     "createdAt": "timestamp",
     "lastLogin": "timestamp"
   }
   ```

### Login Test:
1. Logout (if logged in)
2. Go to login page
3. Enter same email/password
4. Click "Login"

### Expected Result:
- ✅ `lastLogin` field updated
- ✅ Redirected to dashboard
- ✅ User data loaded correctly

---

## 🔍 Troubleshooting

### Issue: "Permission denied" error
**Solution:**
- Check security rules are published
- Verify user is authenticated
- Check rules allow create for users collection

### Issue: User document not created
**Solution:**
- Check browser console for errors
- Verify Firestore database is created
- Check Firebase config is correct
- Verify Authentication is enabled

### Issue: "Firebase configuration not found"
**Solution:**
- Check `public/config.js` has correct values
- Verify API endpoint `/api/config` returns config
- Check Vercel environment variables

---

## 📋 User Document Structure

When user signs up, this document is automatically created:

```json
{
  "uid": "firebase-user-id",
  "email": "user@example.com",
  "name": "User Name",
  "phone": "",
  "createdAt": "2024-01-01T00:00:00Z",
  "lastLogin": "2024-01-01T00:00:00Z",
  "currentChapter": 1,
  "completedChapters": [],
  "goldCoins": 0,
  "cashBalance": 0,
  "totalEarnings": 0,
  "isVerified": false,
  "platform": "web"
}
```

**Fields updated on login:**
- `lastLogin` - Updated to current timestamp

**Fields updated on quiz completion:**
- `currentChapter` - Updated if user completes new chapter
- `completedChapters` - Array updated with completed chapter numbers
- `goldCoins` - Increased by 15 for chapters 11-50
- `cashBalance` - Increased by ₹20 for chapter 1
- `totalEarnings` - Total earnings updated

---

## ✅ Checklist

- [ ] Firebase Authentication enabled (Email/Password)
- [ ] Firestore Database created
- [ ] Security rules published
- [ ] Test signup - user document created
- [ ] Test login - lastLogin updated
- [ ] User data visible in Firebase Console

---

**Once all steps are done, user data will be stored automatically on login/signup!**

