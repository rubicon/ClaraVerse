# Privacy Policy

**Last Updated: January 9, 2026**

## The Short Version

- **We encrypt everything**: Your credentials are encrypted and we can't read them
- **No passwords stored**: We use OAuth (secure login with Google/Microsoft)
- **No email storage**: We don't store your emails or documents
- **You control your data**: Delete your integrations anytime
- **Third-party security**: OAuth tokens managed by Composio (SOC 2 certified)

## What Data We Collect

### Account Information
- Email address (for login)
- Display name (optional)
- Account creation date

### Integration Data
- **What we store**: Encrypted connection IDs (we can't read these)
- **What we DON'T store**: Your passwords, OAuth tokens, emails, or documents
- **How we use it**: To connect your integrations when you use them

### Usage Data
- Integration usage counts
- Last used timestamps
- Error logs (for debugging)

## How We Use OAuth (Secure Login)

When you connect Gmail or Google Sheets:

1. **You click "Connect"** → We redirect you to Google's login page
2. **You log in to Google** → We never see your password
3. **Google asks permission** → You approve access
4. **Google sends us a token** → Stored securely at Composio (not in our database)
5. **You're connected!** → We can now access Gmail on your behalf

**Important**: We never see or store your Google password.

## Third-Party Services

### Composio (OAuth Provider)
- **What they do**: Manage OAuth tokens for Gmail, Google Sheets, etc.
- **Security**: SOC 2 Type II certified
- **Privacy**: See [Composio Privacy Policy](https://composio.dev/privacy)

### What This Means:
- Your OAuth tokens are stored by Composio, not us
- Composio is a trusted, certified security provider
- We only get permission to use your integrations, not the tokens themselves

## What Happens When You Delete

### Delete an Integration
1. ✅ **OAuth connection revoked** at Composio
2. ✅ **Database record deleted** from ClaraVerse
3. ✅ **Access blocked** immediately

**Result**: Your Gmail/Sheets can no longer be accessed via ClaraVerse.

### Delete Your Account
1. ✅ **All integrations disconnected**
2. ✅ **All data deleted** (account, credentials, usage logs)
3. ✅ **Email address removed** from our system

**Result**: Complete removal from ClaraVerse. This action is permanent.

## Your Privacy Rights

You have the right to:

- ✅ **Access** your data
- ✅ **Delete** your data
- ✅ **Export** your data
- ✅ **Revoke access** to any integration
- ✅ **Request corrections** to your account info

### How to Exercise Your Rights:
- **In Settings**: Manage integrations, view usage
- **Email Us**: privacy@claraverse.space
- **Delete Account**: Contact support@claraverse.space

## Data Security

### How We Protect Your Data:

**Encryption**
- All credentials encrypted with AES-256-GCM
- Each user has a unique encryption key
- Even we can't decrypt your credentials

**Secure Communication**
- All data transmitted over HTTPS/TLS
- OAuth tokens never leave Composio
- No plain-text password storage

**Access Controls**
- Rate limiting (50 calls/minute per user)
- Session timeouts (24 hours)
- Per-user data isolation

## What We Don't Do

❌ **Don't sell your data** - Ever. To anyone.
❌ **Don't read your emails** - Not stored, not accessed
❌ **Don't share with advertisers** - No third-party marketing
❌ **Don't track across sites** - No external tracking pixels
❌ **Don't store passwords** - All via secure OAuth

## Cookies & Tracking

### We Use Cookies For:
- **Authentication**: Keep you logged in
- **Preferences**: Remember your settings
- **Security**: Prevent unauthorized access

### We Don't Use Cookies For:
- Advertising
- Third-party tracking
- Selling data

## Children's Privacy

ClaraVerse is not intended for users under 13 years old. We do not knowingly collect data from children under 13.

## International Data Transfers

Your data may be processed in:
- United States (primary servers)
- European Union (Composio servers)

All transfers comply with GDPR requirements.

## Changes to This Policy

We'll notify you of any material changes:
- Email notification to your account
- Notice in the application
- Updated "Last Updated" date at top

## Contact Us

**Privacy Questions**: privacy@claraverse.space
**Security Issues**: security@claraverse.space
**General Support**: support@claraverse.space

## Legal Basis (GDPR)

We process your data based on:

1. **Contract**: To provide the service you signed up for
2. **Consent**: When you connect integrations
3. **Legitimate Interest**: To improve our service and prevent fraud

You can withdraw consent anytime by deleting your integrations or account.

## Data Retention

- **Active Accounts**: Data retained while account is active
- **Deleted Integrations**: Removed immediately
- **Deleted Accounts**: All data removed within 30 days
- **Backups**: Deleted from backups within 90 days

## Your California Privacy Rights (CCPA)

California residents have additional rights:

- **Know**: What data we collect and how we use it
- **Delete**: Request deletion of your data
- **Opt-Out**: We don't sell data, so nothing to opt out of
- **Non-Discrimination**: Same service regardless of privacy choices

---

**Questions?** We're here to help: privacy@claraverse.space

**Read More**: See our detailed [Security Documentation](/docs/SECURITY.md)
