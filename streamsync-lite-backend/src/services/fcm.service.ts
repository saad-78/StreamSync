// src/services/fcm.service.ts
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

export class FCMTokenService {
  async registerToken(userId: string, token: string, platform: string) {
    // Check if token already exists
    const existingToken = await prisma.fcmToken.findUnique({
      where: { token }
    })

    if (existingToken) {
      // Update if owned by different user
      if (existingToken.user_id !== userId) {
        return await prisma.fcmToken.update({
          where: { token },
          data: { user_id: userId, platform }
        })
      }
      return existingToken
    }

    // Create new token
    return await prisma.fcmToken.create({
      data: {
        user_id: userId,
        token,
        platform
      }
    })
  }

  async deleteToken(userId: string, token: string) {
    return await prisma.fcmToken.deleteMany({
      where: {
        user_id: userId,
        token
      }
    })
  }

  async getUserTokens(userId: string) {
    return await prisma.fcmToken.findMany({
      where: { user_id: userId }
    })
  }

  async deleteAllUserTokens(userId: string) {
    return await prisma.fcmToken.deleteMany({
      where: { user_id: userId }
    })
  }
}
