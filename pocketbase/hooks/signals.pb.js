/// <reference path="../pb_data/types.d.ts" />

/**
 * Signals hooks for Pulse trading signals app
 * Handles signal creation, updates, and subscription tier validation
 */

onRecordBeforeCreateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signals') {
    return
  }
  
  console.log('Creating new signal:', record.symbol)
  
  // Validate signal data
  validateSignalData(record)
  
  // Set default values
  if (!record.status) {
    record.set('status', 'active')
  }
  
  if (!record.requiredTier) {
    record.set('requiredTier', 'free')
  }
  
  // Parse and validate tags
  if (record.tags) {
    try {
      const tags = typeof record.tags === 'string' ? JSON.parse(record.tags) : record.tags
      if (Array.isArray(tags)) {
        record.set('tags', JSON.stringify(tags))
      } else {
        record.set('tags', JSON.stringify([]))
      }
    } catch (err) {
      record.set('tags', JSON.stringify([]))
    }
  } else {
    record.set('tags', JSON.stringify([]))
  }
  
  // Set expiry date if not provided (default 7 days for active signals)
  if (!record.expiresAt && record.status === 'active') {
    const expiryDate = new Date()
    expiryDate.setDate(expiryDate.getDate() + 7)
    record.set('expiresAt', expiryDate.toISOString())
  }
}, 'signals')

onRecordAfterCreateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signals') {
    return
  }
  
  console.log('Signal created successfully:', record.symbol, record.id)
  
  // Log signal creation for analytics
  logSignalEvent('signal_created', record)
  
  // Send real-time notification to subscribers
  // Note: This would integrate with your notification system
  notifySubscribers('signal_created', record)
}, 'signals')

onRecordBeforeUpdateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signals') {
    return
  }
  
  console.log('Updating signal:', record.symbol, record.id)
  
  // Validate signal data
  validateSignalData(record)
  
  // Check for status changes
  const oldStatus = record.originalCopy().status
  const newStatus = record.status
  
  if (oldStatus !== newStatus) {
    console.log('Signal status change:', record.symbol, oldStatus, '->', newStatus)
    
    // Set profit/loss when signal is completed
    if (newStatus === 'completed' && record.currentPrice && record.targetPrice) {
      const profitLoss = ((record.currentPrice - record.targetPrice) / record.targetPrice) * 100
      record.set('profitLossPercentage', profitLoss)
    }
    
    // Clear expiry when signal is completed or cancelled
    if (newStatus === 'completed' || newStatus === 'cancelled') {
      record.set('expiresAt', null)
    }
  }
  
  // Update expiry date if status changed to active
  if (newStatus === 'active' && !record.expiresAt) {
    const expiryDate = new Date()
    expiryDate.setDate(expiryDate.getDate() + 7)
    record.set('expiresAt', expiryDate.toISOString())
  }
  
  // Handle tags
  if (record.tags) {
    try {
      const tags = typeof record.tags === 'string' ? JSON.parse(record.tags) : record.tags
      if (Array.isArray(tags)) {
        record.set('tags', JSON.stringify(tags))
      }
    } catch (err) {
      console.error('Invalid tags format for signal:', record.id)
    }
  }
}, 'signals')

onRecordAfterUpdateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signals') {
    return
  }
  
  console.log('Signal updated successfully:', record.symbol, record.id)
  
  // Log signal update for analytics
  logSignalEvent('signal_updated', record)
  
  // Check for significant changes to notify subscribers
  const original = record.originalCopy()
  const significantChanges = []
  
  if (original.status !== record.status) {
    significantChanges.push(`status: ${original.status} -> ${record.status}`)
  }
  
  if (original.targetPrice !== record.targetPrice) {
    significantChanges.push(`target: ${original.targetPrice} -> ${record.targetPrice}`)
  }
  
  if (original.stopLoss !== record.stopLoss) {
    significantChanges.push(`stop_loss: ${original.stopLoss} -> ${record.stopLoss}`)
  }
  
  if (significantChanges.length > 0) {
    console.log('Significant signal changes:', record.symbol, significantChanges.join(', '))
    notifySubscribers('signal_updated', record, significantChanges)
  }
}, 'signals')

onRecordBeforeDeleteRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signals') {
    return
  }
  
  console.log('Deleting signal:', record.symbol, record.id)
  
  // Log signal deletion
  logSignalEvent('signal_deleted', record)
}, 'signals')

onRecordViewRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signals') {
    return
  }
  
  // Check subscription tier access
  const authRecord = e.auth
  if (!authRecord) {
    throw new UnauthorizedError('Authentication required')
  }
  
  // Check if user has access to this signal tier
  if (!hasSubscriptionAccess(authRecord, record.requiredTier)) {
    throw new ForbiddenError('Subscription upgrade required to view this signal')
  }
  
  // Log signal view for analytics (optional)
  // logSignalEvent('signal_viewed', record, { user_id: authRecord.id })
}, 'signals')

onRecordsListRequest((e) => {
  if (e.collection.name !== 'signals') {
    return
  }
  
  const authRecord = e.auth
  if (!authRecord) {
    throw new UnauthorizedError('Authentication required')
  }
  
  // Add subscription tier filter to the query
  const userTier = authRecord.subscriptionTier || 'free'
  const allowedTiers = getAllowedTiers(userTier)
  
  // Modify the filter to include subscription tier restriction
  let filter = e.filter
  const tierFilter = `requiredTier in ("${allowedTiers.join('", "')}")`
  
  if (filter) {
    e.filter = `(${filter}) && (${tierFilter})`
  } else {
    e.filter = tierFilter
  }
  
  console.log('Signals list request for user:', authRecord.email, 'tier:', userTier, 'filter:', e.filter)
}, 'signals')

// Utility functions

function validateSignalData(record) {
  // Validate required fields
  const requiredFields = ['symbol', 'companyName', 'type', 'action', 'currentPrice', 'targetPrice', 'stopLoss', 'confidence', 'reasoning']
  
  for (const field of requiredFields) {
    if (!record[field]) {
      throw new BadRequestError(`Field '${field}' is required`)
    }
  }
  
  // Validate symbol format
  if (!/^[A-Z0-9]+$/.test(record.symbol)) {
    throw new BadRequestError('Symbol must contain only uppercase letters and numbers')
  }
  
  // Validate price fields
  if (record.currentPrice <= 0 || record.targetPrice <= 0 || record.stopLoss <= 0) {
    throw new BadRequestError('Price fields must be positive numbers')
  }
  
  // Validate confidence
  if (record.confidence < 0 || record.confidence > 1) {
    throw new BadRequestError('Confidence must be between 0 and 1')
  }
  
  // Validate signal logic
  if (record.action === 'buy') {
    if (record.targetPrice <= record.currentPrice) {
      throw new BadRequestError('For buy signals, target price must be higher than current price')
    }
    if (record.stopLoss >= record.currentPrice) {
      throw new BadRequestError('For buy signals, stop loss must be lower than current price')
    }
  } else if (record.action === 'sell') {
    if (record.targetPrice >= record.currentPrice) {
      throw new BadRequestError('For sell signals, target price must be lower than current price')
    }
    if (record.stopLoss <= record.currentPrice) {
      throw new BadRequestError('For sell signals, stop loss must be higher than current price')
    }
  }
  
  // Validate reasoning length
  if (record.reasoning.length < 10) {
    throw new BadRequestError('Reasoning must be at least 10 characters long')
  }
  
  if (record.reasoning.length > 2000) {
    throw new BadRequestError('Reasoning must be no more than 2000 characters long')
  }
}

function hasSubscriptionAccess(user, requiredTier) {
  const tierHierarchy = {
    'free': 0,
    'basic': 1,
    'premium': 2,
    'pro': 3
  }
  
  const userTierLevel = tierHierarchy[user.subscriptionTier] || 0
  const requiredTierLevel = tierHierarchy[requiredTier] || 0
  
  // Check if subscription is expired
  if (user.subscriptionExpiresAt) {
    const expiryDate = new Date(user.subscriptionExpiresAt)
    if (expiryDate < new Date()) {
      return requiredTierLevel === 0 // Only free tier access if expired
    }
  }
  
  return userTierLevel >= requiredTierLevel
}

function getAllowedTiers(userTier) {
  const tierHierarchy = ['free', 'basic', 'premium', 'pro']
  const userIndex = tierHierarchy.indexOf(userTier)
  
  if (userIndex === -1) {
    return ['free']
  }
  
  return tierHierarchy.slice(0, userIndex + 1)
}

function logSignalEvent(eventType, signal, metadata = {}) {
  const logData = {
    event_type: eventType,
    signal_id: signal.id,
    symbol: signal.symbol,
    type: signal.type,
    action: signal.action,
    status: signal.status,
    required_tier: signal.requiredTier,
    timestamp: new Date().toISOString(),
    metadata: metadata
  }
  
  // Log to console (in production, send to analytics service)
  console.log('Signal Event:', JSON.stringify(logData))
  
  // In production, you might want to:
  // - Send to analytics service (Google Analytics, Mixpanel, etc.)
  // - Store in a separate analytics collection
  // - Send to monitoring service
}

function notifySubscribers(eventType, signal, changes = []) {
  const notificationData = {
    type: eventType,
    signal: {
      id: signal.id,
      symbol: signal.symbol,
      companyName: signal.companyName,
      type: signal.type,
      action: signal.action,
      status: signal.status,
      requiredTier: signal.requiredTier
    },
    changes: changes,
    timestamp: new Date().toISOString()
  }
  
  console.log('Signal Notification:', JSON.stringify(notificationData))
  
  // In production, you might want to:
  // - Send push notifications to mobile apps
  // - Send email notifications to subscribers
  // - Update real-time WebSocket connections
  // - Send to message queue for async processing
}

// Scheduled job to expire old signals
routerAdd('POST', '/api/signals/expire-old', (c) => {
  const now = new Date()
  
  try {
    // Find expired signals that are still active
    const expiredSignals = $app.dao().findRecordsByFilter(
      'signals',
      'status = "active" AND expiresAt != null AND expiresAt < {:now}',
      null,
      50,
      { now: now.toISOString() }
    )
    
    let expiredCount = 0
    
    expiredSignals.forEach((signal) => {
      signal.set('status', 'expired')
      $app.dao().saveRecord(signal)
      expiredCount++
      
      console.log('Signal expired:', signal.symbol, signal.id)
      logSignalEvent('signal_expired', signal)
    })
    
    return c.json({
      success: true,
      expired_count: expiredCount,
      timestamp: now.toISOString()
    })
    
  } catch (err) {
    console.error('Failed to expire signals:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireAdminAuth())