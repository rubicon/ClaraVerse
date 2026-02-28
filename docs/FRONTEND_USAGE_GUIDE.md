# Frontend Admin UI - Usage Guide

## Overview

The admin UI now provides complete CRUD functionality for providers and models, with a global tier management system. No more manual JSON editing required!

## Provider Management

### Location
Navigate to: **Admin Panel → Providers**

### Features

#### 1. Add New Provider
1. Click **"Add Provider"** button (top right)
2. Fill in the form:
   - **Required**: Name, Base URL, API Key
   - **Special Types** (choose one):
     - Audio Only (transcription services)
     - Image Generation
     - Image Editing
   - **Security**: Check "Private/Secure Provider" for TEE providers
   - **Optional**: Default Model, Favicon URL, System Prompt
3. Click **"Create Provider"**

#### 2. Edit Provider
1. Click the **Edit** icon (pencil) on any provider card
2. Modify fields as needed
3. Click **"Save Changes"**

#### 3. Delete Provider
1. Click the **Delete** icon (trash) on provider card
2. Confirm deletion
   - **Warning**: This will delete all associated models!

#### 4. Enable/Disable Provider
1. Click the **Power** icon to toggle enabled state
2. Disabled providers won't be available for model selection

### Provider Display
- **Badges show**: Enabled status, Private TEE, Audio/Image types, Model count
- **Click to expand**: View models, recommended tiers, filters
- **API Key**: Masked for security (shows last 4 characters)

---

## Model Management

### Location
Navigate to: **Admin Panel → Models**

### Global Tier Management

#### What are Global Tiers?
- Only **5 models** can be recommended across ALL providers (one per tier)
- Tiers replace the old per-provider recommendation system

#### The 5 Tiers
1. **⭐ Elite** (tier1): Most powerful models
2. **💎 Premium** (tier2): High-quality professional models
3. **🎯 Standard** (tier3): Balanced performance/cost
4. **⚡ Fast** (tier4): Speed-optimized models
5. **✨ New** (tier5): Latest additions

#### Assign Model to Tier
1. In the **Global Model Recommendation Tiers** section
2. Click **"Assign Model"** for empty tier
3. Select model from the picker
4. Model is now assigned to that tier globally

#### Change Tier Assignment
1. Click **"Change"** on an assigned tier
2. Select a different model
3. The new model replaces the old one in that tier

#### Clear Tier
1. Click **"Clear"** on an assigned tier
2. Confirm removal
3. Tier slot is now empty

### Bulk Operations

#### Enable Models for Agents (Bulk)
1. Select models using checkboxes
2. Bulk actions bar appears showing count
3. Click **"Enable for Agents"** or **"Disable for Agents"**
4. All selected models updated simultaneously

**Use Case**: Quickly enable/disable multiple models for agent use without editing each individually

---

## API Integration

The frontend uses these new backend endpoints:

### Provider Endpoints
```
GET    /api/admin/providers          - List all providers
POST   /api/admin/providers          - Create provider
PUT    /api/admin/providers/:id      - Update provider
DELETE /api/admin/providers/:id      - Delete provider
PUT    /api/admin/providers/:id/toggle - Toggle enabled
```

### Tier Endpoints
```
GET    /api/admin/tiers                    - Get all tier assignments
POST   /api/admin/models/:modelId/tier     - Assign model to tier
DELETE /api/admin/models/:modelId/tier     - Clear tier assignment
```

### Bulk Operations
```
PUT    /api/admin/models/bulk/agents-enabled - Bulk update agents_enabled
```

---

## Common Workflows

### Setting Up a New Server

1. **Add Providers**
   - Click "Add Provider" for each AI service (OpenAI, Anthropic, etc.)
   - Fill in API keys and settings

2. **Fetch Models**
   - Go to Model Management
   - Click "Fetch Models" to pull available models from each provider

3. **Assign Global Tiers**
   - In the Global Tier Management section
   - Assign your top 5 models to tiers (one per tier)

4. **Enable for Agents** (if needed)
   - Select models suitable for agent use
   - Bulk enable them

### Migrating from Old System

1. **Check Existing Providers**
   - Providers from `providers.json` are auto-loaded into database

2. **Review and Update**
   - Edit providers to add new fields (secure flag, special types)
   - Update API keys if needed

3. **Reassign Tiers**
   - Old per-provider tiers were cleared during migration
   - Manually assign 5 models to new global tiers

---

## TypeScript Types

### CreateProviderRequest
```typescript
{
  name: string;
  base_url: string;
  api_key: string;
  enabled: boolean;

  // Special types
  audio_only?: boolean;
  image_only?: boolean;
  image_edit_only?: boolean;

  // Security & metadata
  secure?: boolean;
  default_model?: string;
  system_prompt?: string;
  favicon?: string;
}
```

### TierAssignment
```typescript
{
  model_id: string;
  provider_id: number;
  display_name: string;
  tier: string; // tier1-tier5
}
```

---

## Error Handling

### Common Errors

**"Failed to save provider"**
- Check that Base URL is valid
- Ensure API key is provided
- Verify name is unique

**"Failed to assign model to tier"**
- Tier may already be occupied (only 1 model per tier)
- Try clearing the tier first, then reassigning

**"Failed to delete provider"**
- Check if provider has active models
- Models will be deleted automatically (cascading delete)

---

## Tips & Best Practices

1. **Provider Names**: Use clear, descriptive names (e.g., "OpenAI", "Anthropic Claude", "Local Ollama")

2. **API Keys**: Store securely - the UI masks them but they're stored in database

3. **Special Types**:
   - Use "Audio Only" for Whisper, Groq transcription
   - Use "Image Generation" for DALL-E, Midjourney
   - Use "Image Editing" for image manipulation APIs

4. **Global Tiers**:
   - Reserve tier1 for your absolute best model
   - Balance tiers between quality and speed
   - Update tiers as new models are released

5. **Bulk Operations**:
   - Use filters to narrow down models before bulk selecting
   - Double-check selection count before bulk operations

---

## Keyboard Shortcuts

- **Escape**: Close modals/forms
- **Enter**: Submit forms (when focused on input)

---

## Browser Compatibility

Tested on:
- Chrome 120+
- Firefox 120+
- Safari 17+
- Edge 120+

---

## Need Help?

- Backend API errors: Check browser console and network tab
- TypeScript errors: Ensure types are imported correctly
- UI not updating: Try refreshing the page or clearing browser cache
