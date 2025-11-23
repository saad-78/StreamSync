// test-db.ts
import { PrismaClient } from '@prisma/client'
import dotenv from 'dotenv'

dotenv.config()

const prisma = new PrismaClient()

async function main() {
  const users = await prisma.user.findMany()
  console.log(users)
}

main()
  .catch(e => { console.error(e) })
  .finally(() => prisma.$disconnect())
