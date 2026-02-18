# OAuth 2.0 Configuration

## Google OAuth Client ID

**Client ID:** `531991202663-92qvrma2jg8juh792n80a84ivupi5oia.apps.googleusercontent.com`

## Usage

This OAuth Client ID is configured for Google Sign-In authentication in the ExamEarn platform.

### Configuration Files

1. **`public/config.js`** - Client-side config (fallback)
2. **`api/config.js`** - Server-side config (Vercel environment variables)

### Environment Variable

For Vercel deployment, add this environment variable:

```
OAUTH_CLIENT_ID=531991202663-92qvrma2jg8juh792n80a84ivupi5oia.apps.googleusercontent.com
```

### Firebase Setup

1. Go to Firebase Console → Authentication → Sign-in method
2. Enable "Google" provider
3. Add this OAuth Client ID in the authorized domains
4. Configure OAuth consent screen in Google Cloud Console

### Security Notes

- ⚠️ **Never commit sensitive credentials to public repositories**
- ✅ Use environment variables for production
- ✅ Keep OAuth credentials secure
- ✅ Rotate credentials if compromised

---

**Saved on:** $(date)
**Project:** ExamEarn

