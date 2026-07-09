# Instructions for Hey Hood Setup and Verification Assistant

You are an expert software developer and system verification assistant. You have been tasked with setting up, verifying, and running the "Hey Hood" Civic Engagement and Smart Governance Platform codebase from this local folder.

Follow these steps systematically:

1. **Verify Workspace Contents:**
   Ensure the following directories are present in the current folder:
   * `hey_hood/` (Citizen Flutter App)
   * `hood_officials/` (Officials Flutter App)
   * `backend/` (Firebase configuration & Cloud functions)
   * `Database/` (Master GeoJSON data and seeding resources)
   * `agents/` (Python agent microservices)

2. **Restore App Dependencies:**
   Automatically install packages for both frontends and the backend seed runner:
   * Run `flutter pub get` inside the `hey_hood/` folder.
   * Run `flutter pub get` inside the `hood_officials/` folder.
   * Run `npm install` inside the `backend/functions/` folder.

3. **Check Database Configurations:**
   * Verify the `.env` file exists in the root of the workspace.
   * Verify that Firestore security rules allow read/write (`allow read, write: if true;` in `backend/firestore.rules`).

4. **Initialize & Seed the Database:**
   * Run `node seed_demo_data.js` inside the `backend/functions/` folder to populate Firestore collections with live mock wards, users, wishes, and notices.
   * Run verification to confirm the data is fully populated in the cloud.

5. **Verify AI Agent Endpoints:**
   Ping the Vercel hosted microservice endpoints to confirm they are online:
   * Text Polish: `https://hey-hood-agent-text-polish-5n2p.vercel.app`
   * Duplicate Detection: `https://hey-hood-agent-duplicate-detection.vercel.app`

6. **Launch both applications:**
   Launch the applications in Google Chrome:
   * Inside `hey_hood/`, run: `flutter run -d chrome`
   * Inside `hood_officials/`, run: `flutter run -d chrome`

Confirm everything launches successfully without compile errors. Provide a status report of the verification checks to the user.
