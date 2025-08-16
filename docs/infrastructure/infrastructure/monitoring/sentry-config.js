// Sentry Configuration for Pulse Trading
// Production-ready error tracking and performance monitoring

import * as Sentry from '@sentry/browser';
import { Integrations } from '@sentry/tracing';

const ENVIRONMENT = process.env.NODE_ENV || 'development';
const RELEASE = process.env.REACT_APP_VERSION || 'unknown';
const DSN = process.env.REACT_APP_SENTRY_DSN;

// Initialize Sentry with comprehensive configuration
export function initSentry() {
  if (!DSN) {
    console.warn('Sentry DSN not configured');
    return;
  }

  Sentry.init({
    dsn: DSN,
    environment: ENVIRONMENT,
    release: RELEASE,
    
    // Integrations for enhanced monitoring
    integrations: [
      new Integrations.BrowserTracing({
        // Performance monitoring for navigation
        routingInstrumentation: Sentry.reactRouterV6Instrumentation(
          React.useEffect,
          useLocation,
          useNavigationType,
          createRoutesFromChildren,
          matchRoutes
        ),
        
        // Capture user interactions
        tracingOrigins: [
          'pulse-trading.com',
          'api.alpaca.markets',
          /^https:\/\/.*\.supabase\.co/,
          /^https:\/\/.*\.googleapis\.com/,
        ],
      }),
      
      // Capture console errors and warnings
      new Sentry.Integrations.CaptureConsole({
        levels: ['error', 'warn'],
      }),
      
      // HTTP breadcrumbs
      new Sentry.Integrations.Http({
        breadcrumbs: true,
        tracing: true,
      }),
      
      // Local storage breadcrumbs
      new Sentry.Integrations.LocalVariables({
        captureAllExceptions: true,
      }),
    ],

    // Performance monitoring
    tracesSampleRate: ENVIRONMENT === 'production' ? 0.1 : 1.0,
    tracePropagationTargets: [
      'pulse-trading.com',
      'api.alpaca.markets',
      /^https:\/\/.*\.supabase\.co/,
    ],

    // Error sampling
    sampleRate: ENVIRONMENT === 'production' ? 0.2 : 1.0,

    // Performance thresholds
    beforeSend(event, hint) {
      // Filter out development errors
      if (ENVIRONMENT === 'development' && event.exception) {
        const error = hint.originalException;
        if (error && error.message && error.message.includes('ResizeObserver')) {
          return null; // Skip ResizeObserver errors in development
        }
      }

      // Add custom context
      event.contexts = {
        ...event.contexts,
        app: {
          name: 'Pulse Trading',
          version: RELEASE,
          build_type: 'flutter_web',
        },
        device: {
          screen_resolution: `${window.screen.width}x${window.screen.height}`,
          viewport: `${window.innerWidth}x${window.innerHeight}`,
          pixel_ratio: window.devicePixelRatio,
        },
      };

      return event;
    },

    beforeSendTransaction(event) {
      // Filter out noisy transactions
      if (event.transaction?.includes('heartbeat') || 
          event.transaction?.includes('ping')) {
        return null;
      }
      
      return event;
    },

    // Custom fingerprinting for better error grouping
    beforeBreadcrumb(breadcrumb) {
      // Filter sensitive data from breadcrumbs
      if (breadcrumb.category === 'http') {
        const url = breadcrumb.data?.url || '';
        if (url.includes('api_key') || url.includes('token')) {
          breadcrumb.data.url = url.replace(/([?&])(api_key|token)=[^&]*/gi, '$1$2=[REDACTED]');
        }
      }
      
      return breadcrumb;
    },

    // Custom tags
    initialScope: {
      tags: {
        component: 'web_app',
        framework: 'flutter',
        renderer: 'canvaskit',
      },
    },
  });

  // Set user context
  Sentry.configureScope((scope) => {
    scope.setContext('runtime', {
      name: 'Flutter Web',
      version: '3.24.0',
    });
  });
}

// Custom error reporting utilities
export const reportError = (error, context = {}) => {
  Sentry.withScope((scope) => {
    Object.keys(context).forEach(key => {
      scope.setExtra(key, context[key]);
    });
    Sentry.captureException(error);
  });
};

export const reportMessage = (message, level = 'info', context = {}) => {
  Sentry.withScope((scope) => {
    scope.setLevel(level);
    Object.keys(context).forEach(key => {
      scope.setExtra(key, context[key]);
    });
    Sentry.captureMessage(message);
  });
};

// Performance monitoring utilities
export const startTransaction = (name, operation = 'navigation') => {
  return Sentry.startTransaction({
    name,
    op: operation,
  });
};

export const addBreadcrumb = (message, category = 'custom', level = 'info', data = {}) => {
  Sentry.addBreadcrumb({
    message,
    category,
    level,
    data,
    timestamp: Date.now() / 1000,
  });
};

// Trading-specific error tracking
export const reportTradingError = (error, symbol, action, context = {}) => {
  Sentry.withScope((scope) => {
    scope.setTag('error_type', 'trading');
    scope.setTag('symbol', symbol);
    scope.setTag('action', action);
    scope.setContext('trading', {
      symbol,
      action,
      timestamp: new Date().toISOString(),
      ...context,
    });
    Sentry.captureException(error);
  });
};

// API error tracking
export const reportApiError = (error, endpoint, method, statusCode) => {
  Sentry.withScope((scope) => {
    scope.setTag('error_type', 'api');
    scope.setTag('endpoint', endpoint);
    scope.setTag('method', method);
    scope.setTag('status_code', statusCode);
    scope.setContext('api', {
      endpoint,
      method,
      statusCode,
      timestamp: new Date().toISOString(),
    });
    Sentry.captureException(error);
  });
};

// Performance timing utilities
export const measurePerformance = (name, fn) => {
  const transaction = startTransaction(name, 'function');
  const start = performance.now();
  
  try {
    const result = fn();
    
    // Handle async functions
    if (result && typeof result.then === 'function') {
      return result
        .then(value => {
          const duration = performance.now() - start;
          transaction.setMeasurement('duration', duration, 'millisecond');
          transaction.finish();
          return value;
        })
        .catch(error => {
          reportError(error, { function: name, duration: performance.now() - start });
          transaction.finish();
          throw error;
        });
    }
    
    // Handle sync functions
    const duration = performance.now() - start;
    transaction.setMeasurement('duration', duration, 'millisecond');
    transaction.finish();
    return result;
    
  } catch (error) {
    reportError(error, { function: name, duration: performance.now() - start });
    transaction.finish();
    throw error;
  }
};

// User identification
export const setUser = (userId, email, subscription = null) => {
  Sentry.setUser({
    id: userId,
    email,
    subscription,
  });
};

// Custom metrics for business logic
export const recordMetric = (name, value, unit = 'none', tags = {}) => {
  Sentry.addBreadcrumb({
    message: `Metric: ${name}`,
    category: 'metric',
    level: 'info',
    data: {
      metric_name: name,
      value,
      unit,
      tags,
      timestamp: Date.now(),
    },
  });
};

// Export configuration for external use
export const sentryConfig = {
  environment: ENVIRONMENT,
  release: RELEASE,
  dsn: DSN,
  initialized: !!DSN,
};