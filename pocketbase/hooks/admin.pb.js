/// <reference path="../pb_data/types.d.ts" />

/**
 * Admin hooks and utilities for Pulse trading signals app
 * Handles admin operations, analytics, and system maintenance
 */

// Admin dashboard API endpoints

// Get analytics overview
routerAdd('GET', '/api/admin/analytics/overview', (c) => {
  try {
    // Get user statistics
    const totalUsers = $app.dao().findRecordsByFilter('users', '', '', 1, {}).length
    const verifiedUsers = $app.dao().findRecordsByFilter('users', 'isVerified = true', '', 1, {}).length
    const paidUsers = $app.dao().findRecordsByFilter('users', 'subscriptionTier != "free"', '', 1, {}).length
    
    // Get subscription tier breakdown
    const freeUsers = $app.dao().findRecordsByFilter('users', 'subscriptionTier = "free"', '', 1, {}).length
    const basicUsers = $app.dao().findRecordsByFilter('users', 'subscriptionTier = "basic"', '', 1, {}).length
    const premiumUsers = $app.dao().findRecordsByFilter('users', 'subscriptionTier = "premium"', '', 1, {}).length
    const proUsers = $app.dao().findRecordsByFilter('users', 'subscriptionTier = "pro"', '', 1, {}).length
    
    // Get signal statistics
    const totalSignals = $app.dao().findRecordsByFilter('signals', '', '', 1, {}).length
    const activeSignals = $app.dao().findRecordsByFilter('signals', 'status = "active"', '', 1, {}).length
    const completedSignals = $app.dao().findRecordsByFilter('signals', 'status = "completed"', '', 1, {}).length
    
    // Get signal type breakdown
    const stockSignals = $app.dao().findRecordsByFilter('signals', 'type = "stock"', '', 1, {}).length
    const cryptoSignals = $app.dao().findRecordsByFilter('signals', 'type = "crypto"', '', 1, {}).length
    const forexSignals = $app.dao().findRecordsByFilter('signals', 'type = "forex"', '', 1, {}).length
    const commoditySignals = $app.dao().findRecordsByFilter('signals', 'type = "commodity"', '', 1, {}).length
    
    // Get watchlist statistics
    const totalWatchlistItems = $app.dao().findRecordsByFilter('watchlistItems', '', '', 1, {}).length
    const priceAlertsEnabled = $app.dao().findRecordsByFilter('watchlistItems', 'isPriceAlertEnabled = true', '', 1, {}).length
    
    // Calculate recent activity (last 7 days)
    const sevenDaysAgo = new Date()
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)
    
    const recentUsers = $app.dao().findRecordsByFilter(
      'users',
      'created >= {:date}',
      '',
      1,
      { date: sevenDaysAgo.toISOString() }
    ).length
    
    const recentSignals = $app.dao().findRecordsByFilter(
      'signals',
      'created >= {:date}',
      '',
      1,
      { date: sevenDaysAgo.toISOString() }
    ).length
    
    return c.json({
      users: {
        total: totalUsers,
        verified: verifiedUsers,
        paid: paidUsers,
        recent: recentUsers,
        byTier: {
          free: freeUsers,
          basic: basicUsers,
          premium: premiumUsers,
          pro: proUsers
        }
      },
      signals: {
        total: totalSignals,
        active: activeSignals,
        completed: completedSignals,
        recent: recentSignals,
        byType: {
          stock: stockSignals,
          crypto: cryptoSignals,
          forex: forexSignals,
          commodity: commoditySignals
        }
      },
      watchlist: {
        total: totalWatchlistItems,
        withAlerts: priceAlertsEnabled
      },
      timestamp: new Date().toISOString()
    })
    
  } catch (err) {
    console.error('Failed to get analytics overview:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireAdminAuth())

// Get user growth analytics
routerAdd('GET', '/api/admin/analytics/user-growth', (c) => {
  try {
    const days = parseInt(c.queryParam('days') || '30')
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - days)
    
    // Get daily user registrations
    const users = $app.dao().findRecordsByFilter(
      'users',
      'created >= {:startDate}',
      'created',
      1000,
      { startDate: startDate.toISOString() }
    )
    
    // Group by date
    const dailyGrowth = {}
    users.forEach((user) => {
      const date = user.created.split('T')[0]
      if (!dailyGrowth[date]) {
        dailyGrowth[date] = {
          date: date,
          total: 0,
          byTier: { free: 0, basic: 0, premium: 0, pro: 0 },
          byProvider: { email: 0, google: 0, apple: 0 }
        }
      }
      
      dailyGrowth[date].total++
      dailyGrowth[date].byTier[user.subscriptionTier]++
      dailyGrowth[date].byProvider[user.authProvider]++
    })
    
    return c.json({
      period: {
        days: days,
        startDate: startDate.toISOString(),
        endDate: new Date().toISOString()
      },
      dailyGrowth: Object.values(dailyGrowth),
      summary: {
        totalNewUsers: users.length,
        averagePerDay: users.length / days
      }
    })
    
  } catch (err) {
    console.error('Failed to get user growth analytics:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireAdminAuth())

// Get signal performance analytics
routerAdd('GET', '/api/admin/analytics/signal-performance', (c) => {
  try {
    const days = parseInt(c.queryParam('days') || '30')
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - days)
    
    // Get completed signals with profit/loss data
    const completedSignals = $app.dao().findRecordsByFilter(
      'signals',
      'status = "completed" AND created >= {:startDate} AND profitLossPercentage IS NOT NULL',
      '-created',
      1000,
      { startDate: startDate.toISOString() }
    )
    
    let totalProfitLoss = 0
    let profitableSignals = 0
    let totalSignals = completedSignals.length
    
    const performanceByType = {
      stock: { total: 0, profitable: 0, totalPL: 0 },
      crypto: { total: 0, profitable: 0, totalPL: 0 },
      forex: { total: 0, profitable: 0, totalPL: 0 },
      commodity: { total: 0, profitable: 0, totalPL: 0 }
    }
    
    completedSignals.forEach((signal) => {
      const pl = signal.profitLossPercentage
      totalProfitLoss += pl
      
      if (pl > 0) {
        profitableSignals++
      }
      
      if (performanceByType[signal.type]) {
        performanceByType[signal.type].total++
        performanceByType[signal.type].totalPL += pl
        if (pl > 0) {
          performanceByType[signal.type].profitable++
        }
      }
    })
    
    return c.json({
      period: {
        days: days,
        startDate: startDate.toISOString(),
        endDate: new Date().toISOString()
      },
      overall: {
        totalSignals: totalSignals,
        profitableSignals: profitableSignals,
        successRate: totalSignals > 0 ? (profitableSignals / totalSignals) * 100 : 0,
        averageProfitLoss: totalSignals > 0 ? totalProfitLoss / totalSignals : 0,
        totalProfitLoss: totalProfitLoss
      },
      byType: Object.keys(performanceByType).map(type => ({
        type: type,
        total: performanceByType[type].total,
        profitable: performanceByType[type].profitable,
        successRate: performanceByType[type].total > 0 
          ? (performanceByType[type].profitable / performanceByType[type].total) * 100 
          : 0,
        averageProfitLoss: performanceByType[type].total > 0 
          ? performanceByType[type].totalPL / performanceByType[type].total 
          : 0
      }))
    })
    
  } catch (err) {
    console.error('Failed to get signal performance analytics:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireAdminAuth())

// Bulk update user subscriptions
routerAdd('POST', '/api/admin/users/bulk-update-subscription', (c) => {
  const requestData = c.bind({})
  
  try {
    const { userIds, subscriptionTier, expiresAt } = requestData
    
    if (!userIds || !Array.isArray(userIds) || !subscriptionTier) {
      return c.json({ error: 'userIds and subscriptionTier are required' }, 400)
    }
    
    let updatedCount = 0
    const results = []
    
    userIds.forEach((userId) => {
      try {
        const user = $app.dao().findRecordById('users', userId)
        
        user.set('subscriptionTier', subscriptionTier)
        
        if (expiresAt) {
          user.set('subscriptionExpiresAt', expiresAt)
        } else if (subscriptionTier === 'free') {
          user.set('subscriptionExpiresAt', null)
        }
        
        $app.dao().saveRecord(user)
        updatedCount++
        
        results.push({
          userId: userId,
          email: user.email,
          status: 'updated',
          newTier: subscriptionTier
        })
        
        console.log('Subscription updated for user:', user.email, 'to tier:', subscriptionTier)
        
      } catch (err) {
        results.push({
          userId: userId,
          status: 'error',
          error: err.message
        })
        console.error('Failed to update subscription for user:', userId, err.message)
      }
    })
    
    return c.json({
      success: true,
      updatedCount: updatedCount,
      totalRequested: userIds.length,
      results: results
    })
    
  } catch (err) {
    console.error('Failed to bulk update subscriptions:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireAdminAuth())

// System health check
routerAdd('GET', '/api/admin/system/health', (c) => {
  try {
    // Check database connection
    const dbHealth = checkDatabaseHealth()
    
    // Check collection counts
    const collections = {
      users: $app.dao().findRecordsByFilter('users', '', '', 1, {}).length,
      signals: $app.dao().findRecordsByFilter('signals', '', '', 1, {}).length,
      watchlistItems: $app.dao().findRecordsByFilter('watchlistItems', '', '', 1, {}).length
    }
    
    // Check for expired signals that need cleanup
    const expiredSignals = $app.dao().findRecordsByFilter(
      'signals',
      'status = "active" AND expiresAt < {:now}',
      '',
      1,
      { now: new Date().toISOString() }
    ).length
    
    // Check for expired subscriptions
    const expiredSubscriptions = $app.dao().findRecordsByFilter(
      'users',
      'subscriptionTier != "free" AND subscriptionExpiresAt < {:now}',
      '',
      1,
      { now: new Date().toISOString() }
    ).length
    
    const systemHealth = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      database: dbHealth,
      collections: collections,
      issues: {
        expiredSignals: expiredSignals,
        expiredSubscriptions: expiredSubscriptions
      }
    }
    
    // Mark as unhealthy if there are critical issues
    if (expiredSignals > 100 || expiredSubscriptions > 50) {
      systemHealth.status = 'warning'
    }
    
    return c.json(systemHealth)
    
  } catch (err) {
    console.error('System health check failed:', err.message)
    return c.json({
      status: 'unhealthy',
      error: err.message,
      timestamp: new Date().toISOString()
    }, 500)
  }
}, $apis.requireAdminAuth())

// Clean up expired data
routerAdd('POST', '/api/admin/system/cleanup', (c) => {
  try {
    let cleanupResults = {
      expiredSignals: 0,
      expiredSubscriptions: 0,
      oldRecords: 0
    }
    
    // Expire old signals
    const expiredSignals = $app.dao().findRecordsByFilter(
      'signals',
      'status = "active" AND expiresAt < {:now}',
      '',
      100,
      { now: new Date().toISOString() }
    )
    
    expiredSignals.forEach((signal) => {
      signal.set('status', 'expired')
      $app.dao().saveRecord(signal)
      cleanupResults.expiredSignals++
      console.log('Expired signal:', signal.symbol, signal.id)
    })
    
    // Handle expired subscriptions
    const expiredSubscriptions = $app.dao().findRecordsByFilter(
      'users',
      'subscriptionTier != "free" AND subscriptionExpiresAt < {:now}',
      '',
      100,
      { now: new Date().toISOString() }
    )
    
    expiredSubscriptions.forEach((user) => {
      user.set('subscriptionTier', 'free')
      user.set('subscriptionExpiresAt', null)
      $app.dao().saveRecord(user)
      cleanupResults.expiredSubscriptions++
      console.log('Downgraded expired subscription for user:', user.email)
    })
    
    // Clean up very old completed/cancelled signals (older than 90 days)
    const ninetyDaysAgo = new Date()
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90)
    
    const oldSignals = $app.dao().findRecordsByFilter(
      'signals',
      '(status = "completed" OR status = "cancelled") AND created < {:date}',
      '',
      50,
      { date: ninetyDaysAgo.toISOString() }
    )
    
    oldSignals.forEach((signal) => {
      $app.dao().deleteRecord(signal)
      cleanupResults.oldRecords++
      console.log('Deleted old signal:', signal.symbol, signal.id)
    })
    
    return c.json({
      success: true,
      timestamp: new Date().toISOString(),
      results: cleanupResults
    })
    
  } catch (err) {
    console.error('System cleanup failed:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireAdminAuth())

// Export data for backup
routerAdd('GET', '/api/admin/export/:collection', (c) => {
  const collection = c.pathParam('collection')
  const format = c.queryParam('format') || 'json'
  const limit = parseInt(c.queryParam('limit') || '1000')
  
  try {
    if (!['users', 'signals', 'watchlistItems'].includes(collection)) {
      return c.json({ error: 'Invalid collection' }, 400)
    }
    
    const records = $app.dao().findRecordsByFilter(collection, '', '-created', limit, {})
    
    const exportData = records.map((record) => {
      // Remove sensitive data for users export
      if (collection === 'users') {
        return {
          id: record.id,
          email: record.email,
          firstName: record.firstName,
          lastName: record.lastName,
          isVerified: record.isVerified,
          subscriptionTier: record.subscriptionTier,
          subscriptionExpiresAt: record.subscriptionExpiresAt,
          authProvider: record.authProvider,
          created: record.created,
          updated: record.updated
        }
      }
      
      return record.exportCopy()
    })
    
    const result = {
      collection: collection,
      format: format,
      count: exportData.length,
      exportedAt: new Date().toISOString(),
      data: exportData
    }
    
    if (format === 'csv') {
      // Convert to CSV format
      return c.json({ error: 'CSV format not implemented yet' }, 501)
    }
    
    return c.json(result)
    
  } catch (err) {
    console.error('Export failed:', err.message)
    return c.json({ error: err.message }, 500)
  }
}, $apis.requireAdminAuth())

// Utility functions

function checkDatabaseHealth() {
  try {
    // Simple database health check
    const testRecord = $app.dao().findRecordsByFilter('users', '', '', 1, {})
    return {
      status: 'connected',
      responseTime: 'fast'
    }
  } catch (err) {
    return {
      status: 'error',
      error: err.message
    }
  }
}

// Admin user management hooks

onAdminAuthRequest((e) => {
  console.log('Admin authentication attempt:', e.admin.email)
})

onAdminAfterAuthRequest((e) => {
  console.log('Admin authenticated successfully:', e.admin.email)
})

// Log important admin actions
onRecordAfterCreateRequest((e) => {
  if (e.admin && e.collection.name === 'signals') {
    console.log('Admin created signal:', e.record.symbol, 'by:', e.admin.email)
  }
})

onRecordAfterUpdateRequest((e) => {
  if (e.admin && e.collection.name === 'signals') {
    console.log('Admin updated signal:', e.record.symbol, 'by:', e.admin.email)
  }
  
  if (e.admin && e.collection.name === 'users') {
    const original = e.record.originalCopy()
    if (original.subscriptionTier !== e.record.subscriptionTier) {
      console.log('Admin changed user subscription:', e.record.email, 
                 original.subscriptionTier, '->', e.record.subscriptionTier, 
                 'by:', e.admin.email)
    }
  }
})

onRecordAfterDeleteRequest((e) => {
  if (e.admin) {
    console.log('Admin deleted record:', e.collection.name, e.record.id, 'by:', e.admin.email)
  }
})