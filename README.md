# 🔮 AURA OS — The World's Most Advanced AI Live Wallpaper App

<p align="center">
<img src="https://img.shields.io/badge/Platform-Android-green" />
<img src="https://img.shields.io/badge/Flutter-3.32-blue" />
<img src="https://img.shields.io/badge/FastAPI-0.109-teal" />
<img src="https://img.shields.io/badge/License-Proprietary-red" />
</p>

> Your phone, alive. Generate breathtaking AI wallpapers from text prompts. Animated, interactive, cinematic.

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🤖 **AI Generator** | Text-to-wallpaper with 12+ art styles |
| 🎬 **Live Animation Engine** | Particles, rain, snow, fire, fog, lightning, parallax |
| 📱 **Interactive** | Reacts to touch, tilt, charging, battery, music, weather |
| 🧠 **AI Director** | Chat assistant that crafts your perfect wallpaper |
| 🔒 **Lock + Home** | Synced lockscreen + homescreen ecosystems |
| 👥 **Social Feed** | TikTok-style feed, remix prompts, creator profiles |
| 💎 **Premium Tiers** | Free / Pro ($9.99) / Ultra ($19.99) |
| ⚡ **60fps Optimized** | Battery-aware, adaptive FPS, low RAM |

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│          FLUTTER APP (ARM64)        │
│  Generator │ Social │ WallpaperEng  │
│  AI Dir    │ Premium│ Particles     │
└─────────────────────────────────────┘
                  │ REST + WebSocket
┌─────────────────────────────────────┐
│       FASTAPI BACKEND (Python)      │
│  Auth │ AI │ Social │ Payments      │
└─────────────────────────────────────┘
            │           │
     ┌──────┴──┐  ┌─────┴────┐
     │PostgreSQL│  │  Redis   │
     └─────────┘  └──────────┘
             │
     ┌───────┴───────────┐
     │  GPU Workers      │
     │ (SDXL / ComfyUI)  │
     └───────────────────┘
```

## 📂 Project Structure

```
aura-os/
├── app/                          # Flutter mobile app
│   ├── lib/
│   │   ├── core/                 # Theme, constants, utils
│   │   ├── features/             # Onboarding, Generator, Social, etc.
│   │   ├── shared/               # Widgets, effects, animations
│   │   ├── models/               # Data models (Freezed)
│   │   ├── services/             # AI, Wallpaper, Subscription
│   │   └── main.dart
│   ├── android/                  # Native Android
│   │   └── kotlin/.../wallpaper/ # Live Wallpaper Service
│   └── web/                      # Web preview
├── backend/                      # FastAPI API
│   ├── app/
│   │   ├── api/v1/               # Routes (auth, ai, social, etc.)
│   │   ├── core/                 # Config, DB, auth
│   │   └── models/               # SQLAlchemy models
│   └── test_server.py            # Standalone test server (SQLite)
├── infra/
│   ├── docker/                   # Docker + Compose
│   └── k8s/                      # Kubernetes manifests
├── docs/
│   ├── ROADMAP.md                # 5-phase product roadmap
│   └── PLAY_STORE.md             # ASO + store listing
└── .github/workflows/build.yml   # CI/CD
```

## 🚀 Quick Start

### 1. Backend (test mode)
```bash
cd aura-os
python3 backend/test_server.py
# → http://localhost:8000/docs (Swagger UI)
```

### 2. Web Preview
```bash
cd aura-os/app/web
python3 -m http.server 8080
# → http://localhost:8080
```

### 3. Build APK (GitHub Actions)
```bash
git add -A && git commit -m "AURA OS v1.0"
git push origin main
# → Actions tab → Download APK artifact
```

### 4. Build APK (local)
```bash
cd app
flutter pub get
flutter build apk --release
# → build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## 📊 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/v1/auth/register` | Register new user |
| POST | `/v1/ai/generate` | Generate wallpaper from prompt |
| POST | `/v1/ai/enhance-prompt` | AI prompt enhancement |
| POST | `/v1/ai/director` | AI Director chat |
| GET | `/v1/ai/history` | Generation history |
| GET | `/v1/wallpapers` | Browse public wallpapers |
| GET | `/v1/social/feed` | Social feed |
| POST | `/v1/social/posts/{id}/like` | Like a post |
| GET | `/v1/users/me` | User profile |
| GET | `/v1/subscription/status` | Subscription info |

## 💰 Monetization

| | Free | Pro ($9.99/mo) | Ultra ($19.99/mo) |
|--|------|----------------|-------------------|
| Generations | 3/day | Unlimited | Unlimited |
| Quality | 1080p | 4K | 4K+ |
| Watermark | ✅ | ❌ | ❌ |
| Styles | 5 | All 12+ | All + Custom |
| AI Director | 1/day | Unlimited | Unlimited |
| Lockscreen | ❌ | ✅ | ✅ |
| API Access | ❌ | ❌ | ✅ |

## 📈 Roadmap

- **Phase 1** (Weeks 1-8): MVP — Generator + animations + wallpaper service
- **Phase 2** (Weeks 9-12): Polish — Social + interactive effects
- **Phase 3** (Weeks 13-16): Premium — Subscriptions + marketplace
- **Phase 4** (Weeks 17-20): Viral — TikTok export + referrals + challenges
- **Phase 5** (Weeks 21-28): Scale — Smartwatch + AR + API + enterprise

See [docs/ROADMAP.md](docs/ROADMAP.md) for the full plan.

## 📄 License

Proprietary. All rights reserved.
