# Frontend Developer Guide

This guide covers the ClaraVerse frontend architecture, patterns, and best practices for developers.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Tech Stack](#tech-stack)
4. [State Management](#state-management)
5. [Routing](#routing)
6. [API Integration](#api-integration)
7. [Components](#components)
8. [Styling](#styling)
9. [Best Practices](#best-practices)
10. [Testing](#testing)

---

## Architecture Overview

ClaraVerse frontend follows a **feature-based architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    React Application                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │              │  │              │  │              │     │
│  │ Components   │  │   Routes     │  │   Services   │     │
│  │              │  │              │  │              │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                 │             │
│         └─────────────────┼─────────────────┘             │
│                           │                               │
│                    ┌──────▼───────┐                       │
│                    │              │                       │
│                    │  Zustand     │                       │
│                    │  Store       │                       │
│                    │              │                       │
│                    └──────────────┘                       │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Component Isolation**: Each component is self-contained
2. **State Centralization**: Zustand for global state
3. **API Abstraction**: Centralized API client
4. **Type Safety**: TypeScript strict mode
5. **Performance**: Code splitting and lazy loading

---

## Project Structure

```
frontend/
├── src/
│   ├── components/          # React components
│   │   ├── ui/              # Base UI components (Button, Input, etc.)
│   │   ├── layout/          # Layout components (Header, Sidebar, etc.)
│   │   ├── chat/            # Chat-specific components
│   │   ├── workflow/        # Workflow builder components
│   │   └── ...
│   │
│   ├── pages/               # Page components (route targets)
│   │   ├── HomePage.tsx
│   │   ├── ChatPage.tsx
│   │   └── ...
│   │
│   ├── routes/              # Route configuration
│   │   └── index.tsx
│   │
│   ├── services/            # API clients and external services
│   │   ├── api.ts           # REST API client
│   │   ├── websocket.ts     # WebSocket client
│   │   └── ...
│   │
│   ├── store/               # Zustand stores
│   │   ├── useAppStore.ts   # App-wide state
│   │   ├── useChatStore.ts  # Chat state
│   │   └── ...
│   │
│   ├── hooks/               # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useChat.ts
│   │   └── ...
│   │
│   ├── utils/               # Utility functions
│   │   ├── format.ts
│   │   ├── validation.ts
│   │   └── ...
│   │
│   ├── types/               # TypeScript type definitions
│   │   ├── api.ts
│   │   ├── chat.ts
│   │   └── ...
│   │
│   ├── constants/           # App constants
│   │   └── index.ts
│   │
│   ├── lib/                 # Third-party library configurations
│   │   └── utils.ts         # Tailwind cn utility
│   │
│   ├── assets/              # Static assets
│   │   ├── images/
│   │   └── fonts/
│   │
│   ├── styles/              # Global styles
│   │   └── globals.css
│   │
│   ├── App.tsx              # Root component
│   ├── main.tsx             # Entry point
│   └── index.css            # Global CSS + Tailwind
│
├── public/                  # Public assets
│   ├── favicon.ico
│   └── ...
│
├── .env.example             # Environment variables template
├── .env                     # Environment variables (gitignored)
├── vite.config.ts           # Vite configuration
├── tsconfig.json            # TypeScript configuration
├── tsconfig.app.json        # App-specific TS config
├── tsconfig.node.json       # Node-specific TS config
├── tailwind.config.js       # Tailwind CSS configuration
├── postcss.config.js        # PostCSS configuration
├── eslint.config.js         # ESLint configuration
└── package.json             # Dependencies and scripts
```

---

## Tech Stack

### Core Technologies

- **React 19**: UI library with hooks and concurrent features
- **TypeScript 5.9**: Type-safe development
- **Vite 7**: Build tool and dev server
- **Tailwind CSS 4**: Utility-first CSS framework

### State Management

- **Zustand 5**: Lightweight state management
  - DevTools integration
  - Persist middleware for localStorage
  - Type-safe stores

### Routing

- **React Router 7**: Client-side routing
  - Using v6 patterns with `createBrowserRouter`
  - Data router for better performance
  - Nested routes with layouts

### API & Real-time

- **Fetch API**: REST API calls
- **WebSocket**: Real-time chat streaming
- **IDB**: IndexedDB for local storage

### UI Libraries

- **Lucide React**: Icon library
- **Framer Motion**: Animation library
- **React Markdown**: Markdown rendering
- **React Syntax Highlighter**: Code highlighting
- **XYFlow**: Flow/node editor for workflows

### Testing

- **Vitest**: Unit testing framework
- **Testing Library**: Component testing
- **Coverage**: v8 code coverage

---

## State Management

### Zustand Store Pattern

ClaraVerse uses Zustand for global state management:

```typescript
// src/store/useAppStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface AppState {
  // State
  theme: 'light' | 'dark' | 'auto';
  sidebarOpen: boolean;

  // Actions
  setTheme: (theme: 'light' | 'dark' | 'auto') => void;
  toggleSidebar: () => void;
}

export const useAppStore = create<AppState>()(
  devtools(
    persist(
      (set) => ({
        // Initial state
        theme: 'auto',
        sidebarOpen: true,

        // Actions
        setTheme: (theme) => set({ theme }),
        toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
      }),
      {
        name: 'app-storage', // LocalStorage key
      }
    )
  )
);
```

### Using Stores in Components

```typescript
import { useAppStore } from '@/store/useAppStore';

export const ThemeSwitcher = () => {
  // Select only what you need (prevents unnecessary re-renders)
  const theme = useAppStore((state) => state.theme);
  const setTheme = useAppStore((state) => state.setTheme);

  return (
    <select value={theme} onChange={(e) => setTheme(e.target.value as any)}>
      <option value="light">Light</option>
      <option value="dark">Dark</option>
      <option value="auto">Auto</option>
    </select>
  );
};
```

### Store Best Practices

1. **Selective Subscription**: Only subscribe to the state you need
2. **Actions Separate**: Keep actions separate from state
3. **TypeScript**: Always type your stores
4. **Persistence**: Use persist middleware for data that should survive reload
5. **DevTools**: Use devtools middleware in development

---

## Routing

### Route Configuration

```typescript
// src/routes/index.tsx
import { createBrowserRouter } from 'react-router-dom';
import MainLayout from '@/components/layout/MainLayout';
import HomePage from '@/pages/HomePage';
import ChatPage from '@/pages/ChatPage';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <MainLayout />,
    children: [
      {
        index: true,
        element: <HomePage />,
      },
      {
        path: 'chat/:conversationId?',
        element: <ChatPage />,
      },
      {
        path: 'workflows',
        element: <WorkflowsPage />,
      },
    ],
  },
]);
```

### Using Router

```typescript
// src/main.tsx
import { RouterProvider } from 'react-router-dom';
import { router } from './routes';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
```

### Navigation

```typescript
import { useNavigate, useParams } from 'react-router-dom';

export const ChatComponent = () => {
  const navigate = useNavigate();
  const { conversationId } = useParams();

  const createNewChat = () => {
    navigate('/chat/new');
  };

  return (
    <button onClick={createNewChat}>
      New Chat
    </button>
  );
};
```

---

## API Integration

### API Client

```typescript
// src/services/api.ts
class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

class ApiClient {
  private baseURL: string;

  constructor(baseURL: string) {
    this.baseURL = baseURL;
  }

  private async request<T>(
    endpoint: string,
    options?: RequestInit
  ): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
    });

    if (!response.ok) {
      throw new ApiError(response.status, `Request failed: ${response.statusText}`);
    }

    return response.json();
  }

  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  async post<T>(endpoint: string, data?: unknown): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async put<T>(endpoint: string, data?: unknown): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }
}

export const api = new ApiClient(import.meta.env.VITE_API_BASE_URL || '');
```

### Using the API Client

```typescript
import { api } from '@/services/api';
import type { Model, Provider } from '@/types/api';

// Get all models
const models = await api.get<Model[]>('/api/models');

// Create a provider
const provider = await api.post<Provider>('/api/providers', {
  name: 'OpenAI',
  api_key: 'sk-...',
  enabled: true,
});
```

### WebSocket Client

```typescript
// src/services/websocket.ts
export class WebSocketClient {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;

  connect(url: string) {
    this.ws = new WebSocket(url);

    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectAttempts = 0;
    };

    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleMessage(data);
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    this.ws.onclose = () => {
      console.log('WebSocket closed');
      this.reconnect(url);
    };
  }

  private reconnect(url: string) {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => {
        console.log(`Reconnecting (${this.reconnectAttempts}/${this.maxReconnectAttempts})...`);
        this.connect(url);
      }, 1000 * this.reconnectAttempts);
    }
  }

  send(data: unknown) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    }
  }

  private handleMessage(data: unknown) {
    // Handle incoming messages
  }

  disconnect() {
    this.ws?.close();
  }
}
```

---

## Components

### Component Structure

```typescript
// src/components/ui/Button.tsx
import { forwardRef, type ButtonHTMLAttributes } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline: 'border border-input bg-background hover:bg-accent',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface ButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);

Button.displayName = 'Button';
```

### Component Best Practices

1. **TypeScript**: Always type props
2. **forwardRef**: Use for components that need ref access
3. **Variants**: Use CVA for component variants
4. **Composition**: Prefer composition over props drilling
5. **Memo**: Use `React.memo` for expensive components

### Custom Hooks

```typescript
// src/hooks/useAuth.ts
import { useState, useEffect } from 'react';
import { supabase } from '@/services/supabase';
import type { User } from '@supabase/supabase-js';

export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null);
      setLoading(false);
    });

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    return () => subscription.unsubscribe();
  }, []);

  return { user, loading };
};
```

---

## Styling

### Tailwind CSS

ClaraVerse uses Tailwind for styling:

```typescript
// Example component
export const Card = ({ children }: { children: React.ReactNode }) => {
  return (
    <div className="rounded-lg border bg-card p-6 shadow-sm">
      {children}
    </div>
  );
};
```

### Utility Function

```typescript
// src/lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

Usage:

```typescript
<div className={cn('base-classes', someCondition && 'conditional-classes', className)} />
```

---

## Best Practices

### 1. Use Path Aliases

Always use `@/` instead of relative imports:

```typescript
// ✅ Good
import { Button } from '@/components/ui/Button';
import { useAppStore } from '@/store/useAppStore';

// ❌ Bad
import { Button } from '../../components/ui/Button';
import { useAppStore } from '../../../store/useAppStore';
```

### 2. Type Everything

```typescript
// ✅ Good
interface ChatMessage {
  id: string;
  content: string;
  role: 'user' | 'assistant';
  timestamp: Date;
}

export const MessageList = ({ messages }: { messages: ChatMessage[] }) => {
  // ...
};

// ❌ Bad
export const MessageList = ({ messages }: any) => {
  // ...
};
```

### 3. Extract Reusable Logic

```typescript
// ✅ Good - Custom hook
export const useChatMessages = (conversationId: string) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadMessages(conversationId).then(setMessages).finally(() => setLoading(false));
  }, [conversationId]);

  return { messages, loading };
};

// ❌ Bad - Logic in component
export const ChatComponent = ({ conversationId }) => {
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    loadMessages(conversationId).then(setMessages).finally(() => setLoading(false));
  }, [conversationId]);
  // ...
};
```

### 4. Avoid Prop Drilling

```typescript
// ✅ Good - Use Zustand
const theme = useAppStore((state) => state.theme);

// ❌ Bad - Prop drilling
<Parent theme={theme}>
  <Child theme={theme}>
    <GrandChild theme={theme} />
  </Child>
</Parent>
```

---

## Testing

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive testing documentation.

Quick example:

```typescript
// src/components/ui/Button.test.tsx
import { render, screen } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('handles click events', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    screen.getByText('Click me').click();
    expect(handleClick).toHaveBeenCalledOnce();
  });
});
```

---

## Development Workflow

### 1. Start Development Server

```bash
cd frontend
npm run dev
```

### 2. Code Quality Checks

```bash
# Type checking
npm run type-check

# Linting
npm run lint

# Formatting
npm run format:check
npm run format  # Auto-fix
```

### 3. Build for Production

```bash
npm run build
npm run preview  # Test production build locally
```

---

## Need Help?

- **Backend Integration**: See [API_REFERENCE.md](../backend/docs/API_REFERENCE.md)
- **Troubleshooting**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Contributing**: See [CONTRIBUTING.md](../CONTRIBUTING.md)
- **Discord**: [Join our Discord](https://discord.com/invite/j633fsrAne)

---

**Happy coding!** 🚀
