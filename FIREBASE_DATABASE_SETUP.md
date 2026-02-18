# Firebase Firestore Database Setup Guide

## Step-by-Step Setup Instructions

### Step 1: Create Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **ExamEarns**
3. Click on **Firestore Database** in left menu
4. Click **Create database**
5. Choose **Production mode** (for security rules)
6. Select location: **asia-south1** (Mumbai - closest to India)
7. Click **Enable**

---

## Step 2: Set Security Rules

Go to **Firestore Database** → **Rules** tab

Copy and paste these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users Collection
    match /users/{userId} {
      // Users can read/write their own data
      allow read, write: if isOwner(userId);
      
      // Allow read for admin (you can add admin check later)
      allow read: if isAuthenticated();
    }
    
    // Categories Collection
    match /categories/{categoryId} {
      // Authenticated users can read categories
      allow read: if isAuthenticated();
      
      // Only admin can write (you'll need to add admin check)
      allow write: if false; // Disable for now, enable via Admin SDK
      
      // Chapters subcollection
      match /chapters/{chapterId} {
        allow read: if isAuthenticated();
        allow write: if false; // Admin only
        
        // Questions subcollection
        match /questions/{questionId} {
          allow read: if isAuthenticated();
          allow write: if false; // Admin only
        }
      }
    }
    
    // Withdrawals Collection
    match /withdrawals/{withdrawalId} {
      // Users can read their own withdrawals
      allow read: if isOwner(resource.data.userId);
      
      // Users can create withdrawals
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      
      // Only admin can update (approve/reject)
      allow update: if false; // Admin only via Admin SDK
    }
    
    // App Config Collection (read-only for users)
    match /app_config/{document=**} {
      allow read: if isAuthenticated();
      allow write: if false; // Admin only
    }
  }
}
```

Click **Publish** to save rules.

---

## Step 3: Create Collections Structure

### Collection 1: `users`

**Path:** `users/{userId}`

**Document Structure:**
```json
{
  "uid": "user123",
  "email": "user@example.com",
  "name": "User Name",
  "phone": "+919876543210",
  "currentChapter": 1,
  "completedChapters": [],
  "goldCoins": 0,
  "cashBalance": 0,
  "totalEarnings": 0,
  "isVerified": false,
  "platform": "web",
  "createdAt": "2024-01-01T00:00:00Z",
  "lastLogin": "2024-01-01T00:00:00Z"
}
```

**Note:** This will be created automatically when user signs up.

---

### Collection 2: `categories`

**Path:** `categories/{categoryId}`

**Example Documents:**

#### Category 1: 5th Class
```json
{
  "name": "5th Class",
  "description": "Class 5th Quiz Questions",
  "order": 1,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 2: 6th Class
```json
{
  "name": "6th Class",
  "description": "Class 6th Quiz Questions",
  "order": 2,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 3: 7th Class
```json
{
  "name": "7th Class",
  "description": "Class 7th Quiz Questions",
  "order": 3,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 4: 8th Class
```json
{
  "name": "8th Class",
  "description": "Class 8th Quiz Questions",
  "order": 4,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 5: 9th Class
```json
{
  "name": "9th Class",
  "description": "Class 9th Quiz Questions",
  "order": 5,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 6: 10th Class
```json
{
  "name": "10th Class",
  "description": "Class 10th Quiz Questions",
  "order": 6,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 7: 11th Class
```json
{
  "name": "11th Class",
  "description": "Class 11th Quiz Questions",
  "order": 7,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 8: 12th Class
```json
{
  "name": "12th Class",
  "description": "Class 12th Quiz Questions",
  "order": 8,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 9: SSC
```json
{
  "name": "SSC",
  "description": "Staff Selection Commission",
  "order": 9,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 10: RRB
```json
{
  "name": "RRB",
  "description": "Railway Recruitment Board",
  "order": 10,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 11: Bank
```json
{
  "name": "Bank",
  "description": "Banking Exams",
  "order": 11,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 12: IAS/PCS
```json
{
  "name": "IAS/PCS",
  "description": "Civil Services",
  "order": 12,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 13: Science
```json
{
  "name": "Science",
  "description": "Science Quiz",
  "order": 13,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 14: Math
```json
{
  "name": "Math",
  "description": "Mathematics Quiz",
  "order": 14,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Category 15: History
```json
{
  "name": "History",
  "description": "History Quiz",
  "order": 15,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

---

### Collection 3: Chapters (Subcollection)

**Path:** `categories/{categoryId}/chapters/{chapterId}`

**Example Document (Chapter 1):**
```json
{
  "chapterNumber": 1,
  "title": "Chapter 1 - Introduction",
  "description": "First chapter quiz",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**Example Document (Chapter 2):**
```json
{
  "chapterNumber": 2,
  "title": "Chapter 2 - Basics",
  "description": "Second chapter quiz",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**Repeat for all 50 chapters** (Chapter 1 to Chapter 50)

---

### Collection 4: Questions (Subcollection)

**Path:** `categories/{categoryId}/chapters/{chapterId}/questions/{questionId}`

**Example Question Document:**
```json
{
  "question": "What is the capital of India?",
  "options": [
    "Mumbai",
    "Delhi",
    "Kolkata",
    "Chennai"
  ],
  "correctAnswer": 1,
  "explanation": "Delhi is the capital of India",
  "difficulty": "easy",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**Important Notes:**
- `correctAnswer` is the **index** (0-3) of the correct option
- For Chapter 1: Add **10 questions**
- For Chapter 11-50: Add **20 questions** each

---

### Collection 5: `withdrawals`

**Path:** `withdrawals/{withdrawalId}`

**Document Structure:**
```json
{
  "userId": "user123",
  "amount": 500,
  "status": "pending",
  "bankDetails": {
    "accountNumber": "encrypted_data",
    "ifscCode": "encrypted_data",
    "accountHolderName": "encrypted_data"
  },
  "createdAt": "2024-01-01T00:00:00Z",
  "processedAt": null,
  "adminNotes": ""
}
```

**Status values:**
- `pending` - Waiting for approval
- `approved` - Approved, payment processing
- `rejected` - Rejected by admin
- `completed` - Payment sent

---

### Collection 6: `app_config` (Optional)

**Path:** `app_config/settings`

**Document Structure:**
```json
{
  "apkDownloadUrl": "https://your-bucket.s3.amazonaws.com/examearn.apk",
  "heroText": "Quiz Khelo, Knowledge Badhao, Paise Kamao!",
  "appVersion": "1.0.0",
  "minAppVersion": "1.0.0",
  "updateRequired": false,
  "maintenanceMode": false,
  "maintenanceMessage": ""
}
```

---

## Step 4: How to Add Data in Firebase Console

### Method 1: Manual Entry (For Testing)

1. Go to **Firestore Database** → **Data** tab
2. Click **Start collection**
3. Enter collection ID: `categories`
4. Click **Next**
5. Add document ID (auto-generate or custom)
6. Add fields one by one
7. Click **Save**

### Method 2: Import JSON (Recommended)

1. Use Firebase Admin SDK or Firebase CLI
2. Or use a script to import data
3. See `import-data.js` script below

---

## Step 5: Quick Setup Script

Create a Node.js script to import initial data:

**File:** `scripts/import-firebase-data.js`

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Categories data
const categories = [
  { name: "5th Class", description: "Class 5th Quiz Questions", order: 1 },
  { name: "6th Class", description: "Class 6th Quiz Questions", order: 2 },
  { name: "7th Class", description: "Class 7th Quiz Questions", order: 3 },
  { name: "8th Class", description: "Class 8th Quiz Questions", order: 4 },
  { name: "9th Class", description: "Class 9th Quiz Questions", order: 5 },
  { name: "10th Class", description: "Class 10th Quiz Questions", order: 6 },
  { name: "11th Class", description: "Class 11th Quiz Questions", order: 7 },
  { name: "12th Class", description: "Class 12th Quiz Questions", order: 8 },
  { name: "SSC", description: "Staff Selection Commission", order: 9 },
  { name: "RRB", description: "Railway Recruitment Board", order: 10 },
  { name: "Bank", description: "Banking Exams", order: 11 },
  { name: "IAS/PCS", description: "Civil Services", order: 12 },
  { name: "Science", description: "Science Quiz", order: 13 },
  { name: "Math", description: "Mathematics Quiz", order: 14 },
  { name: "History", description: "History Quiz", order: 15 }
];

async function setupDatabase() {
  try {
    // Add categories
    for (const category of categories) {
      const docRef = await db.collection('categories').add({
        ...category,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log(`Added category: ${category.name} (ID: ${docRef.id})`);
      
      // Add 50 chapters for each category
      for (let i = 1; i <= 50; i++) {
        const chapterRef = await db.collection('categories')
          .doc(docRef.id)
          .collection('chapters')
          .add({
            chapterNumber: i,
            title: `Chapter ${i}`,
            description: `${category.name} - Chapter ${i} Quiz`,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
          });
        
        console.log(`  Added Chapter ${i} (ID: ${chapterRef.id})`);
        
        // Add questions (10 for Ch1, 20 for Ch11-50)
        const questionCount = i === 1 ? 10 : 20;
        for (let j = 1; j <= questionCount; j++) {
          await db.collection('categories')
            .doc(docRef.id)
            .collection('chapters')
            .doc(chapterRef.id)
            .collection('questions')
            .add({
              question: `Sample Question ${j} for Chapter ${i}?`,
              options: [
                "Option A",
                "Option B",
                "Option C",
                "Option D"
              ],
              correctAnswer: 0, // Index 0-3
              explanation: "This is a sample question",
              difficulty: "medium",
              createdAt: admin.firestore.FieldValue.serverTimestamp()
            });
        }
        console.log(`    Added ${questionCount} questions for Chapter ${i}`);
      }
    }
    
    console.log('Database setup completed!');
  } catch (error) {
    console.error('Error setting up database:', error);
  }
}

setupDatabase();
```

---

## Step 6: Indexes (If Needed)

If you get index errors, create these indexes:

1. Go to **Firestore Database** → **Indexes** tab
2. Click **Create Index**

**Index 1:**
- Collection: `categories`
- Fields: `order` (Ascending)

**Index 2:**
- Collection: `categories/{categoryId}/chapters`
- Fields: `chapterNumber` (Ascending)

---

## Step 7: Verify Setup

Check these in Firebase Console:

✅ **Collections created:**
- `users` (will be created automatically)
- `categories` (15 categories)
- `categories/{id}/chapters` (50 chapters per category)
- `categories/{id}/chapters/{id}/questions` (10-20 questions per chapter)
- `withdrawals` (empty, for future)
- `app_config` (optional)

✅ **Security rules published**

✅ **Indexes created** (if needed)

---

## Important Notes

1. **Chapter 1 Rules:**
   - 10 questions
   - 20 seconds per question
   - ₹20 cash reward

2. **Chapter 11-50 Rules:**
   - 20 questions
   - 10 seconds per question
   - 15 gold coins reward

3. **Correct Answer Format:**
   - `correctAnswer` is the **index** (0, 1, 2, or 3)
   - Not the text of the answer

4. **Data Entry:**
   - Use Admin Panel (admin/index.html) to add questions
   - Or use Firebase Console manually
   - Or use import script

---

## Next Steps After Setup

1. ✅ Test login/signup (creates user document automatically)
2. ✅ Add real questions via Admin Panel
3. ✅ Test quiz functionality
4. ✅ Verify rewards are added correctly

---

**Last Updated:** $(date)
**Project:** ExamEarn

