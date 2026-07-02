const functions = require("firebase-functions");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { spawn } = require("child_process");

initializeApp();

const INJECTION_PATTERNS = [
  /ignore previous instructions/i,
  /bypass/i,
  /auto.?approve/i,
  /override rules/i,
  /forget your instructions/i,
  /you are now/i
];

async function runSecurityCheckpoint(db, data) {
  let title = data.title || "";
  let description = data.description || "";
  let text = title + " " + description;
  
  // PII Redaction
  text = text.replace(/\b\d{12}\b/g, '[REDACTED-AADHAAR]');
  text = text.replace(/(\+91)?[6-9]\d{9}/g, '[REDACTED-PHONE]');
  text = text.replace(/\S+@\S+\.\S+/g, '[REDACTED-EMAIL]');
  
  // Injection Detection
  let flagged = false;
  for (const pattern of INJECTION_PATTERNS) {
    if (pattern.test(text)) {
      flagged = true;
      break;
    }
  }
  
  if (flagged) {
    console.warn("Security Checkpoint: Injection detected! Logging event.");
    await db.collection("security_events").add({
      event_type: "prompt_injection",
      input_data: data,
      flagged_text: text,
      timestamp: new Date().toISOString()
    });
    return { flagged: true, text };
  }
  
  return { flagged: false, text };
}

// Fallback logic for Duplicate Detection
async function fallbackDuplicateDetection(db, issueId, issue) {
  const wardId = issue.ward_id;
  const category = issue.category;
  if (!wardId || !category) return false;
  
  const existingDocs = await db.collection("issues")
    .where("ward_id", "==", wardId)
    .where("category", "==", category)
    .where("status", "!=", "Resolved")
    .limit(5)
    .get();
    
  let duplicateOf = null;
  existingDocs.forEach(doc => {
    if (doc.id !== issueId) {
      const data = doc.data();
      const titleOverlap = checkWordOverlap(issue.title, data.title);
      if (titleOverlap > 0.6) {
        duplicateOf = doc.id;
      }
    }
  });
  
  if (duplicateOf) {
    console.log(`Fallback: Marked ${issueId} as duplicate of ${duplicateOf}`);
    await db.collection("issues").doc(duplicateOf).update({
      support_count: require("firebase-admin/firestore").FieldValue.increment(1)
    });
    await db.collection("issues").doc(issueId).update({
      status: "Duplicate",
      duplicate_of: duplicateOf
    });
    return true;
  }
  return false;
}

// Fallback logic for Issue Routing
async function fallbackIssueRouting(db, issueId, issue) {
  console.log(`Running fallback routing for ${issueId}`);
  const wardId = issue.ward_id || "TN-CHN-100";
  const severity = issue.severity || "Medium";
  
  const wardDoc = await db.collection("wards").doc(wardId).get();
  let assignedTo = "GCC-WC-100";
  let assignedRole = "Ward Councillor";
  
  if (wardDoc.exists) {
    const wardData = wardDoc.data();
    if (wardData.councillor_id) {
      assignedTo = wardData.councillor_id;
    }
  }
  
  let hours = 168;
  if (severity === "Emergency") hours = 24;
  else if (severity === "High") hours = 72;
  else if (severity === "Low") hours = 336;
  
  const deadline = new Date();
  deadline.setHours(deadline.getHours() + hours);
  
  await db.collection("issues").doc(issueId).update({
    assigned_to: assignedTo,
    assigned_role: assignedRole,
    resolution_deadline: deadline.toISOString(),
    status: "Notified",
    timeline: require("firebase-admin/firestore").FieldValue.arrayUnion({
      status: "Notified",
      timestamp: new Date().toISOString()
    })
  });
  
  await db.collection("alerts").add({
    user_id: assignedTo,
    type: "New Issue Assigned",
    title: "New Issue Assigned",
    description: `New ${severity} issue: ${issue.title || "No Title"}`,
    issue_id: issueId,
    read: false,
    created_at: new Date().toISOString()
  });
}

// Fallback logic for Wish Matching
async function fallbackWishMatching(db, wishId, wish) {
  const wardId = wish.ward_id;
  const category = wish.category;
  if (!wardId || !category) return;
  
  const existingDocs = await db.collection("wishes")
    .where("ward_id", "==", wardId)
    .where("category", "==", category)
    .where("status", "==", "Active")
    .limit(5)
    .get();
    
  let matchingWishId = null;
  existingDocs.forEach(doc => {
    if (doc.id !== wishId) {
      const data = doc.data();
      const titleOverlap = checkWordOverlap(wish.title, data.title);
      if (titleOverlap > 0.6) {
        matchingWishId = doc.id;
      }
    }
  });
  
  if (matchingWishId) {
    console.log(`Fallback: Clustered ${wishId} with ${matchingWishId}`);
    await db.collection("wishes").doc(matchingWishId).update({
      support_count: require("firebase-admin/firestore").FieldValue.increment(1)
    });
    await db.collection("wishes").doc(wishId).update({
      status: "Duplicate",
      cluster_id: matchingWishId
    });
  }
}

function checkWordOverlap(str1, str2) {
  if (!str1 || !str2) return 0;
  const words1 = new Set(str1.toLowerCase().split(/\s+/));
  const words2 = new Set(str2.toLowerCase().split(/\s+/));
  const intersection = new Set([...words1].filter(w => words2.has(w)));
  return intersection.size / Math.max(words1.size, words2.size);
}

// TRIGGER 1: New issue created → run duplicate detection then routing if unique
exports.onIssueCreated = functions.firestore
  .document("issues/{issueId}")
  .onCreate(async (snap, context) => {
    const issue = snap.data();
    const issueId = context.params.issueId;
    const db = getFirestore();
    
    console.log(`New issue created: ${issueId}`);
    
    const agentInput = JSON.stringify({
      ...issue,
      issue_id: issueId
    });
    
    try {
      console.log(`Spawning duplicate detection for issue ${issueId}`);
      await runAgent(
        "D:\\Vibe Coding\\agents\\duplicate_detection",
        agentInput
      );
    } catch (err) {
      console.warn("Agent run failed, using Node.js Fallback for duplicate detection:", err.message);
      
      const secResult = await runSecurityCheckpoint(db, {
        title: issue.title,
        description: issue.description,
        issue_id: issueId,
        ward_id: issue.ward_id,
        category: issue.category
      });
      if (secResult.flagged) {
        console.log(`Issue ${issueId} flagged by security checkpoint. Exiting.`);
        return;
      }
      
      const isDuplicate = await fallbackDuplicateDetection(db, issueId, issue);
      if (isDuplicate) return;
    }

    // Refresh issue doc from Firestore to see if it was marked as duplicate
    const refreshedDoc = await db.collection("issues").doc(issueId).get();
    const refreshedData = refreshedDoc.data();

    if (refreshedData && (refreshedData.status === "Duplicate" || refreshedData.status === "Flagged")) {
      console.log(`Issue ${issueId} is duplicate/flagged. Skipping routing.`);
      return;
    }

    try {
      console.log(`Spawning issue routing for unique issue ${issueId}`);
      await runAgent(
        "D:\\Vibe Coding\\agents\\issue_routing",
        agentInput
      );
    } catch (err) {
      console.warn("Agent run failed, using Node.js Fallback for routing:", err.message);
      await fallbackIssueRouting(db, issueId, issue);
    }
  });

// TRIGGER 2: Issue marked resolved → update official score
exports.onIssueResolved = functions.firestore
  .document("issues/{issueId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const issueId = context.params.issueId;
    
    if (before.status !== "Resolved" && after.status === "Resolved") {
      console.log(`Issue ${issueId} resolved. Updating official statistics.`);
      const db = getFirestore();
      const officialId = after.assigned_to;
      
      if (officialId) {
        // Increment issues_resolved and accountability_score
        await db.collection("officials")
          .doc(officialId)
          .update({
            issues_resolved: require("firebase-admin/firestore").FieldValue.increment(1),
            accountability_score: require("firebase-admin/firestore").FieldValue.increment(3)
          });
          
        console.log(`Successfully updated statistics for official: ${officialId}`);
        
        // Notify all supporters of this issue
        const supporters = after.supporters || [];
        for (const userId of supporters) {
          await db.collection("alerts").add({
            user_id: userId,
            type: "Issue Resolved",
            title: "Issue Resolved ✓",
            description: `The issue "${after.title}" you supported has been resolved.`,
            issue_id: issueId,
            read: false,
            created_at: new Date().toISOString()
          });
        }
      }
    }
  });

// TRIGGER 3: New wish created → run wish matching agent
exports.onWishCreated = functions.firestore
  .document("wishes/{wishId}")
  .onCreate(async (snap, context) => {
    const wish = snap.data();
    const wishId = context.params.wishId;
    const db = getFirestore();
    
    console.log(`New wish created: ${wishId}`);
    
    const agentInput = JSON.stringify({
      ...wish,
      wish_id: wishId
    });
    
    try {
      console.log(`Spawning wish matching for wish ${wishId}`);
      await runAgent(
        "D:\\Vibe Coding\\agents\\wish_matching",
        agentInput
      );
    } catch (err) {
      console.warn("Agent run failed, using Node.js Fallback for wish matching:", err.message);
      
      const secResult = await runSecurityCheckpoint(db, {
        title: wish.title,
        description: wish.description,
        wish_id: wishId,
        ward_id: wish.ward_id,
        category: wish.category
      });
      if (secResult.flagged) {
        console.log(`Wish ${wishId} flagged by security checkpoint. Exiting.`);
        return;
      }
      
      await fallbackWishMatching(db, wishId, wish);
    }
  });

// SCHEDULED TRIGGER: Escalation agent runs every 6 hours
exports.scheduledEscalation = functions.pubsub
  .schedule("every 6 hours")
  .onRun(async (context) => {
    console.log("Running scheduled escalation agent...");
    try {
      await runAgent(
        "D:\\Vibe Coding\\agents\\escalation",
        JSON.stringify({ trigger: "scheduled" })
      );
    } catch (err) {
      console.warn("Scheduled escalation agent run failed:", err.message);
    }
  });

async function runAgent(agentPath, inputJson) {
  return new Promise((resolve, reject) => {
    const proc = spawn("uv", [
      "run", "agents-cli", "run",
      "--input", inputJson
    ], {
      cwd: agentPath,
      shell: true,
      env: {
        ...process.env,
        GEMINI_API_KEY: process.env.GEMINI_API_KEY,
        GOOGLE_GENAI_USE_ENTERPRISE: "FALSE"
      }
    });
    
    let stdout = "";
    let stderr = "";
    
    proc.stdout.on("data", (data) => {
      stdout += data.toString();
    });
    
    proc.stderr.on("data", (data) => {
      stderr += data.toString();
    });
    
    proc.on("close", (code) => {
      console.log(`Agent execution output:\n${stdout}`);
      if (stderr) {
        console.error(`Agent execution error output:\n${stderr}`);
      }
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Agent failed with exit code: ${code}`));
      }
    });
  });
}
