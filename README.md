# 🗺️ Hey Hood — Civic Engagement & Smart Governance Platform

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Release%20APKs-orange?style=for-the-badge&logo=flutter" alt="Flutter Release APKs"/>
  <img src="https://img.shields.io/badge/Firebase-Firestore%20Active-yellow?style=for-the-badge&logo=firebase" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Agents-Vercel%20%26%20Railway-blue?style=for-the-badge&logo=vercel" alt="AI Agents"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>
</p>

---

## 🌟 Overview
**Hey Hood** is a next-generation local governance and citizen empowerment platform. It bridges the gap between local residents and ward officials using real-time Firestore synchronization and a fleet of autonomous **AI Agents** that handle moderation, duplicate detection, category routing, wish fulfillment, and automated escalations.

---

## 📸 Screenshots & Visual Assets

<p align="center">
  <img src="screenshots/area_detail_screen.png" width="35%" alt="Area Detail Screen" />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="screenshots/news_short_detail.png" width="35%" alt="News Detail Screen" />
</p>

### 🎨 Custom AI-Generated Illustrations
<p align="center">
  <img src="screenshots/ambulance.png" width="25%" alt="Ambulance" />
  <img src="screenshots/fire_station.png" width="25%" alt="Fire Station" />
  <img src="screenshots/bus_stop.png" width="25%" alt="Bus Stop" />
</p>

---

## 📱 Download the Apps (Release APKs)
Ready-to-use binaries are included directly in the root of this repository:

* 👤 **[hey_hood.apk](file:///D:/Vibe%20Coding/hey_hood.apk)** (58.1 MB) — **Citizen Platform:** Report issues, post neighborhood wishes, view emergency contacts, check local notices, and view AI-generated visual previews of community suggestions.
* 👮 **[hood_officials.apk](file:///D:/Vibe%20Coding/hood_officials.apk)** (54.2 MB) — **Officials Dashboard:** View incoming issues, manage status updates (In Progress, Resolved), publish official ward notices, and track ward satisfaction metrics.

---

## 🤖 AI Agents & Cloud Ecosystem
The platform utilizes a microservice architecture of specialized, hosted AI agents running in the cloud:

| Agent Name | Purpose | Cloud Endpoint |
| :--- | :--- | :--- |
| ✨ **Text Polish Agent** | Cleans up and structures raw citizen inputs. | `https://hey-hood-agent-text-polish-5n2p.vercel.app` |
| 🔍 **Duplicate Detector** | Identifies similar active civic complaints to prevent duplication. | `https://hey-hood-agent-duplicate-detection.vercel.app` |
| 🔀 **Issue Router** | Categorizes and assigns issues to appropriate ward officials. | `https://hey-hood-agent-issue-routing.vercel.app` |
| 🚨 **Escalation Agent** | Automatically escalates unresolved complaints if deadlines pass. | `https://hey-hood-agent-escalation.vercel.app` |
| 🛑 **Fake News Verifier** | Moderates reports with mismatched text/images. | `https://hey-hood-agent-fake-news.vercel.app` |
| 🎯 **Wish Matcher** | Correlates citizen community wishes with ward budgets. | `https://hey-hood-agent-wish-matching.vercel.app` |

---

## 🛠️ Project Structure

```text
hey-hood/
├── agents/                           # Local Python LLM agent microservices
│   ├── duplicate_detection/          # Agent that identifies matching/similar citizen complaints
│   ├── escalation/                   # Agent that escalates overdue issues to higher officials
│   ├── fake_news/                    # Agent that moderates mismatched report images and text
│   ├── issue_routing/                # Agent that automatically routes issues to the right department
│   ├── shared/                       # Shared utility functions and database connections for agents
│   ├── text_polish/                  # Agent that edits and polishes citizen descriptions
│   └── wish_matching/                # Agent that aligns citizen wishes with ward facilities
├── backend/                          # Firebase Backend deployment configuration
│   ├── functions/                    # Cloud functions and database seeding scripts
│   ├── .firebaserc                   # Firebase project active target configuration
│   ├── firebase.json                 # Firebase deployment configurations and rewrites
│   └── firestore.rules               # Security rules configuration for Firestore database
├── Database/                         # Master database setup, schemas, and seeding resources
│   ├── geo_data/                     # Chennai and Virudhunagar ward boundary coordinates
│   ├── seed_data/                    # Initial mocks for users, issues, wishes, and notices
│   ├── seed_scripts/                 # Automated seeding script for Firestore setup
│   ├── dummy_credentials.json        # Placeholder Firebase service credentials for local tests
│   └── firestore.rules               # Copy of current active database security rules
├── hey_hood/                         # Citizen App Flutter codebase
│   ├── android/                      # Native Android build configurations and platform setup
│   ├── assets/                       # Custom logos, icons, and static graphics
│   ├── lib/                          # Main Flutter application logic, screens, and models
│   └── pubspec.yaml                  # Citizen app package and asset dependencies
├── hood_officials/                   # Officials App Flutter codebase
│   ├── android/                      # Native Android build configurations and platform setup
│   ├── assets/                       # Custom logos, icons, and static graphics
│   ├── lib/                          # Main Flutter application logic, screens, and models
│   └── pubspec.yaml                  # Officials app package and asset dependencies
├── screenshots/                      # UI preview captures and custom visuals for documentation
├── .gitignore                        # Git ignore patterns for build folders and secrets
├── hey_hood.apk                      # Ready-to-install Android release build for citizens
├── hood_officials.apk                # Ready-to-install Android release build for officials
└── README.md                         # Project documentation and ecosystem architecture details
```

---

## ⚙️ Quick Start Guide

### Running Citizen App
```bash
cd hey_hood
flutter run -d chrome  # Or run on connected Android/iOS device
```

### Running Officials App
```bash
cd hood_officials
flutter run -d chrome  # Or run on connected Android/iOS device
```

### Seeding Firestore Data
```bash
cd backend/functions
node seed_demo_data.js
```

---

## 🎨 System Architecture

<p align="center">
  <img src="screenshots/hey_hood_architecture.png" width="90%" alt="Hey Hood Architecture Diagram" />
</p>

---
<p align="center">Made with ❤️ for smart, transparent, and responsive local governance.</p>
