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
                },
                appVersion: '1.0.0',
                updateCheckUrl: window.UPDATE_CHECK_URL || 'https://api.examearn.com/check-update'
            };
            window.dispatchEvent(new Event('configLoaded'));
        });
})();

