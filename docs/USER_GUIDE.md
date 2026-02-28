# ClaraVerse User Guide

Welcome to ClaraVerse! This guide will help you get the most out of your privacy-first AI workspace.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Chat Interface](#chat-interface)
3. [Managing Conversations](#managing-conversations)
4. [AI Models & Providers](#ai-models--providers)
5. [Privacy Settings](#privacy-settings)
6. [Visual Workflow Builder](#visual-workflow-builder)
7. [Memory System](#memory-system)
8. [File Uploads](#file-uploads)
9. [Settings & Preferences](#settings--preferences)
10. [Tips & Best Practices](#tips--best-practices)

---

## Getting Started

### First Time Setup

1. **Access ClaraVerse**
   - Self-hosted: Navigate to `http://localhost` (or your domain)
   - Cloud Edition: Visit https://app.claraverse.space

2. **Create an Account**
   - Click "Sign Up"
   - Enter your email and password
   - Verify your email (if enabled)

3. **Login**
   - Enter your credentials
   - You'll be taken to the main chat interface

4. **Select Your First Model**
   - Click the model selector (top of chat)
   - Choose from available AI models
   - If no models appear, check with your administrator

### Interface Overview

```
┌────────────────────────────────────────────────────────────┐
│  [☰] ClaraVerse        [Model: GPT-4o ▼]    [Settings ⚙️]  │
├─────────────┬──────────────────────────────────────────────┤
│             │                                              │
│ Sidebar     │           Main Chat Area                     │
│             │                                              │
│ - New Chat  │  User: Hello!                                │
│ - History   │  AI: Hi! How can I help?                     │
│ - Workflows │                                              │
│ - Memory    │  [Type a message...            ] [Send ➤]   │
│             │                                              │
└─────────────┴──────────────────────────────────────────────┘
```

---

## Chat Interface

### Starting a Conversation

1. **New Chat**: Click "New Chat" in the sidebar
2. **Type Your Message**: Use the input box at the bottom
3. **Send**: Press Enter or click the Send button
4. **Watch Streaming**: Responses appear in real-time as the AI generates them

### Message Features

#### Regenerate Response

If you're not happy with an answer:
- Hover over the AI message
- Click "🔄 Regenerate"
- The AI will generate a new response

#### Response Variations

Create variations of the last response:
- Click "✨ Add Details" for more comprehensive answer
- Click "📝 Make Concise" for shorter version
- Click "🔍 Without Search" to disable web search

#### Copy & Export

- **Copy**: Click the copy icon on any message
- **Export Chat**: Click "⋯" menu → "Export Conversation" (coming soon)

### Interactive Prompts

AI can ask you questions mid-conversation using interactive forms:

**Text Input**:
```
AI: What title should I use for the document?
[___________________________]  [Submit]
```

**Select Options**:
```
AI: Choose a tone:
( ) Professional
( ) Casual
(•) Technical
[Submit]
```

**Checkboxes**:
```
AI: Which features should I include?
[✓] Authentication
[ ] Dark Mode
[✓] File Upload
[Submit]
```

Just fill in the form and click Submit to continue the conversation.

### Markdown Support

ClaraVerse renders rich markdown:

- **Bold**, *italic*, `code`
- Lists and tables
- Code blocks with syntax highlighting
- LaTeX math (coming soon)
- Mermaid diagrams (coming soon)

---

## Managing Conversations

### Conversation List

**Sidebar** shows all your conversations:
- **Search**: Find conversations by name or content
- **Sort**: By date, name, or relevance
- **Filter**: Show starred, archived, or all

### Conversation Actions

Click **⋯** on any conversation to:
- **Rename**: Give it a meaningful title
- **Star**: Mark as favorite
- **Archive**: Hide from main list
- **Delete**: Permanently remove (careful!)
- **Duplicate**: Create a copy
- **Share**: Generate shareable link (coming soon)

### Auto-Titling

ClaraVerse automatically generates conversation titles based on content. You can:
- Let it auto-generate
- Edit manually anytime
- Disable in Settings → "Auto-generate titles"

---

## AI Models & Providers

### Selecting Models

**Click the model dropdown** (top center) to choose:

**Fast Models** (cheaper, quicker):
- GPT-4o-mini
- Claude 3 Haiku
- Gemini 1.5 Flash

**Advanced Models** (smarter, slower):
- GPT-4o
- Claude 3.5 Sonnet
- Gemini 1.5 Pro

**Specialized Models**:
- GPT-4o for vision tasks
- Claude 3 Opus for complex reasoning
- Code models for programming

### Model Capabilities

Different models have different abilities:

| Capability | Example Models |
|------------|----------------|
| **Vision** (image understanding) | GPT-4o, Claude 3.5 Sonnet, Gemini 1.5 Pro |
| **Tool Use** (function calling) | GPT-4o, Claude 3.5 Sonnet |
| **Large Context** (long documents) | Claude 3.5 Sonnet (200k), Gemini 1.5 Pro (1M) |
| **Code** (programming tasks) | GPT-4o, Claude 3.5 Sonnet, CodeLlama |

### Switching Models Mid-Conversation

You can change models during a conversation:
1. Select a new model from the dropdown
2. Continue chatting
3. The new model will see the previous conversation history

**Note**: Different models may interpret context differently.

---

## Privacy Settings

### Storage Modes

ClaraVerse offers **per-conversation privacy control**:

#### Browser-Local Mode (Default)
- ✅ Conversations stored in browser IndexedDB
- ✅ Never sent to server
- ✅ Works offline
- ✅ Server admin cannot access
- ❌ No cross-device sync

**Best for**: Sensitive work, compliance, maximum privacy

#### Cloud-Sync Mode
- ✅ Encrypted backup on server
- ✅ Access from multiple devices
- ✅ Automatic sync
- ⚠️ Server has encrypted copy
- ❌ Requires internet

**Best for**: Personal chats, multi-device access

### Switching Storage Mode

**Per Conversation**:
1. Open conversation
2. Click ⋯ menu
3. Select "Privacy Settings"
4. Toggle "Cloud Sync"

**Default for New Conversations**:
1. Settings → Privacy
2. Set "Default Storage Mode"

### Data Export

Export your data anytime:
1. Settings → Privacy
2. Click "Export All Data"
3. Downloads JSON file with all conversations

### Data Deletion

**Delete Single Conversation**:
- Conversation menu → Delete

**Delete All Data**:
1. Settings → Privacy
2. Click "Delete All Local Data"
3. Confirm deletion

**Note**: This only deletes browser data. For cloud-synced conversations, also delete from account settings.

---

## Visual Workflow Builder

### What are Workflows?

Workflows let you create **complex AI automation** visually:

- Chain multiple AI calls together
- Process data through transformations
- Make decisions based on AI output
- Automate repetitive tasks

### Creating a Workflow

1. **Sidebar** → "Workflows" → "New Workflow"
2. **Add Blocks**:
   - Drag blocks from the left panel
   - Connect blocks by dragging from output to input
3. **Configure Blocks**:
   - Click a block to edit settings
   - Set prompts, variables, conditions
4. **Run**:
   - Click "▶ Run"
   - See results in real-time

### Block Types

#### Variable Block
Store and manipulate data:
```
Input: "Hello World"
Transform: uppercase
Output: "HELLO WORLD"
```

#### LLM Block
Call AI models with custom prompts:
```
Prompt: "Summarize this: {{input}}"
Model: GPT-4o-mini
Output: AI-generated summary
```

#### Code Block
Execute custom JavaScript:
```javascript
// Access inputs
const data = inputs.data;

// Transform
const result = data.map(x => x * 2);

// Return
return { doubled: result };
```

#### Conditional Block
Branch based on conditions:
```
If: {{score}} > 0.8
Then: Use advanced model
Else: Use basic model
```

### Example Workflows

#### Content Generation Pipeline
```
[Input Text] → [Summarize (GPT-4o)] → [Expand (Claude)] → [Format (Code)] → [Output]
```

#### Data Analysis
```
[Upload CSV] → [Parse (Code)] → [Analyze (GPT-4o)] → [Visualize (Chart)] → [Report]
```

#### Multi-Language Translation
```
[English Text] → [Translate to Spanish] → [Translate to French] → [Translate to German]
```

---

## Memory System

### How Clara Memory Works

Clara intelligently manages conversation context:

- **Short-Term Memory**: Active conversation context (always included)
- **Long-Term Memory**: Facts and preferences (included when relevant)
- **Auto-Archival**: Automatically archives less-used memories to save tokens

### Viewing Memory

1. **Sidebar** → "Memory"
2. See all stored memories
3. Filter by:
   - Active (in short-term memory)
   - Archived (in long-term storage)
   - Importance score

### Managing Memory

**Add Explicit Memory**:
```
User: Remember that I prefer TypeScript over JavaScript
AI: Got it! I'll remember you prefer TypeScript.
```

**View Memory**:
```
User: What do you remember about my preferences?
AI: I remember:
- You prefer TypeScript over JavaScript
- You work in healthcare
- You're based in New York
```

**Clear Memory**:
1. Memory panel → Select memories
2. Click "Archive" or "Delete"
3. Confirm

### Memory Scoring

ClaraVerse scores memories by:
- **Recency**: Recently mentioned = higher score
- **Frequency**: Often mentioned = higher score
- **Importance**: User-marked as important = higher score
- **Relevance**: Related to current topic = higher score

High-scored memories stay in short-term memory. Low-scored ones get archived.

---

## File Uploads

### Supported File Types

ClaraVerse can process:

- **Images**: PNG, JPG, WEBP, GIF
- **Documents**: PDF, TXT, MD
- **Data**: CSV, JSON, YAML
- **Code**: Any source code file
- **Audio**: MP3, WAV, M4A (transcription)

### Uploading Files

1. **Click 📎 (paperclip icon)** in chat input
2. **Select file** from your computer
3. **File preview** appears
4. **Ask questions** about the file:
   - "What's in this image?"
   - "Summarize this PDF"
   - "Analyze this CSV data"

### Image Analysis

With vision models (GPT-4o, Claude 3.5 Sonnet):

```
[Upload: screenshot.png]
User: What does this UI look like?
AI: This appears to be a login form with...
```

### PDF Documents

```
[Upload: report.pdf]
User: Summarize the key findings
AI: The document discusses three main points:
1. ...
2. ...
3. ...
```

### CSV Data Analysis

```
[Upload: sales_data.csv]
User: What are the trends?
AI: Analyzing your sales data:
- Revenue up 15% YoY
- Q4 strongest quarter
- Product A is top seller
```

### File Limits

- **Max file size**: 10MB (configurable by admin)
- **Files per message**: 5
- **Total storage**: Limited by browser (typically ~50MB-250MB)

---

## Settings & Preferences

### Accessing Settings

Click **⚙️ (gear icon)** in top right → Settings

### General Settings

- **Theme**: Light / Dark / Auto
- **Language**: Interface language
- **Font Size**: Adjust text size
- **Animations**: Enable/disable animations

### Chat Settings

- **Auto-send**: Send on Enter (vs Shift+Enter)
- **Stream responses**: Show text as it generates
- **Auto-scroll**: Scroll to new messages
- **Show timestamps**: Display message times
- **Message grouping**: Group by sender

### Privacy Settings

- **Default storage mode**: Browser-local or Cloud-sync
- **Analytics**: Share usage data (helps improve ClaraVerse)
- **Crash reports**: Send error reports
- **Conversation analytics**: Let AI analyze usage patterns

### Model Settings

- **Default model**: Auto-selected for new chats
- **Temperature**: Creativity level (0 = focused, 1 = creative)
- **Max tokens**: Response length limit
- **Top P**: Diversity of responses

### Keyboard Shortcuts

- **Ctrl+K** / **Cmd+K**: Quick model switcher
- **Ctrl+/** / **Cmd+/**: Search conversations
- **Ctrl+N** / **Cmd+N**: New conversation
- **Esc**: Close modal/panel
- **↑/↓**: Navigate chat history

### Data & Storage

- **Export data**: Download all conversations
- **Clear cache**: Free up browser storage
- **Delete account**: Permanently remove account

---

## Tips & Best Practices

### Getting Better Responses

**Be Specific**:
```
❌ "Write code"
✅ "Write a Python function to parse CSV files with error handling"
```

**Provide Context**:
```
❌ "Help me with this"
✅ "I'm building a React app and need help with state management using Zustand"
```

**Break Down Complex Tasks**:
```
Instead of: "Build a full authentication system"
Try:
1. "Design a user schema for authentication"
2. "Write the signup API endpoint"
3. "Implement JWT token generation"
```

### Optimizing Costs

**Use Appropriate Models**:
- Quick tasks → GPT-4o-mini, Claude Haiku (cheaper)
- Complex reasoning → GPT-4o, Claude Sonnet (better quality)
- Vision tasks → Multimodal models only

**Manage Context Length**:
- Clear old conversations
- Archive memories you don't need
- Start new chats for unrelated topics

**Use Local Models**:
- For development and testing
- For privacy-sensitive tasks
- To avoid API costs entirely

### Privacy Best Practices

**Browser-Local for Sensitive Data**:
- Legal documents
- Medical information
- Financial data
- Trade secrets

**Regular Exports**:
- Export important conversations
- Back up to encrypted storage
- Don't rely solely on browser storage

**Review Cloud-Synced Chats**:
- Periodically review what's synced
- Move sensitive chats to local-only
- Delete outdated synced conversations

### Performance Tips

**Clear Browser Data**:
- Clear old conversations periodically
- Export first if you want to keep them
- Settings → Clear cache

**Use Efficient Models**:
- Faster models = quicker responses
- Lower token limits = less waiting

**Manage Uploads**:
- Compress large files
- Use appropriate file formats
- Delete uploaded files after use

### Workflow Tips

**Start Simple**:
- Begin with linear workflows
- Add complexity gradually
- Test each step before adding more

**Use Templates**:
- Save successful workflows as templates
- Modify templates for similar tasks
- Share templates with team (coming soon)

**Debug Workflows**:
- Run step-by-step
- Check outputs at each stage
- Use variables to inspect intermediate results

---

## Need Help?

### Documentation

- [FAQ](FAQ.md) - Common questions
- [Troubleshooting](TROUBLESHOOTING.md) - Fix issues
- [API Reference](../backend/docs/API_REFERENCE.md) - For developers

### Community Support

- **Discord**: [Join our Discord](https://discord.com/invite/j633fsrAne)
- **GitHub Discussions**: [Ask questions](https://github.com/claraverse-space/ClaraVerse-Scarlet/discussions)
- **Email**: [hello@claraverse.space](mailto:hello@claraverse.space)

### Report Issues

- **Bug Reports**: [GitHub Issues](https://github.com/claraverse-space/ClaraVerse-Scarlet/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/claraverse-space/ClaraVerse-Scarlet/discussions)

---

**Welcome to ClaraVerse! We hope you enjoy your privacy-first AI experience.** 🚀
