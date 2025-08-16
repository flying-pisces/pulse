// GDPR Compliance Module for Pulse Trading
// Comprehensive data protection and privacy management

class GDPRCompliance {
  constructor(config = {}) {
    this.config = {
      cookieConsentRequired: true,
      dataRetentionDays: 1095, // 3 years
      consentCookieName: 'pulse_consent',
      consentVersion: '1.0',
      privacyPolicyUrl: '/privacy-policy',
      cookiePolicyUrl: '/cookie-policy',
      ...config
    };
    
    this.consentCategories = {
      necessary: {
        name: 'Strictly Necessary',
        description: 'These cookies are essential for the website to function properly.',
        required: true,
        cookies: ['session', 'csrf_token', 'auth_token']
      },
      analytics: {
        name: 'Analytics & Performance',
        description: 'These cookies help us understand how visitors interact with our website.',
        required: false,
        cookies: ['_ga', '_gid', '_gat', 'sentry_session']
      },
      functional: {
        name: 'Functional',
        description: 'These cookies enable enhanced functionality and personalization.',
        required: false,
        cookies: ['user_preferences', 'theme', 'language']
      },
      marketing: {
        name: 'Marketing & Advertising',
        description: 'These cookies are used to deliver relevant advertisements.',
        required: false,
        cookies: ['marketing_id', 'ad_tracking']
      }
    };

    this.init();
  }

  init() {
    this.loadConsentState();
    this.createConsentBanner();
    this.bindEventListeners();
    this.setupDataProtectionHandlers();
  }

  // Consent Management
  loadConsentState() {
    const consentCookie = this.getCookie(this.config.consentCookieName);
    
    if (consentCookie) {
      try {
        this.consentState = JSON.parse(decodeURIComponent(consentCookie));
        
        // Check if consent version matches
        if (this.consentState.version !== this.config.consentVersion) {
          this.showConsentBanner();
        } else {
          this.applyConsent();
        }
      } catch (error) {
        console.error('Error parsing consent cookie:', error);
        this.showConsentBanner();
      }
    } else {
      this.showConsentBanner();
    }
  }

  saveConsentState() {
    const consentData = {
      version: this.config.consentVersion,
      timestamp: Date.now(),
      consent: this.consentState.consent,
      ip: this.getClientIP(),
      userAgent: navigator.userAgent
    };

    const cookieValue = encodeURIComponent(JSON.stringify(consentData));
    const expiryDate = new Date();
    expiryDate.setFullYear(expiryDate.getFullYear() + 1);

    document.cookie = `${this.config.consentCookieName}=${cookieValue}; expires=${expiryDate.toUTCString()}; path=/; secure; samesite=strict`;
    
    // Store consent record for audit purposes
    this.auditConsentChange(consentData);
  }

  showConsentBanner() {
    if (document.getElementById('gdpr-consent-banner')) return;

    const banner = document.createElement('div');
    banner.id = 'gdpr-consent-banner';
    banner.innerHTML = this.generateConsentBannerHTML();
    banner.style.cssText = this.getConsentBannerCSS();

    document.body.appendChild(banner);
    
    // Add event listeners to banner buttons
    this.bindConsentBannerEvents();
  }

  generateConsentBannerHTML() {
    return `
      <div class="consent-banner-content">
        <div class="consent-banner-text">
          <h3>We value your privacy</h3>
          <p>We use cookies and similar technologies to provide the best experience on our website. 
          Some are necessary for the site to work, while others help us improve our services and your experience.</p>
        </div>
        <div class="consent-banner-actions">
          <button id="accept-all-cookies" class="btn-primary">Accept All</button>
          <button id="reject-all-cookies" class="btn-secondary">Reject All</button>
          <button id="customize-cookies" class="btn-link">Customize Settings</button>
        </div>
      </div>
      <div class="consent-banner-links">
        <a href="${this.config.privacyPolicyUrl}" target="_blank">Privacy Policy</a>
        <a href="${this.config.cookiePolicyUrl}" target="_blank">Cookie Policy</a>
      </div>
    `;
  }

  showConsentModal() {
    if (document.getElementById('gdpr-consent-modal')) return;

    const modal = document.createElement('div');
    modal.id = 'gdpr-consent-modal';
    modal.innerHTML = this.generateConsentModalHTML();
    modal.style.cssText = this.getConsentModalCSS();

    document.body.appendChild(modal);
    this.bindConsentModalEvents();
  }

  generateConsentModalHTML() {
    const categoriesHTML = Object.entries(this.consentCategories)
      .map(([key, category]) => `
        <div class="consent-category">
          <div class="consent-category-header">
            <h4>${category.name}</h4>
            <label class="consent-toggle">
              <input type="checkbox" id="consent-${key}" ${category.required ? 'checked disabled' : ''}>
              <span class="toggle-slider"></span>
            </label>
          </div>
          <p class="consent-category-description">${category.description}</p>
          <details class="consent-category-details">
            <summary>View Cookies</summary>
            <ul>
              ${category.cookies.map(cookie => `<li>${cookie}</li>`).join('')}
            </ul>
          </details>
        </div>
      `).join('');

    return `
      <div class="consent-modal-overlay">
        <div class="consent-modal">
          <div class="consent-modal-header">
            <h2>Cookie Preferences</h2>
            <button id="close-consent-modal" class="close-button">&times;</button>
          </div>
          <div class="consent-modal-content">
            <p>Manage your cookie preferences below. You can enable or disable different types of cookies. 
            Note that blocking some types of cookies may impact your experience of the site.</p>
            
            <div class="consent-categories">
              ${categoriesHTML}
            </div>
          </div>
          <div class="consent-modal-actions">
            <button id="save-consent-preferences" class="btn-primary">Save Preferences</button>
            <button id="accept-all-modal" class="btn-secondary">Accept All</button>
          </div>
        </div>
      </div>
    `;
  }

  bindConsentBannerEvents() {
    document.getElementById('accept-all-cookies')?.addEventListener('click', () => {
      this.acceptAllCookies();
    });

    document.getElementById('reject-all-cookies')?.addEventListener('click', () => {
      this.rejectAllCookies();
    });

    document.getElementById('customize-cookies')?.addEventListener('click', () => {
      this.showConsentModal();
    });
  }

  bindConsentModalEvents() {
    document.getElementById('close-consent-modal')?.addEventListener('click', () => {
      this.closeConsentModal();
    });

    document.getElementById('save-consent-preferences')?.addEventListener('click', () => {
      this.saveCustomConsent();
    });

    document.getElementById('accept-all-modal')?.addEventListener('click', () => {
      this.acceptAllCookiesFromModal();
    });

    // Close modal when clicking outside
    document.getElementById('gdpr-consent-modal')?.addEventListener('click', (e) => {
      if (e.target.className === 'consent-modal-overlay') {
        this.closeConsentModal();
      }
    });
  }

  acceptAllCookies() {
    this.consentState = {
      consent: Object.keys(this.consentCategories).reduce((acc, key) => {
        acc[key] = true;
        return acc;
      }, {}),
      timestamp: Date.now()
    };

    this.saveConsentState();
    this.applyConsent();
    this.hideConsentBanner();
    this.trackConsentEvent('accept_all');
  }

  rejectAllCookies() {
    this.consentState = {
      consent: Object.keys(this.consentCategories).reduce((acc, key) => {
        acc[key] = this.consentCategories[key].required;
        return acc;
      }, {}),
      timestamp: Date.now()
    };

    this.saveConsentState();
    this.applyConsent();
    this.hideConsentBanner();
    this.trackConsentEvent('reject_all');
  }

  saveCustomConsent() {
    const consent = {};
    Object.keys(this.consentCategories).forEach(key => {
      const checkbox = document.getElementById(`consent-${key}`);
      consent[key] = checkbox ? checkbox.checked : this.consentCategories[key].required;
    });

    this.consentState = { consent, timestamp: Date.now() };
    this.saveConsentState();
    this.applyConsent();
    this.closeConsentModal();
    this.hideConsentBanner();
    this.trackConsentEvent('custom', consent);
  }

  applyConsent() {
    if (!this.consentState?.consent) return;

    // Enable/disable analytics
    if (this.consentState.consent.analytics) {
      this.enableGoogleAnalytics();
      this.enableSentry();
    } else {
      this.disableGoogleAnalytics();
      this.disableSentry();
    }

    // Enable/disable functional cookies
    if (!this.consentState.consent.functional) {
      this.clearFunctionalCookies();
    }

    // Enable/disable marketing cookies
    if (!this.consentState.consent.marketing) {
      this.clearMarketingCookies();
    }

    // Fire consent update event
    this.fireConsentEvent();
  }

  // Data Subject Rights Implementation
  initiateDataExport(userId, email) {
    return new Promise((resolve, reject) => {
      const exportRequest = {
        userId,
        email,
        requestDate: new Date().toISOString(),
        status: 'pending',
        requestType: 'data_export'
      };

      // Store request for processing
      this.storeDataRequest(exportRequest)
        .then(() => {
          // Trigger background job for data collection
          this.triggerDataExportJob(userId);
          resolve({ requestId: this.generateRequestId(), estimatedCompletion: '30 days' });
        })
        .catch(reject);
    });
  }

  initiateDataDeletion(userId, email, reason = '') {
    return new Promise((resolve, reject) => {
      const deletionRequest = {
        userId,
        email,
        reason,
        requestDate: new Date().toISOString(),
        status: 'pending',
        requestType: 'data_deletion'
      };

      this.storeDataRequest(deletionRequest)
        .then(() => {
          // Start deletion process
          this.triggerDataDeletionJob(userId);
          resolve({ requestId: this.generateRequestId(), estimatedCompletion: '30 days' });
        })
        .catch(reject);
    });
  }

  requestDataRectification(userId, email, incorrectData, correctData) {
    return new Promise((resolve, reject) => {
      const rectificationRequest = {
        userId,
        email,
        incorrectData,
        correctData,
        requestDate: new Date().toISOString(),
        status: 'pending',
        requestType: 'data_rectification'
      };

      this.storeDataRequest(rectificationRequest)
        .then(() => {
          resolve({ requestId: this.generateRequestId(), estimatedCompletion: '7 days' });
        })
        .catch(reject);
    });
  }

  // Data Processing Lawfulness
  recordProcessingPurpose(userId, purpose, legalBasis, data, retention) {
    const record = {
      userId,
      purpose,
      legalBasis, // 'consent', 'contract', 'legal_obligation', 'legitimate_interest'
      dataCategories: data,
      retentionPeriod: retention,
      recordDate: new Date().toISOString()
    };

    return this.storeProcessingRecord(record);
  }

  // Audit and Logging
  auditConsentChange(consentData) {
    const auditRecord = {
      type: 'consent_change',
      timestamp: Date.now(),
      userId: this.getCurrentUserId(),
      sessionId: this.getSessionId(),
      consent: consentData,
      ipAddress: this.getClientIP(),
      userAgent: navigator.userAgent
    };

    this.sendAuditLog(auditRecord);
  }

  auditDataAccess(userId, dataType, purpose) {
    const auditRecord = {
      type: 'data_access',
      timestamp: Date.now(),
      userId,
      dataType,
      purpose,
      accessor: this.getCurrentUserId(),
      ipAddress: this.getClientIP()
    };

    this.sendAuditLog(auditRecord);
  }

  // Utility Methods
  getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(';').shift();
  }

  deleteCookie(name) {
    document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/`;
  }

  getClientIP() {
    // This would typically be handled server-side
    // Client-side IP detection is not reliable
    return 'unknown';
  }

  getCurrentUserId() {
    // Get current user ID from authentication system
    return localStorage.getItem('user_id') || 'anonymous';
  }

  getSessionId() {
    return sessionStorage.getItem('session_id') || 'no_session';
  }

  generateRequestId() {
    return 'req_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }

  // Event Tracking (Privacy-Compliant)
  trackConsentEvent(action, consent = null) {
    if (this.consentState?.consent?.analytics) {
      const eventData = {
        event: 'gdpr_consent',
        action,
        timestamp: Date.now()
      };

      if (consent) {
        eventData.consent_categories = Object.keys(consent).filter(key => consent[key]);
      }

      // Send to analytics (only if consent given)
      this.sendAnalyticsEvent(eventData);
    }
  }

  fireConsentEvent() {
    const event = new CustomEvent('gdprConsent', {
      detail: {
        consent: this.consentState.consent,
        timestamp: this.consentState.timestamp
      }
    });
    
    window.dispatchEvent(event);
  }

  // CSS Styles
  getConsentBannerCSS() {
    return `
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      background: #1a1a1a;
      color: white;
      padding: 20px;
      z-index: 10000;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      box-shadow: 0 -2px 10px rgba(0,0,0,0.2);
    `;
  }

  getConsentModalCSS() {
    return `
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      z-index: 10001;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    `;
  }

  // Cleanup
  hideConsentBanner() {
    const banner = document.getElementById('gdpr-consent-banner');
    if (banner) banner.remove();
  }

  closeConsentModal() {
    const modal = document.getElementById('gdpr-consent-modal');
    if (modal) modal.remove();
  }

  // Public API Methods
  hasConsent(category) {
    return this.consentState?.consent?.[category] || false;
  }

  updateConsent(category, granted) {
    if (!this.consentState) this.consentState = { consent: {} };
    this.consentState.consent[category] = granted;
    this.consentState.timestamp = Date.now();
    this.saveConsentState();
    this.applyConsent();
  }

  getConsentStatus() {
    return this.consentState?.consent || {};
  }

  resetConsent() {
    this.deleteCookie(this.config.consentCookieName);
    this.consentState = null;
    this.showConsentBanner();
  }
}

// Initialize GDPR compliance when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.gdprCompliance = new GDPRCompliance({
    cookieConsentRequired: true,
    dataRetentionDays: 1095,
    privacyPolicyUrl: 'https://pulse-trading.com/privacy-policy',
    cookiePolicyUrl: 'https://pulse-trading.com/cookie-policy'
  });
});

export default GDPRCompliance;