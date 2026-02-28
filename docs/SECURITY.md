# ClaraVerse Security & Privacy

Last Updated: 2026-01-09

## How We Protect Your Data

### Data Storage Model

ClaraVerse uses a **zero-knowledge architecture** for your OAuth integrations:

| What We Store | How We Store It | Can We Read It? |
|---------------|-----------------|-----------------|
| **Integration Mappings** | Encrypted (AES-256-GCM) | ❌ No - Encrypted with your unique key |
| **OAuth Tokens** | Not stored - Managed by Composio | ❌ Never - We never see these |
| **Email/Document Content** | Not stored | ❌ Never - Only accessed in real-time when you request |
| **User IDs** | Plain text | ✅ Yes - Required for routing |

### What We DON'T Store

- **OAuth Access Tokens**: Stored securely at Composio (SOC 2 Type II compliant)
- **OAuth Refresh Tokens**: Stored securely at Composio
- **Your Actual Passwords**: Never transmitted to us
- **Email Content**: Not stored; only fetched when you request
- **Document Data**: Not stored; only accessed when you request

### Encryption Details

**Bank-Level Encryption:**
- Algorithm: AES-256-GCM (Galois/Counter Mode)
- Key Derivation: HKDF (HMAC-based Key Derivation Function)
- Per-User Keys: Each user has a unique encryption key derived from the master key
- Authenticated Encryption: Prevents tampering

**What This Means:**
- Even if our database is compromised, your credentials remain encrypted
- Even ClaraVerse staff cannot decrypt your credentials
- Each user's data is encrypted with a different key

## Third-Party Services

### Composio OAuth Platform

For Gmail, Google Sheets, and other OAuth integrations, we use **Composio** as our OAuth provider:

**Why Composio?**
- SOC 2 Type II certified
- Handles complex OAuth flows securely
- Automatic token refresh
- Enterprise-grade security

**What Composio Stores:**
- Your OAuth access tokens
- Your OAuth refresh tokens
- Connection metadata

**What Composio Does NOT Store:**
- Your Google/Microsoft passwords
- Your email or document content
- Any personal data beyond OAuth tokens

**Composio's Security:**
- Industry-standard OAuth 2.0 implementation
- Encrypted token storage
- Automatic token rotation
- Regular security audits

## What Happens When You Delete an Integration

When you delete a Gmail or Google Sheets integration from ClaraVerse:

1. **✅ OAuth Connection Revoked**: We immediately call Composio API to disconnect your account
2. **✅ Database Record Deleted**: All encrypted credential data is permanently removed
3. **✅ Access Tokens Invalidated**: Composio revokes all OAuth tokens
4. **✅ Future Access Blocked**: Your Gmail/Sheets can no longer be accessed via ClaraVerse

**Important**: Deletion is permanent. You'll need to reconnect via OAuth if you want to use the integration again.

## Your Data Rights

### You Have the Right To:

1. **Access Your Data**: View all integrations you've connected
2. **Delete Your Data**: Remove any integration at any time
3. **Export Your Data**: Request a copy of your connection metadata
4. **Revoke Access**: Immediately disconnect any service
5. **Account Deletion**: Permanently delete your ClaraVerse account and all associated data

### How to Exercise Your Rights:

- **Delete Integration**: Go to Settings → Credentials → Click delete icon
- **Delete Account**: Contact support@claraverse.space
- **Export Data**: Contact support@claraverse.space

## Security Practices

### What We Do:

✅ **Encryption at Rest**: All credentials encrypted with AES-256-GCM
✅ **Per-User Rate Limiting**: 50 API calls per minute per user
✅ **OAuth Delegation**: No passwords stored; all via secure OAuth
✅ **Secure Communication**: HTTPS/TLS for all API calls
✅ **Regular Security Updates**: Dependencies updated weekly

### What You Should Do:

✅ **Use Strong Passwords**: For your ClaraVerse account
✅ **Enable 2FA**: On your Google/Microsoft accounts
✅ **Review Connections**: Regularly check which integrations are active
✅ **Disconnect Unused**: Remove integrations you no longer use
✅ **Report Suspicious Activity**: Contact us immediately if you notice anything unusual

## Data Access Scenarios

### ❓ "Can ClaraVerse staff read my emails?"

**No.** We never store email content. When you use Gmail tools:
1. Your request triggers an API call to Gmail (via Composio)
2. Gmail returns email data in real-time
3. We display it to you
4. **It's never stored** - Only exists in memory during your session

### ❓ "What if your database is hacked?"

**You're protected.** Here's what an attacker would get:
- ❌ **Cannot** read your credentials (encrypted with per-user keys)
- ❌ **Cannot** access your OAuth tokens (stored at Composio, not in our DB)
- ❌ **Cannot** read your emails or documents (not stored)
- ⚠️ **Could** see that you have integrations connected (metadata only)

Without our encryption master key (stored separately in secure environment), the data is useless.

### ❓ "What if Composio is hacked?"

Composio is SOC 2 Type II certified and uses enterprise-grade security. However:
- **Worst case**: OAuth tokens could be compromised
- **Your protection**: You can revoke access immediately from Google/Microsoft account settings
- **Our response**: We'd immediately notify all users and invalidate all connections

### ❓ "Can someone impersonate me if they get my session token?"

**Limited exposure.** Session tokens expire after:
- 24 hours of inactivity
- 7 days maximum (even if active)

If compromised:
1. Change your ClaraVerse password immediately
2. Delete and reconnect any integrations
3. Contact support

## Compliance & Certifications

### Current Status:

- **GDPR Compliant**: Right to access, delete, and export data
- **CCPA Compliant**: California Consumer Privacy Act compliance
- **Composio**: SOC 2 Type II certified partner

### Future Plans:

- SOC 2 Type II certification (in progress)
- ISO 27001 certification (planned for 2026)
- HIPAA compliance (planned for healthcare users)

## Incident Response

### If We Detect a Security Issue:

1. **Immediate Action**: Affected systems isolated within 1 hour
2. **User Notification**: Affected users notified within 24 hours
3. **Investigation**: Full forensic analysis within 72 hours
4. **Public Disclosure**: Transparent reporting on security page
5. **Remediation**: Fixes deployed and verified

### How to Report Security Issues:

**Do NOT** report security issues via public channels.

**Email**: security@claraverse.space
**PGP Key**: Available at https://claraverse.space/.well-known/security.txt
**Response Time**: Within 24 hours for critical issues

## Technical Details (For Developers)

### Encryption Implementation

```
Master Key (32 bytes, hex-encoded)
    ↓
HKDF Key Derivation (SHA-256)
    ↓ (with User ID as salt)
Per-User Key (32 bytes)
    ↓
AES-256-GCM Encryption
    ↓
Encrypted Credential Data (base64-encoded)
```

### OAuth Flow

```
1. User clicks "Connect Gmail"
   ↓
2. ClaraVerse → Composio: "Create OAuth link"
   ↓
3. Composio → User: Google OAuth consent screen
   ↓
4. User grants permission
   ↓
5. Google → Composio: OAuth tokens
   ↓
6. Composio → ClaraVerse: "Connection successful"
   ↓
7. ClaraVerse stores: {user_id, integration_type, entity_id}
```

### Data Deletion Flow

```
1. User clicks "Delete Integration"
   ↓
2. ClaraVerse → Composio: "DELETE /connected_accounts/{id}"
   ↓
3. Composio revokes OAuth tokens
   ↓
4. Composio confirms deletion
   ↓
5. ClaraVerse deletes database record
   ↓
6. User confirmation: "Integration deleted"
```

## Questions?

### Contact Us:

- **General Security**: security@claraverse.space
- **Privacy Questions**: privacy@claraverse.space
- **Support**: support@claraverse.space

### Learn More:

- [Composio Security](https://composio.dev/security)
- [Google OAuth Security](https://developers.google.com/identity/protocols/oauth2)
- [ClaraVerse Integration Guide](/docs/COMPOSIO_INTEGRATION_GUIDE.md)

---

**Last Security Audit**: January 2026
**Next Scheduled Audit**: July 2026

*This document is updated as our security practices evolve. Check back regularly for updates.*
