import { Router } from 'express'
import { VideoController } from '../controllers/video.controller'
import { authMiddleware } from '../middleware/auth.middleware'

const router = Router()
const videoController = new VideoController()

// All video routes require authentication
router.use(authMiddleware)

router.get('/latest', (req, res) => videoController.getLatest(req, res))
router.get('/:videoId', (req, res) => videoController.getById(req, res))

router.post('/progress', (req, res) => videoController.saveProgress(req, res))
router.get('/progress/user', (req, res) => videoController.getProgress(req, res))

router.post('/favorites', (req, res) => videoController.addFavorite(req, res))
router.delete('/favorites/:videoId', (req, res) => videoController.removeFavorite(req, res))
router.get('/favorites/user', (req, res) => videoController.getFavorites(req, res))

export default router
