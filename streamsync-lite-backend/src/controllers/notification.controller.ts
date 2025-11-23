// src/controllers/notification.controller.ts
import { Response } from 'express'
import { NotificationService } from '../services/notification.service'
import { FCMTokenService } from '../services/fcm.service'
import { AuthRequest } from '../middleware/auth.middleware'
import { z } from 'zod'

const notificationService = new NotificationService()
const fcmService = new FCMTokenService()

const registerTokenSchema = z.object({
  token: z.string().min(10),
  platform: z.enum(['android', 'ios', 'web'])
})

const testPushSchema = z.object({
  title: z.string().min(1).max(100),
  body: z.string().min(1).max(500)
})

export class NotificationController {
  async registerToken(req: AuthRequest, res: Response) {
    try {
      const { token, platform } = registerTokenSchema.parse(req.body)
      const userId = req.userId!

      const result = await fcmService.registerToken(userId, token, platform)

      res.json({
        success: true,
        data: result
      })
    } catch (error: any) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation failed',
          //@ts-ignore
          details: error.errors
        })
      }
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to register token'
      })
    }
  }

  async deleteToken(req: AuthRequest, res: Response) {
    try {
      const { token } = req.body
      const userId = req.userId!

      await fcmService.deleteToken(userId, token)

      res.json({
        success: true,
        message: 'Token deleted'
      })
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to delete token'
      })
    }
  }

  async sendTestPush(req: AuthRequest, res: Response) {
    try {
      const { title, body } = testPushSchema.parse(req.body)
      const userId = req.userId!

      const result = await notificationService.sendTestPush(userId, title, body)

      res.json({
        success: true,
        data: result,
        message: `Push notification sent to ${result.sent} device(s)`
      })
    } catch (error: any) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation failed',
          //@ts-ignore
          details: error.errors
        })
      }
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to send test push'
      })
    }
  }

  async getNotifications(req: AuthRequest, res: Response) {
    try {
      const userId = req.userId!
      const limit = parseInt(req.query.limit as string) || 50

      const notifications = await notificationService.getUserNotifications(userId, limit)

      res.json({
        success: true,
        data: notifications
      })
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: error.message || 'Failed to fetch notifications'
      })
    }
  }

  async markAsRead(req: AuthRequest, res: Response) {
    try {
      const { notificationId } = req.body
      const userId = req.userId!

      await notificationService.markAsRead(notificationId, userId)

      res.json({
        success: true,
        message: 'Notification marked as read'
      })
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to mark as read'
      })
    }
  }

  async deleteNotification(req: AuthRequest, res: Response) {
    try {
      const { id } = req.params
      const userId = req.userId!

      await notificationService.deleteNotification(id, userId)

      res.json({
        success: true,
        message: 'Notification deleted'
      })
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to delete notification'
      })
    }
  }

  async getUnreadCount(req: AuthRequest, res: Response) {
    try {
      const userId = req.userId!
      const count = await notificationService.getUnreadCount(userId)

      res.json({
        success: true,
        data: { count }
      })
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: error.message || 'Failed to get unread count'
      })
    }
  }
}
