import { PrismaClient } from '@prisma/client'
import { YouTubeService } from './youtube.service'

const prisma = new PrismaClient()
const youtubeService = new YouTubeService()

export class VideoService {
  async getLatestVideos(channelId: string) {
    return await youtubeService.getLatestVideos(channelId, 10)
  }

  async getVideoById(videoId: string) {
    const video = await prisma.video.findUnique({
      where: { video_id: videoId }
    })

    if (!video) {
      throw new Error('Video not found')
    }

    return video
  }

  async saveProgress(userId: string, videoId: string, positionSeconds: number, completedPercent: number) {
    return await prisma.progress.upsert({
      where: {
        user_id_video_id: {
          user_id: userId,
          video_id: videoId
        }
      },
      update: {
        position_seconds: positionSeconds,
        completed_percent: completedPercent,
        synced: true,
        updated_at: new Date()
      },
      create: {
        user_id: userId,
        video_id: videoId,
        position_seconds: positionSeconds,
        completed_percent: completedPercent,
        synced: true
      }
    })
  }

  async getProgress(userId: string, videoId: string) {
    return await prisma.progress.findUnique({
      where: {
        user_id_video_id: {
          user_id: userId,
          video_id: videoId
        }
      }
    })
  }

  async getUserProgress(userId: string) {
    return await prisma.progress.findMany({
      where: { user_id: userId },
      include: { video: true },
      orderBy: { updated_at: 'desc' }
    })
  }

  async addFavorite(userId: string, videoId: string) {
    // Check if video exists
    const video = await prisma.video.findUnique({
      where: { video_id: videoId }
    })

    if (!video) {
      throw new Error('Video not found')
    }

    return await prisma.favorite.upsert({
      where: {
        user_id_video_id: {
          user_id: userId,
          video_id: videoId
        }
      },
      update: { synced: true },
      create: {
        user_id: userId,
        video_id: videoId,
        synced: true
      }
    })
  }

  async removeFavorite(userId: string, videoId: string) {
    return await prisma.favorite.delete({
      where: {
        user_id_video_id: {
          user_id: userId,
          video_id: videoId
        }
      }
    })
  }

  async getFavorites(userId: string) {
    return await prisma.favorite.findMany({
      where: { user_id: userId },
      include: { video: true },
      orderBy: { created_at: 'desc' }
    })
  }
}
