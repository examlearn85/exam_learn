// Vercel Serverless Function
// Accessible at: /api/config

module.exports = (req, res) => {
    // Get environment variables from Vercel
    const config = {
        apkDownloadUrl: process.env.APK_DOWNLOAD_URL || '/downloads/examearn.apk',
        heroText: process.env.HERO_TEXT || 'Quiz Khelo, Knowledge Badhao, Paise Kamao!',
        firebaseConfig: {
            apiKey: process.env.FIREBASE_API_KEY || '',
            authDomain: process.env.FIREBASE_AUTH_DOMAIN || '',
            projectId: process.env.FIREBASE_PROJECT_ID || '',
            storageBucket: process.env.FIREBASE_STORAGE_BUCKET || '',
            messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID || '',
            appId: process.env.FIREBASE_APP_ID || '',
            measurementId: process.env.FIREBASE_MEASUREMENT_ID || '', // Optional
        },
        oauthClientId: process.env.OAUTH_CLIENT_ID || '531991202663-92qvrma2jg8juh792n80a84ivupi5oia.apps.googleusercontent.com',
        appVersion: '1.0.0',
    };

    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET');
    res.setHeader('Content-Type', 'application/json');

    res.status(200).json(config);
};

