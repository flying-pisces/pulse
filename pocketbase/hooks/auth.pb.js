/// <reference path="../pb_data/types.d.ts" />

/**
 * Authentication hooks for Pulse trading signals app
 * Handles user registration, login, and OAuth integration
 */

onRecordAfterCreateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'users') {
    return
  }
  
  console.log('New user registered:', record.email)
  
  // Set default subscription tier if not provided
  if (!record.subscriptionTier) {
    record.set('subscriptionTier', 'free')
  }
  
  // Set verification status for OAuth users
  if (record.authProvider && record.authProvider !== 'email') {
    record.set('isVerified', true)
  }
  
  // Set default subscription expiry for free tier (no expiry)
  if (record.subscriptionTier === 'free') {
    record.set('subscriptionExpiresAt', null)
  }
  
  try {
    $app.dao().saveRecord(record)
    console.log('User defaults set for:', record.email)
  } catch (err) {
    console.error('Failed to set user defaults:', err.message)
  }
}, 'users')

onRecordAfterAuthWithOAuth2Request((e) => {
  const record = e.record
  const auth = e.auth
  
  console.log('OAuth authentication successful:', record.email, 'Provider:', auth.provider)
  
  // Update user data from OAuth provider
  try {
    // Google OAuth
    if (auth.provider === 'google') {
      if (auth.rawUser?.name && !record.firstName && !record.lastName) {
        const nameParts = auth.rawUser.name.split(' ')
        record.set('firstName', nameParts[0] || '')
        record.set('lastName', nameParts.slice(1).join(' ') || '')
      }
      
      if (auth.rawUser?.picture && !record.profileImageUrl) {
        record.set('profileImageUrl', auth.rawUser.picture)
      }
      
      if (auth.rawUser?.email_verified) {
        record.set('isVerified', true)
      }
    }
    
    // Apple OAuth
    if (auth.provider === 'apple') {
      if (auth.rawUser?.name && !record.firstName && !record.lastName) {
        if (auth.rawUser.name.firstName) {
          record.set('firstName', auth.rawUser.name.firstName)
        }
        if (auth.rawUser.name.lastName) {
          record.set('lastName', auth.rawUser.name.lastName)
        }
      }
      
      // Apple users are always verified
      record.set('isVerified', true)
    }
    
    // Store provider-specific data
    record.set('authProvider', auth.provider)
    record.set('providerId', auth.rawUser?.id || auth.rawUser?.sub)
    record.set('providerData', JSON.stringify(auth.rawUser))
    
    $app.dao().saveRecord(record)
    console.log('OAuth user data updated for:', record.email)
    
  } catch (err) {
    console.error('Failed to update OAuth user data:', err.message)
  }
}, 'users')

onRecordBeforeAuthWithPasswordRequest((e) => {
  const identity = e.identity
  const password = e.password
  
  console.log('Password authentication attempt for:', identity)
  
  // Add rate limiting for failed attempts
  // This is a basic implementation - in production, use Redis or similar
  const maxAttempts = 5
  const lockoutDuration = 15 * 60 * 1000 // 15 minutes
  
  // Note: In a real implementation, you'd want to store failed attempts
  // in a persistent cache like Redis to survive server restarts
}, 'users')

onRecordAfterAuthWithPasswordRequest((e) => {
  const record = e.record
  
  console.log('Password authentication successful for:', record.email)
  
  // Update last login timestamp
  try {
    const now = new Date().toISOString()
    record.set('lastLoginAt', now)
    $app.dao().saveRecord(record)
  } catch (err) {
    console.error('Failed to update last login:', err.message)
  }
}, 'users')

onRecordBeforeUpdateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'users') {
    return
  }
  
  // Validate subscription tier changes
  const oldTier = record.originalCopy().subscriptionTier
  const newTier = record.subscriptionTier
  
  if (oldTier !== newTier) {
    console.log('Subscription tier change:', record.email, oldTier, '->', newTier)
    
    // Set appropriate expiry date for paid tiers
    if (newTier !== 'free' && !record.subscriptionExpiresAt) {
      // Default to 30 days from now for new subscriptions
      const expiryDate = new Date()
      expiryDate.setDate(expiryDate.getDate() + 30)
      record.set('subscriptionExpiresAt', expiryDate.toISOString())
    }
    
    // Clear expiry for free tier
    if (newTier === 'free') {
      record.set('subscriptionExpiresAt', null)
    }
  }
  
  // Validate email changes
  const oldEmail = record.originalCopy().email
  const newEmail = record.email
  
  if (oldEmail !== newEmail) {
    console.log('Email change requested:', oldEmail, '->', newEmail)
    // Reset verification status for email changes
    record.set('isVerified', false)
  }
}, 'users')

onRecordAfterUpdateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'users') {
    return
  }
  
  console.log('User profile updated:', record.email)
  
  // Log significant changes
  const changes = []
  const original = record.originalCopy()
  
  if (original.subscriptionTier !== record.subscriptionTier) {
    changes.push(`subscription: ${original.subscriptionTier} -> ${record.subscriptionTier}`)
  }
  
  if (original.isVerified !== record.isVerified) {
    changes.push(`verified: ${original.isVerified} -> ${record.isVerified}`)
  }
  
  if (changes.length > 0) {
    console.log('User changes for', record.email + ':', changes.join(', '))
  }
}, 'users')

// Password reset hook
onRecordBeforeRequestPasswordResetRequest((e) => {
  const email = e.email
  
  console.log('Password reset requested for:', email)
  
  // Add rate limiting for password reset requests
  // In production, implement proper rate limiting
}, 'users')

onRecordAfterRequestPasswordResetRequest((e) => {
  const record = e.record
  
  console.log('Password reset email sent to:', record.email)
  
  // Log password reset for security audit
  // In production, you might want to log this to a security audit system
}, 'users')

onRecordBeforeConfirmPasswordResetRequest((e) => {
  const token = e.token
  const password = e.password
  
  console.log('Password reset confirmation attempt with token')
  
  // Validate password strength
  if (password.length < 8) {
    throw new BadRequestError('Password must be at least 8 characters long')
  }
  
  // Add more password validation rules as needed
  const hasUpperCase = /[A-Z]/.test(password)
  const hasLowerCase = /[a-z]/.test(password)
  const hasNumbers = /\d/.test(password)
  const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password)
  
  if (!hasUpperCase || !hasLowerCase || !hasNumbers || !hasSpecialChar) {
    throw new BadRequestError('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character')
  }
}, 'users')

onRecordAfterConfirmPasswordResetRequest((e) => {
  const record = e.record
  
  console.log('Password reset completed for:', record.email)
  
  // Invalidate all existing auth tokens for security
  // Note: This is automatically handled by PocketBase
}, 'users')

// Email verification hooks
onRecordBeforeRequestVerificationRequest((e) => {
  const email = e.email
  
  console.log('Email verification requested for:', email)
}, 'users')

onRecordAfterRequestVerificationRequest((e) => {
  const record = e.record
  
  console.log('Verification email sent to:', record.email)
}, 'users')

onRecordAfterConfirmVerificationRequest((e) => {
  const record = e.record
  
  console.log('Email verification completed for:', record.email)
  
  // Set verification status
  record.set('isVerified', true)
  
  try {
    $app.dao().saveRecord(record)
  } catch (err) {
    console.error('Failed to update verification status:', err.message)
  }
}, 'users')