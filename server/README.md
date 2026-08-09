# Azanto Gym Node.js Express API Server

Production-grade Node.js + Express backend service for the Azanto Gym Application.

## Getting Started

### Prerequisites
- Node.js 18+ installed

### Setup & Run Server

1. **Install Dependencies**:
   ```bash
   cd server
   npm install
   ```

2. **Configure Environment Variables (`.env`)**:
   Copy `.env.example` to `.env` and update credentials:
   ```bash
   cp .env.example .env
   ```

3. **Start the API Server**:
   - Production Mode:
     ```bash
     npm start
     ```
   - Development Mode (with auto-reload):
     ```bash
     npm run dev
     ```

## API Routes Overview

- **Auth**: `/auth/api/v1` (Login, Register, Request OTP, Verify OTP, Reset Password, Refresh Token)
- **Gym & Branch**: `/gym-branch/api/v1` (Onboard Gym, Get/Update Gym, Upload Logo, Add/Get Branches, Branch Members)
- **Plans**: `/gym-branch/api/v1/plan` (Create Plan, Get All Plans, Plan Details, Update Plan)
- **Member & Profile**: `/profile/api/v1/member` (Search Member, Get/Update Profile, Upload/Get Avatar)
- **Attendance**: `/profile/api/v1/attendance` (Check-in, Check-out, My Attendance History)
- **Membership**: `/profile/api/v1/membership` (Enrolled Plan Status)
- **Workout**: `/profile/api/v1/workout` (Categories, Body Parts, Exercises, Tracking, Complete Exercise, Log History)
