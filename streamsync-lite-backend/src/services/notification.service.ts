// src/services/notification.service.ts
import { PrismaClient } from '@prisma/client'
import admin from 'firebase-admin'
import { FCMTokenService } from './fcm.service'
import * as fs from 'fs'
import * as path from 'path'

const prisma = new PrismaClient()
const fcmService = new FCMTokenService()

// Initialize Firebase Admin (only once)
let firebaseInitialized = false

function initializeFirebase() {
  if (firebaseInitialized) {
    return true
  }

  try {
    const serviceAccountPath = path.join(process.cwd(), 'firebase-service-account.json')
    
    // Check if file exists
    if (!fs.existsSync(serviceAccountPath)) {
      console.warn('⚠️  Firebase service account file not found. Push notifications will not work.')
      return false
    }

    const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'))
    
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    })
    
    firebaseInitialized = true
    console.log('✅ Firebase Admin initialized')
    return true
  } catch (error: any) {
    console.error('⚠️  Firebase Admin initialization failed:', error.message)
    return false
  }
}

// Try to initialize on module load
initializeFirebase()

export class NotificationService {
  async createNotification(userId: string | null, title: string, body: string, metadata?: any) {
    // Create notification record
    const notification = await prisma.notification.create({
      data: {
        user_id: userId,
        title,
        body,
        metadata: metadata || {}
      }
    })

    // Create job to send it
    await prisma.notificationJob.create({
      data: {
        notification_id: notification.id,
        status: 'pending'
      }
    })

    return notification
  }

  async sendTestPush(userId: string, title: string, body: string) {
    if (!firebaseInitialized) {
      throw new Error('Firebase Admin is not initialized. Please add firebase-service-account.json')
    }

    // Get user's FCM tokens
    const tokens = await fcmService.getUserTokens(userId)

    if (tokens.length === 0) {
      throw new Error('No FCM tokens registered for this user')
    }

    // Create notification record
    const notification = await this.createNotification(userId, title, body, {
      type: 'test',
      timestamp: new Date().toISOString()
    })

    // Send immediately (for test push, we don't queue)
    const tokenStrings = tokens.map(t => t.token)
    
    try {
      const result = await this.sendPushToTokens(tokenStrings, title, body, {
        notificationId: notification.id,
        type: 'test'
      })

      // Mark as sent
      await prisma.notification.update({
        where: { id: notification.id },
        data: { sent: true }
      })

      return {
        notification,
        sent: result.successCount,
        failed: result.failureCount
      }
    } catch (error: any) {
      console.error('Failed to send test push:', error)
      throw new Error('Failed to send push notification')
    }
  }

  async sendPushToTokens(tokens: string[], title: string, body: string, data?: any) {
    if (!firebaseInitialized) {
      throw new Error('Firebase Admin is not initialized')
    }

    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title,
        body
      },
      data: data || {},
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          priority: 'high'
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1
          }
        }
      }
    }

    const response = await admin.messaging().sendEachForMulticast(message)
    
    console.log(`✅ Push sent: ${response.successCount} success, ${response.failureCount} failures`)
    
    // Log failures
    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`Failed to send to token ${tokens[idx]}:`, resp.error)
        }
      })
    }

    return response
  }

  async getUserNotifications(userId: string, limit: number = 50) {
    return await prisma.notification.findMany({
      where: {
        user_id: userId,
        is_deleted: false
      },
      orderBy: { received_at: 'desc' },
      take: limit
    })
  }

  async markAsRead(notificationId: string, userId: string) {
    return await prisma.notification.updateMany({
      where: {
        id: notificationId,
        user_id: userId
      },
      data: {
        is_read: true
      }
    })
  }

  async deleteNotification(notificationId: string, userId: string) {
    return await prisma.notification.updateMany({
      where: {
        id: notificationId,
        user_id: userId
      },
      data: {
        is_deleted: true
      }
    })
  }

  async getUnreadCount(userId: string) {
    return await prisma.notification.count({
      where: {
        user_id: userId,
        is_read: false,
        is_deleted: false
      }
    })
  }
}
