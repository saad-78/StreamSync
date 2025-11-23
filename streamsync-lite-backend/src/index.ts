import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import dotenv from 'dotenv'
import authRoutes from './routes/auth.routes'
import videoRoutes from './routes/video.routes'
import notificationRoutes from './routes/notification.routes' 

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000

app.use(helmet())
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}))

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'StreamSync Lite API'
  })
})

// API routes
app.use('/api/auth', authRoutes)
app.use('/api/videos', videoRoutes)
app.use('/api/notifications', notificationRoutes) 

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found'
  })
})

app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err)
  res.status(err.status || 500).json({
    success: false,
    error: err.message || 'Internal server error'
  })
})

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`)
  console.log(`📍 Health: http://localhost:${PORT}/health`)
  console.log(`🔐 Auth: http://localhost:${PORT}/api/auth`)
  console.log(`🎥 Videos: http://localhost:${PORT}/api/videos`)
  console.log(`🔔 Notifications: http://localhost:${PORT}/api/notifications`)
})

export default app
