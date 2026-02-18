// Firebase Authentication for Web
let firebaseApp;
let auth;
let db;
let isLoginMode = true;

// Initialize Firebase
window.addEventListener('configLoaded', function() {
    const config = window.ExamEarnConfig;
    
    if (config.firebaseConfig && config.firebaseConfig.apiKey) {
        firebaseApp = firebase.initializeApp(config.firebaseConfig);
        auth = firebase.auth();
        db = firebase.firestore();
        
        // Check if user is already logged in
        auth.onAuthStateChanged((user) => {
            if (user) {
                // User is logged in, redirect to dashboard
                window.location.href = 'dashboard.html';
            }
        });
    } else {
        showError('Firebase configuration not found. Please contact administrator.');
    }
});

// Toggle between Login and Sign Up
document.addEventListener('DOMContentLoaded', function() {
    const toggleLink = document.getElementById('toggle-link');
    const toggleText = document.getElementById('toggle-text');
    const submitBtn = document.getElementById('submit-btn');
    const btnText = document.getElementById('btn-text');
    const nameGroup = document.getElementById('name-group');
    const form = document.getElementById('auth-form');

    toggleLink.addEventListener('click', function(e) {
        e.preventDefault();
        isLoginMode = !isLoginMode;
        
        if (isLoginMode) {
            toggleText.textContent = "Don't have an account? ";
            toggleLink.textContent = "Sign Up";
            btnText.textContent = "Login";
            nameGroup.style.display = 'none';
            document.getElementById('name').required = false;
        } else {
            toggleText.textContent = "Already have an account? ";
            toggleLink.textContent = "Login";
            btnText.textContent = "Sign Up";
            nameGroup.style.display = 'block';
            document.getElementById('name').required = true;
        }
    });

    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const name = document.getElementById('name').value;

        const submitBtn = document.getElementById('submit-btn');
        const loading = document.getElementById('loading');
        const btnText = document.getElementById('btn-text');

        // Show loading
        submitBtn.disabled = true;
        loading.classList.add('show');
        btnText.textContent = isLoginMode ? 'Logging in...' : 'Signing up...';
        hideError();

        try {
            if (isLoginMode) {
                // Login
                await auth.signInWithEmailAndPassword(email, password);
                
                // Update last login
                const user = auth.currentUser;
                if (user) {
                    await db.collection('users').doc(user.uid).update({
                        lastLogin: firebase.firestore.FieldValue.serverTimestamp()
                    });
                }
                
                // Redirect to dashboard
                window.location.href = 'dashboard.html';
            } else {
                // Sign Up
                const userCredential = await auth.createUserWithEmailAndPassword(email, password);
                
                // Update display name
                if (name) {
                    await userCredential.user.updateProfile({
                        displayName: name
                    });
                }

                // Create user document in Firestore
                const userData = {
                    uid: userCredential.user.uid,
                    email: email,
                    name: name || '',
                    phone: userCredential.user.phoneNumber || '',
                    createdAt: firebase.firestore.FieldValue.serverTimestamp(),
                    lastLogin: firebase.firestore.FieldValue.serverTimestamp(),
                    currentChapter: 1,
                    completedChapters: [],
                    goldCoins: 0,
                    cashBalance: 0,
                    totalEarnings: 0,
                    isVerified: false,
                    platform: 'web'
                };

                await db.collection('users').doc(userCredential.user.uid).set(userData);
                
                // Redirect to dashboard
                window.location.href = 'dashboard.html';
            }
        } catch (error) {
            console.error('Auth error:', error);
            showError(getErrorMessage(error.code));
        } finally {
            submitBtn.disabled = false;
            loading.classList.remove('show');
            btnText.textContent = isLoginMode ? 'Login' : 'Sign Up';
        }
    });
});

function showError(message) {
    const errorDiv = document.getElementById('error-message');
    errorDiv.textContent = message;
    errorDiv.classList.add('show');
}

function hideError() {
    const errorDiv = document.getElementById('error-message');
    errorDiv.classList.remove('show');
}

function getErrorMessage(errorCode) {
    const errorMessages = {
        'auth/email-already-in-use': 'This email is already registered. Please login instead.',
        'auth/invalid-email': 'Invalid email address.',
        'auth/operation-not-allowed': 'Email/password accounts are not enabled.',
        'auth/weak-password': 'Password should be at least 6 characters.',
        'auth/user-disabled': 'This account has been disabled.',
        'auth/user-not-found': 'No account found with this email.',
        'auth/wrong-password': 'Incorrect password.',
        'auth/network-request-failed': 'Network error. Please check your connection.',
        'auth/too-many-requests': 'Too many failed attempts. Please try again later.'
    };
    
    return errorMessages[errorCode] || 'An error occurred. Please try again.';
}

// Logout function (can be used in other pages)
function logout() {
    auth.signOut().then(() => {
        window.location.href = 'index.html';
    }).catch((error) => {
        console.error('Logout error:', error);
    });
}

