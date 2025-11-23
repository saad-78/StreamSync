// src/controllers/auth.controller.ts
import { Request, Response } from 'express'
import { AuthService } from '../services/auth.service'
import { z } from 'zod'

const authService = new AuthService()

// Validation schemas
const registerSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(6)
})

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string()
})

const refreshSchema = z.object({
  refreshToken: z.string()
})

export class AuthController {
  async register(req: Request, res: Response) {
    try {
      // Validate input
      const { name, email, password } = registerSchema.parse(req.body)

      // Register user
      const result = await authService.register(name, email, password)

      res.status(201).json({
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
        error: error.message || 'Registration failed'
      })
    }
  }

  async login(req: Request, res: Response) {
    try {
      // Validate input
      const { email, password } = loginSchema.parse(req.body)

      // Login user
      const result = await authService.login(email, password)

      res.status(200).json({
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
      res.status(401).json({
        success: false,
        error: error.message || 'Login failed'
      })
    }
  }

  async refresh(req: Request, res: Response) {
    try {
      // Validate input
      const { refreshToken } = refreshSchema.parse(req.body)

      // Refresh token
      const result = await authService.refreshToken(refreshToken)

      res.status(200).json({
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
      res.status(401).json({
        success: false,
        error: error.message || 'Token refresh failed'
      })
    }
  }
}
