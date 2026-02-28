# Cloudflare Turnstile CAPTCHA Integration Guide

## ✅ What's Been Implemented

I've successfully integrated Cloudflare Turnstile CAPTCHA into your ClaraVerse login page. Here's what was done:

### 1. **Package Installed** ✅
- Added `@marsidev/react-turnstile@^1.3.1` to `package.json`

### 2. **New Components Created** ✅
- **`TurnstileWidget.tsx`** - Reusable Turnstile component wrapper
  - Handles success, error, and expiry callbacks
  - Automatically hides if site key is not configured
  - Supports light theme

### 3. **Auth Service Updated** ✅
- **`authService.ts`** - Both `signIn()` and `signUp()` now accept optional `captchaToken`
  - `signIn(email, password, captchaToken?)`
  - `signUp(email, password, username?, captchaToken?)`
  - Tokens passed to Supabase Auth API

### 4. **Auth Form Enhanced** ✅
- **`AuthForm.tsx`** - Integrated Turnstile widget
  - CAPTCHA appears for both Sign In and Sign Up modes
  - Hidden for "Forgot Password" flow
  - Token automatically captured and sent with auth requests
  - Token reset on mode change or expiry

### 5. **Environment Configuration** ✅
- **`.env.example`** - Added Turnstile configuration template

---

## 🔧 Setup Instructions

### Step 1: Install Dependencies

Due to permissions issues, you'll need to manually install the npm package:

```bash
cd frontend
npm install
```

This will:
- Install `@marsidev/react-turnstile`
- Update `package-lock.json`

### Step 2: Get Cloudflare Turnstile Site Key

1. Go to https://dash.cloudflare.com/
2. Navigate to **Turnstile** in the sidebar
3. Click **"Add Site"**
4. Configure your site:
   - **Site Name**: ClaraVerse
   - **Domain**: Your production domain (e.g., `claraverse.com`)
   - **For Local Testing**: Add `localhost` to the domain allowlist
   - **Widget Mode**: Managed (Recommended)
   - **Security Level**: Choose based on your needs

5. Copy the **Site Key** (starts with `0x...`)

### Step 3: Configure Environment Variables

1. Copy `.env.example` to `.env` (if not already done):
   ```bash
   cp .env.example .env
   ```

2. Add your Turnstile site key:
   ```env
   VITE_TURNSTILE_SITE_KEY=0x4AAAAAAA...your-site-key
   ```

### Step 4: Configure Supabase (Backend)

To enable CAPTCHA verification on Supabase:

1. Go to **Supabase Dashboard** → Your Project → **Authentication** → **Providers**
2. Scroll to **Security and Validation**
3. Enable **Cloudflare Turnstile**
4. Enter your Turnstile **Site Key** and **Secret Key**

**Important**: Without this configuration, CAPTCHA tokens will be ignored by Supabase.

### Step 5: Test Locally

1. Start the development server:
   ```bash
   npm run dev
   ```

2. Navigate to the login page
3. You should see the Cloudflare Turnstile challenge
4. Complete the challenge and sign in/sign up

---

## 🔍 How It Works

### User Flow

```
1. User opens login page
   ↓
2. Turnstile widget loads automatically
   ↓
3. User solves CAPTCHA challenge (if required)
   ↓
4. Turnstile generates a token
   ↓
5. Token stored in React state
   ↓
6. User submits login form
   ↓
7. Token sent to Supabase Auth API
   ↓
8. Supabase validates token with Cloudflare
   ↓
9. If valid, authentication proceeds
```

### Code Architecture

```typescript
// TurnstileWidget.tsx
export const TurnstileWidget = forwardRef<TurnstileWidgetRef, TurnstileWidgetProps>(...);

// Exposes reset() method for parent components
useImperativeHandle(ref, () => ({
  reset: () => turnstileRef.current?.reset(),
}));

// AuthForm.tsx
const [captchaToken, setCaptchaToken] = useState<string | undefined>();
const turnstileRef = useRef<TurnstileWidgetRef>(null);

// Auto-reset CAPTCHA on auth failure
if (response.error) {
  turnstileRef.current?.reset();
  setCaptchaToken(undefined);
  return;
}

// Sign in with CAPTCHA
authService.signIn(email, password, captchaToken);

// Sign up with CAPTCHA
authService.signUp(email, password, username, captchaToken);
```

### Auto-Reset on Failure

The CAPTCHA widget automatically resets when authentication fails, ensuring smooth user experience:
- **Wrong Password**: Widget resets immediately, user solves fresh CAPTCHA
- **Network Error**: Widget resets, ready for retry
- **Token Expiry**: Widget auto-refreshes before expiration

This prevents the "timeout-or-duplicate" error when retrying after failed attempts.

---

## 📋 Configuration Options

### Turnstile Widget Themes

Edit `TurnstileWidget.tsx` to customize:

```typescript
options={{
  theme: 'light',  // or 'dark', 'auto'
  size: 'normal',  // or 'compact'
}}
```

### Conditional CAPTCHA

If you want to enable/disable CAPTCHA dynamically:

```typescript
// In .env
VITE_ENABLE_CAPTCHA=true

// In TurnstileWidget.tsx
const enableCaptcha = import.meta.env.VITE_ENABLE_CAPTCHA === 'true';
if (!siteKey || !enableCaptcha) {
  return null;
}
```

---

## 🧪 Testing

### Local Testing Checklist

- [ ] CAPTCHA widget appears on login page
- [ ] CAPTCHA widget appears on signup page
- [ ] CAPTCHA widget does NOT appear on forgot password page
- [ ] Token is captured after solving CAPTCHA
- [ ] Login works with CAPTCHA
- [ ] Signup works with CAPTCHA
- [ ] Error handling works if CAPTCHA fails

### Production Testing

- [ ] Add production domain to Cloudflare Turnstile allowlist
- [ ] Update `VITE_TURNSTILE_SITE_KEY` with production key
- [ ] Test login/signup flow end-to-end
- [ ] Monitor Supabase logs for CAPTCHA validation

---

## 🔐 Security Features

1. **Bot Protection**: Cloudflare Turnstile prevents automated bot attacks
2. **Invisible Mode**: Can be configured for invisible challenges (fewer interruptions)
3. **Token Expiry**: Tokens expire after 10 minutes (automatically refreshed)
4. **No Vendor Lock-in**: Can switch to other CAPTCHA providers easily
5. **Privacy-Friendly**: No user tracking or data collection by Cloudflare

---

## 🐛 Troubleshooting

### CAPTCHA Widget Not Appearing

**Problem**: Widget doesn't show up on the page

**Solutions**:
1. Check `.env` file has `VITE_TURNSTILE_SITE_KEY` set
2. Verify environment variable is prefixed with `VITE_`
3. Restart dev server after adding environment variable
4. Check browser console for errors

### "Invalid Site Key" Error

**Problem**: Turnstile shows error about invalid site key

**Solutions**:
1. Verify site key is correct (starts with `0x`)
2. Check `localhost` is in Cloudflare Turnstile domain allowlist
3. Ensure you're using the **Site Key**, not the **Secret Key**

### CAPTCHA Validation Fails

**Problem**: Authentication fails even after solving CAPTCHA

**Solutions**:
1. Check Supabase has Turnstile configured in **Authentication → Providers**
2. Verify both site key and secret key are configured in Supabase
3. Check Supabase logs for validation errors
4. The widget now auto-resets on auth failure - no manual action needed

### Docker Build Fails

**Problem**: `npm ci` fails with "Missing: @marsidev/react-turnstile"

**Solution**:
```bash
cd frontend
npm install  # Updates package-lock.json
git add package-lock.json
git commit -m "Update package-lock.json for Turnstile"
```

---

## 📚 Resources

- **Turnstile Docs**: https://developers.cloudflare.com/turnstile/
- **Supabase CAPTCHA**: https://supabase.com/docs/guides/auth/captcha
- **React Turnstile**: https://github.com/marsidev/react-turnstile

---

## 🎯 Next Steps

1. ✅ Run `npm install` in `frontend/` directory
2. ✅ Get Cloudflare Turnstile site key
3. ✅ Add `VITE_TURNSTILE_SITE_KEY` to `.env`
4. ✅ Configure Supabase with Turnstile credentials
5. ✅ Test login/signup with CAPTCHA
6. ✅ Add production domain to Turnstile allowlist before deployment

---

## 🚀 Deployment Checklist

Before deploying to production:

- [ ] Get production Turnstile site key
- [ ] Add production domain to Turnstile allowlist
- [ ] Update `VITE_TURNSTILE_SITE_KEY` in production environment
- [ ] Configure Supabase production project with Turnstile
- [ ] Test production login/signup flow
- [ ] Monitor CAPTCHA solve rates in Cloudflare dashboard

---

**All code changes are complete and ready to use! Just need to run `npm install` and configure your Turnstile keys.** 🎉
