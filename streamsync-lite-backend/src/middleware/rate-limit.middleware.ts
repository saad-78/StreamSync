// src/middleware/rate-limit.middleware.ts
import { Request, Response, NextFunction } from 'express'

interface RateLimitStore {
  [key: string]: {
    count: number
    resetTime: number
  }
}

const store: RateLimitStore = {}

export const rateLimiter = (windowMs: number, maxRequests: number) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const userId = (req as any).userId
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized' })
    }

    const key = `${userId}`
    const now = Date.now()

    // Initialize or reset if window expired
    if (!store[key] || store[key].resetTime < now) {
      store[key] = {
        count: 0,
        resetTime: now + windowMs
      }
    }

    // Check limit
    if (store[key].count >= maxRequests) {
      const resetIn = Math.ceil((store[key].resetTime - now) / 1000)
      return res.status(429).json({
        error: 'Too many requests',
        retryAfter: resetIn
      })
    }

    // Increment counter
    store[key].count++
    next()
  }
}
