import { Response } from 'express'
import { VideoService } from '../services/video.service'
import { AuthRequest } from '../middleware/auth.middleware'
import { z } from 'zod'

const videoService = new VideoService()

const progressSchema = z.object({
  videoId: z.string(),
  positionSeconds: z.number().min(0),
  completedPercent: z.number().min(0).max(100)
})

const favoriteSchema = z.object({
  videoId: z.string()
})

export class VideoController {
  async getLatest(req: AuthRequest, res: Response) {
    try {
      const channelId = req.query.channelId as string || process.env.DEFAULT_CHANNEL_ID

      if (!channelId) {
        return res.status(400).json({
          success: false,
          error: 'Channel ID is required'
        })
      }

      const videos = await videoService.getLatestVideos(channelId)

      res.json({
        success: true,
        data: videos
      })
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: error.message || 'Failed to fetch videos'
      })
    }
  }

  async getById(req: AuthRequest, res: Response) {
    try {
      const { videoId } = req.params
      const video = await videoService.getVideoById(videoId)

      res.json({
        success: true,
        data: video
      })
    } catch (error: any) {
      res.status(404).json({
        success: false,
        error: error.message || 'Video not found'
      })
    }
  }

  async saveProgress(req: AuthRequest, res: Response) {
    try {
      const { videoId, positionSeconds, completedPercent } = progressSchema.parse(req.body)
      const userId = req.userId!

      const progress = await videoService.saveProgress(userId, videoId, positionSeconds, completedPercent)

      res.json({
        success: true,
        data: progress
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
        error: error.message || 'Failed to save progress'
      })
    }
  }

  async getProgress(req: AuthRequest, res: Response) {
    try {
      const userId = req.userId!
      const progress = await videoService.getUserProgress(userId)

      res.json({
        success: true,
        data: progress
      })
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: error.message || 'Failed to fetch progress'
      })
    }
  }

  async addFavorite(req: AuthRequest, res: Response) {
    try {
      const { videoId } = favoriteSchema.parse(req.body)
      const userId = req.userId!

      const favorite = await videoService.addFavorite(userId, videoId)

      res.json({
        success: true,
        data: favorite
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
        error: error.message || 'Failed to add favorite'
      })
    }
  }

  async removeFavorite(req: AuthRequest, res: Response) {
    try {
      const { videoId } = req.params
      const userId = req.userId!

      await videoService.removeFavorite(userId, videoId)

      res.json({
        success: true,
        message: 'Favorite removed'
      })
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to remove favorite'
      })
    }
  }

  async getFavorites(req: AuthRequest, res: Response) {
    try {
      const userId = req.userId!
      const favorites = await videoService.getFavorites(userId)

      res.json({
        success: true,
        data: favorites
      })
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: error.message || 'Failed to fetch favorites'
      })
    }
  }
}
