import { google } from 'googleapis'
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()
const youtube = google.youtube('v3')

const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY
const CACHE_TTL_MINUTES = 10

export class YouTubeService {
  async getLatestVideos(channelId: string, maxResults: number = 10) {
  // Validate inputs
  if (!channelId) {
    throw new Error('Channel ID is required')
  }

  if (!YOUTUBE_API_KEY || YOUTUBE_API_KEY === 'your-youtube-api-key-here') {
    console.warn('⚠️  No valid YouTube API key configured')
    return this.getMockVideos()
  }

  // Check cache first
  const cachedVideos = await this.getCachedVideos(channelId, maxResults)
  
  if (cachedVideos.length > 0 && this.isCacheFresh(cachedVideos[0].created_at)) {
    console.log('✅ Returning cached videos')
    return cachedVideos
  }

  // Fetch from YouTube API with error handling
  try {
    console.log('🔄 Fetching fresh videos from YouTube API')
    const freshVideos = await this.fetchFromYouTube(channelId, maxResults)
    
    if (freshVideos.length > 0) {
      // Cache in database
      await this.cacheVideos(freshVideos)
      return freshVideos
    }
    
    // NEW: If no fresh videos found
    console.log('⚠️  No videos found from YouTube API')
    
    // If we have cache, return it even if stale
    if (cachedVideos.length > 0) {
      console.log('⚠️  Returning stale cache')
      return cachedVideos
    }
    
    // NEW: No cache and no YouTube results - return mock data
    console.log('⚠️  Returning mock data (no YouTube results and no cache)')
    return this.getMockVideos()
    
  } catch (error: any) {
    console.error('Failed to fetch from YouTube, checking cache...', error.message)
    
    // Return cache if available, even if stale
    if (cachedVideos.length > 0) {
      console.log('⚠️  Using cached videos due to API error')
      return cachedVideos
    }
    
    // Last resort: return mock data for testing
    console.log('⚠️  Returning mock data (API error)')
    return this.getMockVideos()
  }
}


  private async fetchFromYouTube(channelId: string, maxResults: number) {
    try {
      // Step 1: Search for videos
      const response = await youtube.search.list({
        key: YOUTUBE_API_KEY,
        channelId: channelId,
        part: ['snippet'],
        order: 'date',
        maxResults: maxResults,
        type: ['video']
      })

      if (!response.data.items || response.data.items.length === 0) {
        console.log('No videos found for channel:', channelId)
        return []
      }

      // Step 2: Extract video IDs
      const videoIds = response.data.items
        .map(item => item.id?.videoId)
        .filter(Boolean) as string[]

      if (videoIds.length === 0) {
        console.log('No valid video IDs found')
        return []
      }

      console.log(`Found ${videoIds.length} videos, fetching details...`)

      // Step 3: Get video details (FIXED: pass as array, not comma-separated string)
      const detailsResponse = await youtube.videos.list({
        key: YOUTUBE_API_KEY,
        id: videoIds,  // Pass array directly
        part: ['contentDetails', 'snippet', 'statistics']
      })

      if (!detailsResponse.data.items || detailsResponse.data.items.length === 0) {
        console.log('No video details found')
        return []
      }

      // Step 4: Map to our schema
      const videos = detailsResponse.data.items.map(video => ({
        video_id: video.id!,
        title: video.snippet?.title || 'Untitled',
        description: video.snippet?.description || '',
        thumbnail_url: video.snippet?.thumbnails?.high?.url || 
                       video.snippet?.thumbnails?.medium?.url || 
                       video.snippet?.thumbnails?.default?.url || '',
        channel_id: video.snippet?.channelId || channelId,
        channel_title: video.snippet?.channelTitle || 'Unknown Channel',
        published_at: new Date(video.snippet?.publishedAt || Date.now()),
        duration_seconds: this.parseDuration(video.contentDetails?.duration || 'PT0S')
      }))

      console.log(`✅ Successfully fetched ${videos.length} videos from YouTube`)
      return videos

    } catch (error: any) {
      console.error('YouTube API Error:', error.message)
      
      // Log additional error details
      if (error.response?.data?.error) {
        console.error('API Error Details:', JSON.stringify(error.response.data.error, null, 2))
      }
      
      throw new Error('Failed to fetch videos from YouTube')
    }
  }

  private async cacheVideos(videos: any[]) {
    for (const video of videos) {
      await prisma.video.upsert({
        where: { video_id: video.video_id },
        update: video,
        create: video
      })
    }
  }

  private async getCachedVideos(channelId: string, limit: number) {
    return await prisma.video.findMany({
      where: { channel_id: channelId },
      orderBy: { published_at: 'desc' },
      take: limit
    })
  }

  private isCacheFresh(createdAt: Date): boolean {
    const now = new Date()
    const diff = now.getTime() - createdAt.getTime()
    const minutes = diff / (1000 * 60)
    return minutes < CACHE_TTL_MINUTES
  }

  private parseDuration(duration: string): number {
    // Parse ISO 8601 duration (e.g., PT1H2M10S)
    const match = duration.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/)
    if (!match) return 0

    const hours = parseInt(match[1] || '0')
    const minutes = parseInt(match[2] || '0')
    const seconds = parseInt(match[3] || '0')

    return hours * 3600 + minutes * 60 + seconds
  }

  private getMockVideos() {
    return [
      {
        video_id: 'dQw4w9WgXcQ',
        title: 'Sample Video - Learn TypeScript',
        description: 'This is a sample video for testing the StreamSync Lite app. Learn TypeScript fundamentals and advanced concepts.',
        thumbnail_url: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        channel_id: 'UCYfdidRxbB8Qhf0Nx7ioOYw',
        channel_title: 'Tech Channel',
        published_at: new Date(),
        duration_seconds: 600
      },
      {
        video_id: 'jNQXAC9IVRw',
        title: 'Sample Video 2 - Node.js Backend',
        description: 'Building scalable backends with Node.js and Express. Best practices for production.',
        thumbnail_url: 'https://i.ytimg.com/vi/jNQXAC9IVRw/hqdefault.jpg',
        channel_id: 'UCYfdidRxbB8Qhf0Nx7ioOYw',
        channel_title: 'Tech Channel',
        published_at: new Date(Date.now() - 86400000),
        duration_seconds: 720
      },
      {
        video_id: 'M7lc1UVf-VE',
        title: 'Sample Video 3 - Flutter Development',
        description: 'Complete Flutter tutorial for building mobile apps. From basics to advanced state management.',
        thumbnail_url: 'https://i.ytimg.com/vi/M7lc1UVf-VE/hqdefault.jpg',
        channel_id: 'UCYfdidRxbB8Qhf0Nx7ioOYw',
        channel_title: 'Tech Channel',
        published_at: new Date(Date.now() - 172800000),
        duration_seconds: 900
      }
    ]
  }
}
