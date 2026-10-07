# 🚀 Render Deployment Blueprint

## 🎓 Application: FuzzyLogic AI - Student Performance Predictor System

This blueprint provides step-by-step production deployment instructions for hosting the **Node.js Express Backend** and **PostgreSQL Database** on [Render.com](https://render.com), along with configuring the **Flutter Application** to communicate with the live production API.

---

## 🏗️ 1. Architecture Overview on Render

```text
               ┌────────────────────────────────────────────────┐
               │              Flutter Application               │
               │        (Android / iOS / Web / Desktop)         │
               └───────────────────────┬────────────────────────┘
                                       │ HTTPS REST API
                                       ▼
               ┌────────────────────────────────────────────────┐
               │           Render Web Service (Node.js)         │
               │  URL: https://fuzzylogic-api.onrender.com/api  │
               └───────────────────────┬────────────────────────┘
                                       │ Internal TCP / SSL
                                       ▼
               ┌────────────────────────────────────────────────┐
               │          Render PostgreSQL Database            │
               │          (fuzzy_student_db instance)           │
               └────────────────────────────────────────────────┘
```

---

## ⚡ Method A: 1-Click Infrastructure Deployment (`render.yaml`)

The repository includes a ready-to-use `backend/render.yaml` configuration file for automatic Blueprint deployment.

### Steps:
1. Push your project repository to GitHub / GitLab.
2. Log in to [Render Dashboard](https://dashboard.render.com).
3. Click **New +** -> **Blueprint**.
4. Connect your repository and select `backend/render.yaml`.
5. Render will automatically provision:
   - **Managed PostgreSQL Database**: `fuzzy_student_db`
   - **Express Web Service**: Node.js v22 environment listening on port 10000.
6. Click **Apply**. Render will automatically build and deploy both services!

---

## 🛠️ Method B: Manual Step-by-Step Render Setup

### Step 1: Create PostgreSQL Database on Render
1. Go to [Render Dashboard](https://dashboard.render.com) -> **New +** -> **PostgreSQL**.
2. Fill in details:
   - **Name**: `fuzzylogic-postgres-db`
   - **Database Name**: `fuzzy_student_db`
   - **User**: `postgres`
   - **Region**: Singapore / Frankfurt / Oregon
   - **Plan**: Free
3. Click **Create Database**.
4. Once created, copy the **Internal Database URL** (e.g. `postgres://postgres:password@dpg-xxx-a:5432/fuzzy_student_db`).

---

### Step 2: Create Web Service for Node.js Backend
1. Go to Render Dashboard -> **New +** -> **Web Service**.
2. Connect your Git Repository.
3. Configure the settings:
   - **Name**: `fuzzylogic-student-predictor-api`
   - **Root Directory**: `backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `node src/server.js`
   - **Plan**: Free
4. Add **Environment Variables**:

| Key | Value | Description |
| :--- | :--- | :--- |
| `NODE_ENV` | `production` | Enables SSL & optimizations |
| `PORT` | `10000` | Render standard port |
| `JWT_SECRET` | `fuzzy_logic_secret_key_student_performance_2026_super_secure` | Secret for signing JWTs |
| `JWT_EXPIRES_IN` | `7d` | Token validity |
| `DATABASE_URL` | *(Internal Database URL from Step 1)* | PostgreSQL connection string |

5. Click **Create Web Service**.

---

### Step 3: Seed Production Database on Render
Once the backend service status is `Live`:
1. In the Render Dashboard, click your Web Service (`fuzzylogic-student-predictor-api`).
2. Go to the **Shell** tab on the left menu.
3. Run the seed command inside the Render shell:
   ```bash
   node src/seed.js
   ```
4. Output will confirm:
   ```text
   Seeding demo student and prediction records...
   Connected to PostgreSQL database: fuzzy_student_db
   Database tables verified/created successfully.
   Created user: Rahul Sharma (rahul@student.edu)
   [SEED] Sample Case (Rahul) -> Score: 88.62% | Level: Very Good | Risk: Very Low Risk
   Seeding completed successfully!
   ```

---

## 📱 3. Connecting Flutter Application to Render Backend

Update `baseUrl` in `c:\Fuzzy\flutter_app\lib\services\api_service.dart` to point to your live Render backend URL:

```dart
class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'https://fuzzylogic-student-predictor-api.onrender.com/api';
    return 'https://fuzzylogic-student-predictor-api.onrender.com/api';
  }
  ...
}
```

---

## 🌐 4. Deploying Flutter Web Application (Optional)

You can also host the Flutter Web build directly on Render as a Static Site!

### Build Command:
```bash
cd flutter_app
flutter build web --release
```

### Render Static Site Setup:
1. Render Dashboard -> **New +** -> **Static Site**.
2. Root Directory: `flutter_app`
3. Build Command: `flutter/bin/flutter build web --release`
4. Publish Directory: `flutter_app/build/web`

---

## ✅ Deployment Checklist

- [x] Onboarding screens configured in Flutter (`OnboardingScreen`)
- [x] Application name set to **FuzzyLogic AI - Student Performance Predictor**
- [x] SSL connection enabled for production PostgreSQL (`rejectUnauthorized: false`)
- [x] Health check endpoint active at `/api/health`
- [x] `render.yaml` infrastructure-as-code file created
- [x] Database auto-migration & auto-seeding enabled
