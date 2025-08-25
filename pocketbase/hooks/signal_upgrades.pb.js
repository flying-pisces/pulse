/// <reference path="../pb_data/types.d.ts" />

/**
 * Signal upgrades hooks for Pulse trading signals app
 * Handles dynamic signal upgrade payments and notifications
 */

onRecordBeforeCreateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signalUpgrades') {
    return
  }
  
  console.log('Creating signal upgrade:', record.signalId, record.userId)
  
  // Validate required fields
  if (!record.signalId || !record.userId || !record.paymentIntentId) {
    throw new BadRequestError('Signal ID, User ID, and Payment Intent ID are required')
  }
  
  // Validate amount
  if (!record.amount || record.amount <= 0) {
    throw new BadRequestError('Amount must be positive')
  }
  
  // Set default values
  if (!record.status) {
    record.set('status', 'pending')
  }
  
  if (!record.currency) {
    record.set('currency', 'USD')
  }
  
  if (!record.durationHours) {
    record.set('durationHours', 72) // Default 72 hours
  }
  
  // Set expiry date based on duration
  if (!record.expiresAt) {
    const expiryDate = new Date()
    expiryDate.setHours(expiryDate.getHours() + (record.durationHours || 72))
    record.set('expiresAt', expiryDate.toISOString())
  }
  
  // Initialize metadata if not provided
  if (!record.metadata) {
    record.set('metadata', JSON.stringify({}))
  }
  
}, 'signalUpgrades')

onRecordAfterCreateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signalUpgrades') {
    return
  }
  
  console.log('Signal upgrade created:', record.id, record.paymentIntentId)
  
  // Send notification to user about pending upgrade
  createUserNotification(record.userId, {
    type: 'payment_success',
    title: 'Signal Upgrade Processing',
    message: 'Your dynamic signal upgrade payment is being processed. You will receive confirmation shortly.',
    priority: 'medium',
    actionType: 'view_signal',
    actionData: JSON.stringify({ signalId: record.signalId })
  })
  
}, 'signalUpgrades')

onRecordBeforeUpdateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signalUpgrades') {
    return
  }
  
  console.log('Updating signal upgrade:', record.id, record.status)
  
  const oldStatus = record.originalCopy().status
  const newStatus = record.status
  
  // Handle status changes
  if (oldStatus !== newStatus) {
    const now = new Date().toISOString()
    
    switch (newStatus) {
      case 'confirmed':
        if (!record.confirmedAt) {
          record.set('confirmedAt', now)
        }
        break
        
      case 'failed':
        // Clear confirmation date if payment failed
        record.set('confirmedAt', null)
        break
        
      case 'refunded':
        if (!record.refundedAt) {
          record.set('refundedAt', now)
        }
        break
    }
  }
  
}, 'signalUpgrades')

onRecordAfterUpdateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'signalUpgrades') {
    return
  }
  
  const oldStatus = record.originalCopy().status
  const newStatus = record.status
  
  if (oldStatus !== newStatus) {
    console.log('Signal upgrade status changed:', record.id, oldStatus, '->', newStatus)
    
    // Handle status change notifications and actions
    switch (newStatus) {
      case 'confirmed':
        handleUpgradeConfirmed(record)
        break
        
      case 'failed':
        handleUpgradeFailed(record)
        break
        
      case 'refunded':
        handleUpgradeRefunded(record)
        break
    }
  }
  
}, 'signalUpgrades')

// Utility functions

function handleUpgradeConfirmed(upgradeRecord) {
  try {
    // Get the signal record
    const signal = $app.dao().findRecordById('signals', upgradeRecord.signalId)
    
    if (!signal) {
      console.error('Signal not found:', upgradeRecord.signalId)
      return
    }
    
    // Update signal to dynamic mode
    signal.set('isDynamic', true)
    signal.set('dynamicUserId', upgradeRecord.userId)
    signal.set('dynamicExpiresAt', upgradeRecord.expiresAt)
    signal.set('lastPriceUpdate', new Date().toISOString())
    
    $app.dao().saveRecord(signal)
    
    // Send confirmation notification
    createUserNotification(upgradeRecord.userId, {
      type: 'payment_success',
      title: 'Dynamic Signal Activated!',
      message: `Your ${signal.symbol} signal is now dynamic with real-time updates for ${upgradeRecord.durationHours} hours.`,
      priority: 'high',
      actionType: 'view_signal',
      actionData: JSON.stringify({ signalId: upgradeRecord.signalId })
    })
    
    // Create initial update
    createSignalUpdate(upgradeRecord.signalId, upgradeRecord.id, upgradeRecord.userId, {
      updateType: 'ai_analysis',
      title: 'Dynamic Signal Activated',
      content: `Your ${signal.symbol} signal is now live with real-time updates. You'll receive alerts for price movements, news, and AI analysis updates.`,
      priority: 'medium',
      data: JSON.stringify({
        activation_time: new Date().toISOString(),
        duration_hours: upgradeRecord.durationHours,
        expires_at: upgradeRecord.expiresAt
      })
    })
    
    console.log('Dynamic signal activated:', signal.symbol, upgradeRecord.id)
    
  } catch (error) {
    console.error('Failed to handle upgrade confirmation:', error.message)
  }
}

function handleUpgradeFailed(upgradeRecord) {
  try {
    // Send failure notification
    createUserNotification(upgradeRecord.userId, {
      type: 'payment_failed',
      title: 'Signal Upgrade Failed',
      message: 'Your dynamic signal upgrade payment could not be processed. Please try again or contact support.',
      priority: 'high',
      actionType: 'view_signal',
      actionData: JSON.stringify({ signalId: upgradeRecord.signalId })
    })
    
    console.log('Signal upgrade failed:', upgradeRecord.id)
    
  } catch (error) {
    console.error('Failed to handle upgrade failure:', error.message)
  }
}

function handleUpgradeRefunded(upgradeRecord) {
  try {
    // Get the signal record and remove dynamic status
    const signal = $app.dao().findRecordById('signals', upgradeRecord.signalId)
    
    if (signal) {
      signal.set('isDynamic', false)
      signal.set('dynamicUserId', null)
      signal.set('dynamicExpiresAt', null)
      $app.dao().saveRecord(signal)
    }
    
    // Send refund notification
    createUserNotification(upgradeRecord.userId, {
      type: 'payment_success',
      title: 'Signal Upgrade Refunded',
      message: 'Your dynamic signal upgrade has been refunded. The refund will appear in your account within 3-5 business days.',
      priority: 'medium'
    })
    
    console.log('Signal upgrade refunded:', upgradeRecord.id)
    
  } catch (error) {
    console.error('Failed to handle upgrade refund:', error.message)
  }
}

function createUserNotification(userId, notificationData) {
  try {
    const notification = {
      userId: userId,
      type: notificationData.type,
      title: notificationData.title,
      message: notificationData.message,
      priority: notificationData.priority || 'medium',
      actionType: notificationData.actionType || 'none',
      actionData: notificationData.actionData || JSON.stringify({}),
      isRead: false
    }
    
    $app.dao().saveRecord($app.dao().newRecordForTable('userNotifications', notification))
    
  } catch (error) {
    console.error('Failed to create user notification:', error.message)
  }
}

function createSignalUpdate(signalId, upgradeId, userId, updateData) {
  try {
    const update = {
      signalId: signalId,
      upgradeId: upgradeId,
      userId: userId,
      updateType: updateData.updateType,
      title: updateData.title,
      content: updateData.content,
      priority: updateData.priority || 'medium',
      data: updateData.data || JSON.stringify({}),
      isRead: false
    }
    
    $app.dao().saveRecord($app.dao().newRecordForTable('signalUpdates', update))
    
  } catch (error) {
    console.error('Failed to create signal update:', error.message)
  }
}

// Scheduled job to expire old dynamic signals
routerAdd('POST', '/api/signal-upgrades/expire-old', (c) => {
  const now = new Date()
  
  try {
    // Find expired upgrades that are still active
    const expiredUpgrades = $app.dao().findRecordsByFilter(
      'signalUpgrades',
      'status = "confirmed" AND expiresAt < {:now}',
      null,
      50,
      { now: now.toISOString() }
    )
    
    let expiredCount = 0
    
    expiredUpgrades.forEach((upgrade) => {
      try {
        // Get the signal and remove dynamic status
        const signal = $app.dao().findRecordById('signals', upgrade.signalId)
        
        if (signal && signal.isDynamic) {
          signal.set('isDynamic', false)
          signal.set('dynamicUserId', null)
          signal.set('dynamicExpiresAt', null)
          $app.dao().saveRecord(signal)
          
          // Create expiration notification
          createUserNotification(upgrade.userId, {
            type: 'system_alert',
            title: 'Dynamic Signal Expired',
            message: `Your dynamic signal for ${signal.symbol} has expired. Upgrade again for continued real-time updates.`,
            priority: 'medium',
            actionType: 'view_signal',
            actionData: JSON.stringify({ signalId: upgrade.signalId })
          })
          
          // Create final signal update
          createSignalUpdate(upgrade.signalId, upgrade.id, upgrade.userId, {
            updateType: 'ai_analysis',
            title: 'Dynamic Period Ended',
            content: `Your ${signal.symbol} dynamic signal has expired. The signal will continue as a standard premium signal. Upgrade again for real-time updates.`,
            priority: 'medium',
            data: JSON.stringify({
              expiration_time: now.toISOString(),
              final_price: signal.realTimePrice || signal.currentPrice
            })
          })
          
          expiredCount++
          console.log('Dynamic signal expired:', signal.symbol, upgrade.id)
        }
        
      } catch (error) {
        console.error('Failed to expire upgrade:', upgrade.id, error.message)
      }
    })
    
    return c.json({
      success: true,
      expired_count: expiredCount,
      timestamp: now.toISOString()
    })
    
  } catch (err) {
    console.error('Failed to expire signal upgrades:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireAdminAuth())

// API endpoint to check upgrade status
routerAdd('GET', '/api/signal-upgrades/status/:id', (c) => {
  const upgradeId = c.pathParam('id')
  
  try {
    const upgrade = $app.dao().findRecordById('signalUpgrades', upgradeId)
    
    if (!upgrade) {
      return c.json({ error: 'Upgrade not found' }, 404)
    }
    
    // Check if user has access
    const authRecord = c.get('authRecord')
    if (!authRecord || authRecord.id !== upgrade.userId) {
      return c.json({ error: 'Access denied' }, 403)
    }
    
    return c.json({
      id: upgrade.id,
      signalId: upgrade.signalId,
      status: upgrade.status,
      amount: upgrade.amount,
      currency: upgrade.currency,
      durationHours: upgrade.durationHours,
      expiresAt: upgrade.expiresAt,
      confirmedAt: upgrade.confirmedAt,
      createdAt: upgrade.created,
      isExpired: new Date(upgrade.expiresAt) < new Date()
    })
    
  } catch (err) {
    console.error('Failed to get upgrade status:', err.message)
    return c.json({ error: 'Internal server error' }, 500)
  }
}, $apis.requireAuth())