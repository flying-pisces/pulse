/// <reference path="../pb_data/types.d.ts" />

/**
 * Watchlist hooks for Pulse trading signals app
 * Handles watchlist operations and price alerts
 */

onRecordBeforeCreateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'watchlistItems') {
    return
  }
  
  console.log('Adding to watchlist:', record.symbol, 'for user:', record.userId)
  
  // Validate watchlist data
  validateWatchlistData(record)
  
  // Check for duplicates
  const existingItem = $app.dao().findFirstRecordByData(
    'watchlistItems',
    'userId',
    record.userId,
    'symbol',
    record.symbol
  )
  
  if (existingItem) {
    throw new BadRequestError(`${record.symbol} is already in your watchlist`)
  }
  
  // Set default values
  if (!record.addedAt) {
    record.set('addedAt', new Date().toISOString())
  }
  
  if (record.isPriceAlertEnabled === undefined) {
    record.set('isPriceAlertEnabled', false)
  }
}, 'watchlistItems')

onRecordAfterCreateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'watchlistItems') {
    return
  }
  
  console.log('Watchlist item created:', record.symbol, record.id)
  
  // Log watchlist addition for analytics
  logWatchlistEvent('watchlist_added', record)
  
  // Send real-time update to user
  notifyUser(record.userId, 'watchlist_added', {
    symbol: record.symbol,
    companyName: record.companyName
  })
}, 'watchlistItems')

onRecordBeforeUpdateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'watchlistItems') {
    return
  }
  
  console.log('Updating watchlist item:', record.symbol, record.id)
  
  // Validate watchlist data
  validateWatchlistData(record)
  
  // Check for price alert changes
  const original = record.originalCopy()
  
  if (record.isPriceAlertEnabled && !original.isPriceAlertEnabled) {
    console.log('Price alert enabled for:', record.symbol, 'target:', record.priceAlertTarget)
    
    if (!record.priceAlertTarget) {
      throw new BadRequestError('Price alert target is required when enabling price alerts')
    }
    
    // Validate price alert target
    if (record.priceAlertTarget <= 0) {
      throw new BadRequestError('Price alert target must be a positive number')
    }
  }
  
  if (!record.isPriceAlertEnabled && original.isPriceAlertEnabled) {
    console.log('Price alert disabled for:', record.symbol)
    record.set('priceAlertTarget', null)
  }
  
  // Check for price changes that might trigger alerts
  if (record.isPriceAlertEnabled && record.priceAlertTarget && 
      record.currentPrice !== original.currentPrice) {
    checkPriceAlert(record, original)
  }
}, 'watchlistItems')

onRecordAfterUpdateRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'watchlistItems') {
    return
  }
  
  console.log('Watchlist item updated:', record.symbol, record.id)
  
  // Log watchlist update for analytics
  logWatchlistEvent('watchlist_updated', record)
  
  // Check for significant price changes
  const original = record.originalCopy()
  const priceChangeThreshold = 5.0 // 5% change threshold
  
  if (Math.abs(record.priceChangePercent) >= priceChangeThreshold) {
    console.log('Significant price change detected:', record.symbol, record.priceChangePercent + '%')
    
    notifyUser(record.userId, 'significant_price_change', {
      symbol: record.symbol,
      companyName: record.companyName,
      currentPrice: record.currentPrice,
      priceChange: record.priceChange,
      priceChangePercent: record.priceChangePercent
    })
  }
}, 'watchlistItems')

onRecordBeforeDeleteRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'watchlistItems') {
    return
  }
  
  console.log('Removing from watchlist:', record.symbol, record.id)
  
  // Log watchlist removal
  logWatchlistEvent('watchlist_removed', record)
}, 'watchlistItems')

onRecordAfterDeleteRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'watchlistItems') {
    return
  }
  
  console.log('Watchlist item removed:', record.symbol, record.id)
  
  // Notify user of removal
  notifyUser(record.userId, 'watchlist_removed', {
    symbol: record.symbol,
    companyName: record.companyName
  })
}, 'watchlistItems')

onRecordViewRequest((e) => {
  const record = e.record
  
  if (e.collection.name !== 'watchlistItems') {
    return
  }
  
  // Ensure user can only view their own watchlist items
  const authRecord = e.auth
  if (!authRecord) {
    throw new UnauthorizedError('Authentication required')
  }
  
  if (record.userId !== authRecord.id) {
    throw new ForbiddenError('Access denied')
  }
}, 'watchlistItems')

onRecordsListRequest((e) => {
  if (e.collection.name !== 'watchlistItems') {
    return
  }
  
  const authRecord = e.auth
  if (!authRecord) {
    throw new UnauthorizedError('Authentication required')
  }
  
  // Automatically filter to user's own watchlist items
  const userFilter = `userId = "${authRecord.id}"`
  
  if (e.filter) {
    e.filter = `(${e.filter}) && (${userFilter})`
  } else {
    e.filter = userFilter
  }
  
  console.log('Watchlist request for user:', authRecord.email, 'filter:', e.filter)
}, 'watchlistItems')

// Utility functions

function validateWatchlistData(record) {
  // Validate required fields
  const requiredFields = ['userId', 'symbol', 'companyName', 'type', 'currentPrice', 'priceChange', 'priceChangePercent']
  
  for (const field of requiredFields) {
    if (record[field] === undefined || record[field] === null) {
      throw new BadRequestError(`Field '${field}' is required`)
    }
  }
  
  // Validate symbol format
  if (!/^[A-Z0-9]+$/.test(record.symbol)) {
    throw new BadRequestError('Symbol must contain only uppercase letters and numbers')
  }
  
  // Validate price fields
  if (record.currentPrice <= 0) {
    throw new BadRequestError('Current price must be a positive number')
  }
  
  // Validate type
  const validTypes = ['stock', 'crypto', 'forex', 'commodity']
  if (!validTypes.includes(record.type)) {
    throw new BadRequestError(`Type must be one of: ${validTypes.join(', ')}`)
  }
  
  // Validate price alert target if enabled
  if (record.isPriceAlertEnabled && record.priceAlertTarget) {
    if (record.priceAlertTarget <= 0) {
      throw new BadRequestError('Price alert target must be a positive number')
    }
  }
  
  // Validate notes length
  if (record.notes && record.notes.length > 1000) {
    throw new BadRequestError('Notes must be no more than 1000 characters long')
  }
  
  // Validate user exists
  try {
    const user = $app.dao().findRecordById('users', record.userId)
    if (!user) {
      throw new BadRequestError('Invalid user ID')
    }
  } catch (err) {
    throw new BadRequestError('Invalid user ID')
  }
}

function checkPriceAlert(record, original) {
  const target = record.priceAlertTarget
  const currentPrice = record.currentPrice
  const previousPrice = original.currentPrice
  
  // Check if price crossed the alert threshold
  let alertTriggered = false
  let alertType = ''
  
  if (previousPrice < target && currentPrice >= target) {
    alertTriggered = true
    alertType = 'above'
  } else if (previousPrice > target && currentPrice <= target) {
    alertTriggered = true
    alertType = 'below'
  }
  
  if (alertTriggered) {
    console.log('Price alert triggered:', record.symbol, 'target:', target, 'current:', currentPrice, 'type:', alertType)
    
    // Send price alert notification
    sendPriceAlert(record, alertType)
    
    // Log price alert event
    logWatchlistEvent('price_alert_triggered', record, {
      alert_type: alertType,
      target_price: target,
      triggered_price: currentPrice
    })
    
    // Optionally disable the alert after triggering (one-time alert)
    // record.set('isPriceAlertEnabled', false)
    // record.set('priceAlertTarget', null)
  }
}

function sendPriceAlert(record, alertType) {
  const alertData = {
    type: 'price_alert',
    alert_type: alertType,
    symbol: record.symbol,
    companyName: record.companyName,
    currentPrice: record.currentPrice,
    targetPrice: record.priceAlertTarget,
    priceChange: record.priceChange,
    priceChangePercent: record.priceChangePercent,
    timestamp: new Date().toISOString()
  }
  
  console.log('Price Alert:', JSON.stringify(alertData))
  
  // Send notification to user
  notifyUser(record.userId, 'price_alert', alertData)
  
  // In production, you might want to:
  // - Send push notification to mobile app
  // - Send email notification
  // - Send SMS notification
  // - Log to notification history
}

function logWatchlistEvent(eventType, watchlistItem, metadata = {}) {
  const logData = {
    event_type: eventType,
    watchlist_item_id: watchlistItem.id,
    user_id: watchlistItem.userId,
    symbol: watchlistItem.symbol,
    type: watchlistItem.type,
    current_price: watchlistItem.currentPrice,
    price_change_percent: watchlistItem.priceChangePercent,
    is_price_alert_enabled: watchlistItem.isPriceAlertEnabled,
    price_alert_target: watchlistItem.priceAlertTarget,
    timestamp: new Date().toISOString(),
    metadata: metadata
  }
  
  // Log to console (in production, send to analytics service)
  console.log('Watchlist Event:', JSON.stringify(logData))
}

function notifyUser(userId, notificationType, data) {
  const notification = {
    user_id: userId,
    type: notificationType,
    data: data,
    timestamp: new Date().toISOString()
  }
  
  console.log('User Notification:', JSON.stringify(notification))
  
  // In production, you might want to:
  // - Store notification in database
  // - Send real-time update via WebSocket
  // - Send push notification
  // - Add to notification queue
}

// API endpoint to update watchlist prices
routerAdd('POST', '/api/watchlist/update-prices', (c) => {
  const requestData = c.bind({})
  
  try {
    const updates = requestData.updates || []
    let updatedCount = 0
    
    updates.forEach((update) => {
      try {
        const watchlistItem = $app.dao().findRecordById('watchlistItems', update.id)
        
        if (watchlistItem) {
          const originalPrice = watchlistItem.currentPrice
          
          watchlistItem.set('currentPrice', update.currentPrice)
          watchlistItem.set('priceChange', update.priceChange)
          watchlistItem.set('priceChangePercent', update.priceChangePercent)
          
          $app.dao().saveRecord(watchlistItem)
          updatedCount++
          
          console.log('Price updated for watchlist item:', watchlistItem.symbol, 
                     originalPrice, '->', update.currentPrice)
        }
      } catch (err) {
        console.error('Failed to update watchlist item:', update.id, err.message)
      }
    })
    
    return c.json({
      success: true,
      updated_count: updatedCount,
      timestamp: new Date().toISOString()
    })
    
  } catch (err) {
    console.error('Failed to update watchlist prices:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireRecordAuth('users'))

// API endpoint to get watchlist with current market data
routerAdd('GET', '/api/watchlist/with-market-data/:userId', (c) => {
  const userId = c.pathParam('userId')
  const authRecord = c.get('authRecord')
  
  // Ensure user can only access their own watchlist
  if (!authRecord || authRecord.id !== userId) {
    return c.json({ error: 'Access denied' }, 403)
  }
  
  try {
    const watchlistItems = $app.dao().findRecordsByFilter(
      'watchlistItems',
      'userId = {:userId}',
      '-addedAt',
      50,
      { userId: userId }
    )
    
    const result = watchlistItems.map((item) => ({
      id: item.id,
      symbol: item.symbol,
      companyName: item.companyName,
      type: item.type,
      currentPrice: item.currentPrice,
      priceChange: item.priceChange,
      priceChangePercent: item.priceChangePercent,
      addedAt: item.addedAt,
      isPriceAlertEnabled: item.isPriceAlertEnabled,
      priceAlertTarget: item.priceAlertTarget,
      notes: item.notes
    }))
    
    return c.json({
      success: true,
      items: result,
      count: result.length,
      timestamp: new Date().toISOString()
    })
    
  } catch (err) {
    console.error('Failed to get watchlist with market data:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireRecordAuth('users'))