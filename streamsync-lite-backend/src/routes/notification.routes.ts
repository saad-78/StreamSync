import { Router } from 'express'
import { NotificationController } from '../controllers/notification.controller'
import { authMiddleware } from '../middleware/auth.middleware'
import { rateLimiter } from '../middleware/rate-limit.middleware'

const router = Router()
const notificationController = new NotificationController()

// All routes require authentication
router.use(authMiddleware)

// FCM token management
router.post('/tokens', (req, res) => notificationController.registerToken(req, res))
router.delete('/tokens', (req, res) => notificationController.deleteToken(req, res))

// Test push (rate limited: 5 requests per minute)
router.post('/send-test', rateLimiter(60000, 5), (req, res) => notificationController.sendTestPush(req, res))

// Notification CRUD
router.get('/', (req, res) => notificationController.getNotifications(req, res))
router.post('/mark-read', (req, res) => notificationController.markAsRead(req, res))
router.delete('/:id', (req, res) => notificationController.deleteNotification(req, res))
router.get('/unread-count', (req, res) => notificationController.getUnreadCount(req, res))

export default router
