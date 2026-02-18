// ExamEarn Configuration
// This file loads config from API or uses defaults
// For Vercel: Config is loaded from /api/config endpoint

(function() {
    // Try to load config from API first
    fetch('/api/config')
        .then(response => response.json())
        .then(config => {
            window.ExamEarnConfig = config;
            // Trigger config loaded event
            window.dispatchEvent(new Event('configLoaded'));
        })
        .catch(error => {
            console.log('Config API not available, using defaults');
            // Fallback to default config
            window.ExamEarnConfig = {
                apkDownloadUrl: window.APK_DOWNLOAD_URL || '/downloads/examearn.apk',
                heroText: window.HERO_TEXT || 'Quiz Khelo, Knowledge Badhao, Paise Kamao!',
                firebaseConfig: {
                    apiKey: window.FIREBASE_API_KEY || '',
                    authDomain: window.FIREBASE_AUTH_DOMAIN || '',
                    projectId: window.FIREBASE_PROJECT_ID || '',
                    storageBucket: window.FIREBASE_STORAGE_BUCKET || '',
                    messagingSenderId: window.FIREBASE_MESSAGING_SENDER_ID || '',
                    appId: window.FIREBASE_APP_ID || '',
                    measurementId: window.FIREBASE_MEASUREMENT_ID || '', // Optional
                },
                oauthClientId: window.OAUTH_CLIENT_ID || '531991202663-92qvrma2jg8juh792n80a84ivupi5oia.apps.googleusercontent.com',
                appVersion: '1.0.0',
                updateCheckUrl: window.UPDATE_CHECK_URL || 'https://api.examearn.com/check-update'
            };
            window.dispatchEvent(new Event('configLoaded'));
        });
})();

