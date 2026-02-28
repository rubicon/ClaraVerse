# Testing Guide

Comprehensive guide to testing in ClaraVerse.

## Table of Contents

1. [Overview](#overview)
2. [Frontend Testing](#frontend-testing)
3. [Backend Testing](#backend-testing)
4. [E2E Testing](#e2e-testing)
5. [Best Practices](#best-practices)
6. [CI/CD Integration](#cicd-integration)

---

## Overview

ClaraVerse uses a multi-layered testing approach:

- **Unit Tests**: Test individual functions and components
- **Integration Tests**: Test component/service interactions
- **E2E Tests**: Test complete user workflows
- **Manual Testing**: User acceptance testing

### Testing Stack

**Frontend**:
- **Vitest**: Fast unit testing framework
- **Testing Library**: React component testing
- **MSW**: API mocking
- **Coverage**: v8 coverage reporter

**Backend**:
- **Go Testing**: Built-in `testing` package
- **Testify**: Assertions and mocks
- **httptest**: HTTP handler testing

---

## Frontend Testing

### Setup

Testing is configured in `frontend/vite.config.ts`:

```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'src/test/'],
    },
  },
});
```

### Running Tests

```bash
cd frontend

# Run all tests
npm run test

# Run in watch mode
npm run test:watch

# Run specific file
npm run test Button.test.tsx

# Generate coverage report
npm run test:coverage
```

### Unit Testing Components

#### Basic Component Test

```typescript
// src/components/ui/Button.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);

    await userEvent.click(screen.getByText('Click me'));

    expect(handleClick).toHaveBeenCalledOnce();
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>);
    expect(screen.getByText('Click me')).toBeDisabled();
  });

  it('applies variant classes', () => {
    render(<Button variant="destructive">Delete</Button>);
    expect(screen.getByText('Delete')).toHaveClass('bg-destructive');
  });
});
```

#### Testing Components with State

```typescript
// src/components/Counter.test.tsx
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Counter } from './Counter';

describe('Counter', () => {
  it('increments count when button clicked', async () => {
    render(<Counter />);

    const button = screen.getByRole('button', { name: /increment/i });
    expect(screen.getByText('Count: 0')).toBeInTheDocument();

    await userEvent.click(button);
    expect(screen.getByText('Count: 1')).toBeInTheDocument();

    await userEvent.click(button);
    expect(screen.getByText('Count: 2')).toBeInTheDocument();
  });
});
```

### Testing Hooks

```typescript
// src/hooks/useCounter.test.ts
import { describe, it, expect } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });

  it('initializes with custom value', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  it('increments count', () => {
    const { result } = renderHook(() => useCounter());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });

  it('decrements count', () => {
    const { result } = renderHook(() => useCounter(5));

    act(() => {
      result.current.decrement();
    });

    expect(result.current.count).toBe(4);
  });
});
```

### Testing Zustand Stores

```typescript
// src/store/useAppStore.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { useAppStore } from './useAppStore';

describe('useAppStore', () => {
  beforeEach(() => {
    // Reset store before each test
    useAppStore.setState({
      theme: 'auto',
      sidebarOpen: true,
    });
  });

  it('initializes with default state', () => {
    const state = useAppStore.getState();
    expect(state.theme).toBe('auto');
    expect(state.sidebarOpen).toBe(true);
  });

  it('sets theme', () => {
    useAppStore.getState().setTheme('dark');
    expect(useAppStore.getState().theme).toBe('dark');
  });

  it('toggles sidebar', () => {
    const initialState = useAppStore.getState().sidebarOpen;
    useAppStore.getState().toggleSidebar();
    expect(useAppStore.getState().sidebarOpen).toBe(!initialState);
  });
});
```

### Mocking API Calls

```typescript
// src/services/api.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { api } from './api';

// Mock fetch
global.fetch = vi.fn();

describe('API Client', () => {
  beforeEach(() => {
    vi.resetAllMocks();
  });

  it('makes GET request', async () => {
    const mockData = { id: 1, name: 'Test' };

    (global.fetch as any).mockResolvedValueOnce({
      ok: true,
      json: async () => mockData,
    });

    const result = await api.get('/test');

    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining('/test'),
      expect.objectContaining({ method: 'GET' })
    );
    expect(result).toEqual(mockData);
  });

  it('throws on error response', async () => {
    (global.fetch as any).mockResolvedValueOnce({
      ok: false,
      status: 404,
      statusText: 'Not Found',
    });

    await expect(api.get('/notfound')).rejects.toThrow('Request failed');
  });
});
```

### Mocking with MSW

```typescript
// src/test/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/models', () => {
    return HttpResponse.json([
      { id: '1', name: 'GPT-4o', provider: 'OpenAI' },
      { id: '2', name: 'Claude 3.5 Sonnet', provider: 'Anthropic' },
    ]);
  }),

  http.post('/api/providers', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: '1', ...body }, { status: 201 });
  }),
];

// src/test/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// src/test/setup.ts
import { beforeAll, afterEach, afterAll } from 'vitest';
import { server } from './mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

---

## Backend Testing

### Running Tests

```bash
cd backend

# Run all tests
go test ./...

# Run with verbose output
go test -v ./...

# Run specific package
go test ./internal/handlers

# Run with coverage
go test -cover ./...

# Generate HTML coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Unit Testing Functions

```go
// internal/utils/format_test.go
package utils

import (
    "testing"
)

func TestFormatMessage(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        {
            name:     "simple message",
            input:    "Hello",
            expected: "Hello",
        },
        {
            name:     "message with newlines",
            input:    "Hello\nWorld",
            expected: "Hello\nWorld",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := FormatMessage(tt.input)
            if result != tt.expected {
                t.Errorf("FormatMessage(%q) = %q, want %q", tt.input, result, tt.expected)
            }
        })
    }
}
```

### Testing HTTP Handlers

```go
// internal/handlers/health_test.go
package handlers

import (
    "net/http"
    "net/http/httptest"
    "testing"

    "github.com/gofiber/fiber/v2"
    "github.com/stretchr/testify/assert"
)

func TestHealthCheck(t *testing.T) {
    app := fiber.New()
    app.Get("/health", HealthCheck)

    req := httptest.NewRequest(http.MethodGet, "/health", nil)
    resp, err := app.Test(req)

    assert.NoError(t, err)
    assert.Equal(t, http.StatusOK, resp.StatusCode)
}
```

### Testing with Mock Database

```go
// internal/repositories/conversation_test.go
package repositories

import (
    "context"
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

// Mock MongoDB collection
type MockCollection struct {
    mock.Mock
}

func (m *MockCollection) InsertOne(ctx context.Context, document interface{}) (interface{}, error) {
    args := m.Called(ctx, document)
    return args.Get(0), args.Error(1)
}

func TestCreateConversation(t *testing.T) {
    mockColl := new(MockCollection)
    repo := NewConversationRepository(mockColl)

    conversation := &Conversation{
        ID:     "test-id",
        Title:  "Test Conversation",
        UserID: "user-123",
    }

    mockColl.On("InsertOne", mock.Anything, conversation).Return("test-id", nil)

    err := repo.Create(context.Background(), conversation)

    assert.NoError(t, err)
    mockColl.AssertExpectations(t)
}
```

### Testing Services

```go
// internal/services/chat_service_test.go
package services

import (
    "context"
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

type MockLLMClient struct {
    mock.Mock
}

func (m *MockLLMClient) SendMessage(ctx context.Context, messages []Message) (string, error) {
    args := m.Called(ctx, messages)
    return args.String(0), args.Error(1)
}

func TestChatService_SendMessage(t *testing.T) {
    mockClient := new(MockLLMClient)
    service := NewChatService(mockClient)

    messages := []Message{
        {Role: "user", Content: "Hello"},
    }

    mockClient.On("SendMessage", mock.Anything, messages).Return("Hi there!", nil)

    response, err := service.SendMessage(context.Background(), messages)

    assert.NoError(t, err)
    assert.Equal(t, "Hi there!", response)
    mockClient.AssertExpectations(t)
}
```

---

## E2E Testing

### Playwright Setup (Coming Soon)

```typescript
// e2e/chat.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Chat Interface', () => {
  test('should send and receive messages', async ({ page }) => {
    await page.goto('http://localhost:5173');

    // Login
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // Send message
    await page.fill('[placeholder="Type a message..."]', 'Hello, AI!');
    await page.press('[placeholder="Type a message..."]', 'Enter');

    // Wait for response
    await page.waitForSelector('text=Hello, AI!');
    await page.waitForSelector('[data-role="assistant"]');

    // Check response exists
    const response = await page.locator('[data-role="assistant"]').first();
    expect(await response.isVisible()).toBe(true);
  });
});
```

---

## Best Practices

### 1. Follow AAA Pattern

```typescript
it('should increment counter', () => {
  // Arrange
  render(<Counter initialValue={0} />);
  const button = screen.getByRole('button', { name: /increment/i });

  // Act
  userEvent.click(button);

  // Assert
  expect(screen.getByText('Count: 1')).toBeInTheDocument();
});
```

### 2. Test Behavior, Not Implementation

```typescript
// ✅ Good - Tests behavior
it('shows error when form is invalid', async () => {
  render(<LoginForm />);
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));
  expect(screen.getByText(/email is required/i)).toBeInTheDocument();
});

// ❌ Bad - Tests implementation
it('sets error state when form is invalid', () => {
  const { result } = renderHook(() => useLoginForm());
  act(() => {
    result.current.submit();
  });
  expect(result.current.errors.email).toBe('Email is required');
});
```

### 3. Use Descriptive Test Names

```typescript
// ✅ Good
describe('Button', () => {
  it('calls onClick handler when clicked', () => { /* ... */ });
  it('is disabled when disabled prop is true', () => { /* ... */ });
  it('renders loading spinner when loading prop is true', () => { /* ... */ });
});

// ❌ Bad
describe('Button', () => {
  it('works', () => { /* ... */ });
  it('test button', () => { /* ... */ });
});
```

### 4. Clean Up After Tests

```typescript
import { afterEach, vi } from 'vitest';
import { cleanup } from '@testing-library/react';

afterEach(() => {
  cleanup(); // Clean up React components
  vi.clearAllMocks(); // Clear all mocks
});
```

### 5. Don't Test Third-Party Libraries

```typescript
// ❌ Bad - Testing React Router
it('navigates to home page', () => {
  const { result } = renderHook(() => useNavigate());
  act(() => result.current('/'));
  // ...
});

// ✅ Good - Test your component's behavior
it('redirects to home after successful login', async () => {
  render(<LoginPage />);
  // ... login flow
  await waitFor(() => {
    expect(window.location.pathname).toBe('/');
  });
});
```

### 6. Use Test IDs Sparingly

```typescript
// ✅ Good - Use semantic queries
screen.getByRole('button', { name: /submit/i });
screen.getByLabelText(/email address/i);
screen.getByPlaceholderText(/enter your name/i);

// ⚠️ Acceptable - When semantic queries don't work
screen.getByTestId('custom-widget');

// ❌ Bad - Overusing test IDs
screen.getByTestId('submit-button');
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install dependencies
        run: cd frontend && npm ci

      - name: Run tests
        run: cd frontend && npm run test:run

      - name: Generate coverage
        run: cd frontend && npm run test:coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./frontend/coverage/coverage-final.json

  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.24'

      - name: Run tests
        run: cd backend && go test -v -cover ./...
```

### Coverage Requirements

Set minimum coverage thresholds:

```json
// frontend/package.json
{
  "scripts": {
    "test:coverage": "vitest run --coverage"
  },
  "vitest": {
    "coverage": {
      "thresholds": {
        "lines": 80,
        "functions": 80,
        "branches": 75,
        "statements": 80
      }
    }
  }
}
```

---

## Debugging Tests

### Frontend

```bash
# Run tests in debug mode
npm run test -- --inspect-brk

# Run specific test file in watch mode
npm run test -- Button.test.tsx --watch

# Show more detailed output
npm run test -- --reporter=verbose
```

### Backend

```bash
# Run with race detector
go test -race ./...

# Run with verbose output
go test -v ./internal/handlers

# Run specific test
go test -run TestHealthCheck ./internal/handlers
```

---

## Resources

- [Vitest Documentation](https://vitest.dev/)
- [Testing Library](https://testing-library.com/)
- [Go Testing](https://golang.org/pkg/testing/)
- [Testify](https://github.com/stretchr/testify)
- [Playwright](https://playwright.dev/)

---

**Need help?** Ask in [Discord](https://discord.com/invite/j633fsrAne) or see [CONTRIBUTING.md](../CONTRIBUTING.md).
