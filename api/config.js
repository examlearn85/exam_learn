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
        },
        appVersion: '1.0.0',
    };

    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET');
    res.setHeader('Content-Type', 'application/json');

    res.status(200).json(config);
};

