const admin = require("firebase-admin");
const fs = require("fs");

const credPath = "D:\\Vibe Coding\\firebase_credentials.json";
if (!fs.existsSync(credPath)) {
  console.error(`Credentials file not found at ${credPath}. Cannot verify.`);
  process.exit(1);
}

const serviceAccount = require(credPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function verifySeeding() {
  console.log("Starting Seeding Diagnostics...");
  console.log("Fetching database collections...");

  const wardsSnap = await db.collection("wards").get();
  const issuesSnap = await db.collection("issues").get();
  const wishesSnap = await db.collection("wishes").get();
  const servicesSnap = await db.collection("emergency_services").get();
  const noticesSnap = await db.collection("notices").get();
  const alertsSnap = await db.collection("alerts").where("user_id", "==", "USR-ADYAR-01").get();

  const wards = wardsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  const issues = issuesSnap.docs.map(doc => doc.data());
  const wishes = wishesSnap.docs.map(doc => doc.data());
  const services = servicesSnap.docs.map(doc => doc.data());
  const notices = noticesSnap.docs.map(doc => doc.data());
  const alerts = alertsSnap.docs.map(doc => doc.data());

  console.log("----------------------------------------------------");
  console.log(`Summary of Total Documents in DB:`);
  console.log(`- Wards: ${wards.length}`);
  console.log(`- Issues: ${issues.length}`);
  console.log(`- Wishes: ${wishes.length}`);
  console.log(`- Emergency Services: ${services.length}`);
  console.log(`- Notices: ${notices.length}`);
  console.log(`- Alerts (USR-ADYAR-01): ${alerts.length}`);
  console.log("----------------------------------------------------");

  let hasErrors = false;

  for (const ward of wards) {
    const wId = ward.id;
    const wName = ward.ward_name || ward.name || "Unnamed";
    
    const wardIssues = issues.filter(i => i.ward_id === wId);
    const wardWishes = wishes.filter(w => w.ward_id === wId);
    const wardNotices = notices.filter(n => n.ward_id === wId);
    
    // Emergency services wards field is an array of ward_ids
    const wardServices = services.filter(s => s.ward_ids && s.ward_ids.includes(wId));
    const wardAlerts = alerts.filter(a => a.ward_id === wId);

    console.log(`Ward: ${wId} (${wName})`);
    console.log(`  - Issues: ${wardIssues.length}`);
    console.log(`  - Wishes: ${wardWishes.length}`);
    console.log(`  - Emergency Services: ${wardServices.length}`);
    console.log(`  - Notices: ${wardNotices.length}`);
    console.log(`  - Alerts: ${wardAlerts.length}`);

    if (wardIssues.length === 0) {
      console.error(`  [ERROR] Zero issues seeded for ward ${wId}`);
      hasErrors = true;
    }
    if (wardWishes.length === 0) {
      console.error(`  [ERROR] Zero wishes seeded for ward ${wId}`);
      hasErrors = true;
    }
    if (wardServices.length === 0) {
      console.error(`  [ERROR] Zero emergency services mapped for ward ${wId}`);
      hasErrors = true;
    }
    if (wardNotices.length === 0) {
      console.error(`  [ERROR] Zero notices seeded for ward ${wId}`);
      hasErrors = true;
    }
    if (wardAlerts.length === 0) {
      console.error(`  [ERROR] Zero alerts seeded for active user in ward ${wId}`);
      hasErrors = true;
    }
    console.log("");
  }

  console.log("----------------------------------------------------");
  if (hasErrors) {
    console.error("DIAGNOSTICS FAILED: Mapped coverage gaps detected!");
    process.exit(1);
  } else {
    console.log("DIAGNOSTICS PASSED: 100% full ward coverage confirmed!");
  }
}

verifySeeding().catch(err => {
  console.error("Verification error:", err);
  process.exit(1);
});
