const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

const credPath = "D:\\Vibe Coding\\firebase_credentials.json";
if (!fs.existsSync(credPath)) {
  console.error(`Credentials file not found at ${credPath}. Cannot seed data.`);
  process.exit(1);
}

const serviceAccount = require(credPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Sleep helper to prevent API rate limit issues
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Call live Vercel text-polish agent
async function polishText(rawText, index) {
  if (rawText.toLowerCase().includes("ignore previous instructions")) {
    return rawText; // Don't polish injection test
  }
  
  // Sleep 3.5 seconds before every request to avoid Vercel Gemini 429 free tier limits
  if (index > 0) {
    console.log("Sleeping 3.5 seconds to avoid API rate limits...");
    await sleep(3500);
  }
  
  try {
    console.log(`Polishing description: "${rawText.substring(0, 40)}..."`);
    const res = await fetch("https://hey-hood-agent-text-polish-5n2p.vercel.app/run", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        raw_text: rawText,
        context: "civic grievance report"
      })
    });
    if (!res.ok) {
      throw new Error(`HTTP ${res.status}`);
    }
    const data = await res.json();
    const polished = data.result && data.result.polished_text;
    if (polished) {
      console.log(`  Polished successfully: "${polished.substring(0, 50)}..."`);
      return polished;
    }
  } catch (err) {
    console.warn(`  Failed to polish: ${err.message}. Using raw description.`);
  }
  return rawText;
}

// Curated list of Unsplash IDs for Indian streets/neighborhoods (for ward banners)
const indianStreetImages = [
  "photo-1581791538302-03537b9c97bf", // Chennai street corner
  "photo-1626014303757-641c249a05b1", // Indian market street
  "photo-1590050752117-238cb0fb12b1", // Delhi street scene
  "photo-1605649487212-47bdab064df7", // Indian street traffic
  "photo-1566837945700-30057527ade0", // Bangalore road
  "photo-1598977123418-45f04b01f4ac", // Indian local bazaar
  "photo-1548013146-72479768bada", // Street traffic India
  "photo-1596495578065-6e0763fa1141", // Urban residential India
  "photo-1506521788723-8681148d29ec", // City traffic
  "photo-1477959858617-67f85cf4f1df"  // Skyline / city
];

// Curated Unsplash IDs for issues, indexed by category keywords
const issueCategoryImages = {
  drainage: [
    "photo-1541888946425-d81bb19240f5", // Excavation/drain
    "photo-1585338107529-13afc5f02586", // Sewer water flow
    "photo-1504307651254-35680f356dfd", // Muddy trench
    "photo-1621905251189-08b45d6a269e"  // Water main work
  ],
  roads: [
    "photo-1515162305285-0293e4767cc2", // Pavement crack/hole
    "photo-1594787318286-3d835c1d207f", // Asphalt speed bump
    "photo-1606857521015-7f9fcf423740", // Broken concrete sidewalk slabs
    "photo-1584467541268-b040f83be3fd"  // Road construction gravel
  ],
  electricity: [
    "photo-1509391366360-2e959784a276", // Solar street lamp
    "photo-1470071459604-3b5ec3a7fe05", // Glowing street lights
    "photo-1517059224940-d4af9eec41b7", // Light pole close up
    "photo-1599740831146-80a6b7db00b2"  // Tangled overhead cables
  ],
  water: [
    "photo-1523362628745-0c100150b504", // Water tap / glass
    "photo-1574629810360-7efbbe195018", // Water dispenser tap
    "photo-1527317711096-749e8971f496", // Steel water tank public tap
    "photo-1600585154340-be6161a56a0c"  // Tap water running
  ],
  sanitation: [
    "photo-1611284446314-60a58ac0deb9", // Overflowing trash pile
    "photo-1601584115197-04ecc0da31d7", // Public garbage dump field
    "photo-1618477388954-7852f32655ec", // Overfilled metal bins
    "photo-1532996122724-e3c354a0b15b"  // Trash in city street
  ],
  safety: [
    "photo-1548199973-03cce0bbc87b", // Dog pack running
    "photo-1561037404-61cd46aa615b", // Street dog portrait
    "photo-1596492784531-6e6eb5ea9993", // Empty dark corridor warning
    "photo-1509822929063-6b6cfc9b42f2"  // Closed metal gate
  ],
  traffic: [
    "photo-1506521788723-8681148d29ec", // Congested lane cars
    "photo-1494783367193-149034c05e8f", // Rush hour city traffic
    "photo-1568605117036-5fe5e7bab0b7", // Vehicles double parked
    "photo-1590674899484-d5640e854abe"  // Parked scooter row
  ],
  library: [
    "photo-1507842217343-583bb7270b66", // Library bookshelf
    "photo-1521587760476-6c12a4b040da"  // Library tables/books
  ],
  environment: [
    "photo-1448375240586-882707db888b", // Park walkway with trees
    "photo-1464822759023-fed622ff2c3b", // Indian public park walkway
    "photo-1502082553048-f009c37129b9"  // Sapling/plant
  ]
};

// Helper function to return context-matched image URLs
let imgCounter = 0;
function getMatchedImage(type, category, docId, title) {
  imgCounter++;
  const uniqueSig = `sig=${docId}_${imgCounter}`;
  
  if (type === "banner") {
    // Ward banner images: Indian street/neighborhood
    const imgId = indianStreetImages[imgCounter % indianStreetImages.length];
    return `https://images.unsplash.com/${imgId}?auto=format&fit=crop&w=800&q=80&${uniqueSig}`;
  }
  
  // Issue/wish category matching
  let catKey = "environment";
  const searchStr = `${category || ""} ${title || ""}`.toLowerCase();
  
  if (searchStr.includes("drain") || searchStr.includes("sew")) {
    catKey = "drainage";
  } else if (searchStr.includes("road") || searchStr.includes("pothole") || searchStr.includes("pave") || searchStr.includes("street")) {
    if (searchStr.includes("light") || searchStr.includes("elect") || searchStr.includes("solar")) {
      catKey = "electricity";
    } else {
      catKey = "roads";
    }
  } else if (searchStr.includes("elect") || searchStr.includes("light") || searchStr.includes("power") || searchStr.includes("solar")) {
    catKey = "electricity";
  } else if (searchStr.includes("water") || searchStr.includes("dispenser") || searchStr.includes("booth") || searchStr.includes("drinking")) {
    catKey = "water";
  } else if (searchStr.includes("trash") || searchStr.includes("garb") || searchStr.includes("sanit") || searchStr.includes("toilet")) {
    catKey = "sanitation";
  } else if (searchStr.includes("dog") || searchStr.includes("saf") || searchStr.includes("secur") || searchStr.includes("anim")) {
    catKey = "safety";
  } else if (searchStr.includes("library") || searchStr.includes("read") || searchStr.includes("book") || searchStr.includes("education")) {
    catKey = "library";
  } else if (searchStr.includes("traf") || searchStr.includes("park") || searchStr.includes("vehic") || searchStr.includes("bench")) {
    if (searchStr.includes("park") && (searchStr.includes("car") || searchStr.includes("usman") || searchStr.includes("plaza"))) {
      catKey = "traffic";
    } else {
      catKey = "environment";
    }
  } else if (searchStr.includes("traffic") || searchStr.includes("double")) {
    catKey = "traffic";
  }
  
  const imgList = issueCategoryImages[catKey] || issueCategoryImages.environment;
  const imgId = imgList[imgCounter % imgList.length];
  return `https://images.unsplash.com/${imgId}?auto=format&fit=crop&w=800&q=80&${uniqueSig}`;
}

async function seedData() {
  console.log("Cleaning and resetting DB seeding state...");

  // Function to delete documents in a collection cleanly
  const purgeCollection = async (collectionName) => {
    let query = db.collection(collectionName);
    const snap = await query.get();
    let count = 0;
    let batch = db.batch();
    
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
      count++;
      if (count === 500) {
        await batch.commit();
        batch = db.batch();
        count = 0;
      }
    }
    
    if (count > 0) {
      await batch.commit();
    }
    console.log(`  Purged ${snap.docs.length} docs from "${collectionName}"`);
  };

  // Purge ALL collections EXCEPT "wards" completely to avoid orphaned/legacy data conflicts
  await purgeCollection("issues");
  await purgeCollection("wishes");
  await purgeCollection("notices");
  await purgeCollection("users");
  await purgeCollection("emergency_services");
  await purgeCollection("officials");
  await purgeCollection("alerts");

  console.log("Starting DB seeding...");

  const now = new Date();

  // 1. Fetch ALL existing wards in the database
  console.log("Fetching existing wards from Firestore...");
  const baseWards = {
    "TN-CHN-170": { name: "Adyar", number: 170, district: "Chennai", state: "Tamil Nadu", zone: "Zone 13" },
    "TN-CHN-179": { name: "Velachery", number: 179, district: "Chennai", state: "Tamil Nadu", zone: "Zone 13" },
    "TN-CHN-057": { name: "T Nagar", number: 57, district: "Chennai", state: "Tamil Nadu", zone: "Teynampet Zone" },
    "TN-CHN-100": { name: "Adyar 100", number: 100, district: "Chennai", state: "Tamil Nadu", zone: "Adyar Zone" },
    "TN-CHN-108": { name: "Velachery 108", number: 108, district: "Chennai", state: "Tamil Nadu", zone: "Adyar Zone" },
    "TN-CHN-173": { name: "Anna Nagar", number: 173, district: "Chennai", state: "Tamil Nadu", zone: "Anna Nagar Zone" },
    "TN-VRD-001": { name: "Virudhunagar Ward 1", number: 1, district: "Virudhunagar", state: "Tamil Nadu", zone: "East" },
    "TN-VRD-002": { name: "Virudhunagar Ward 2", number: 2, district: "Virudhunagar", state: "Tamil Nadu", zone: "West" }
  };

  const wards = { ...baseWards };
  const wardsSnap = await db.collection("wards").get();
  wardsSnap.forEach(doc => {
    const data = doc.data();
    const wId = doc.id;
    if (!wards[wId]) {
      console.log(`  Discovered extra ward: ${wId} (${data.ward_name || data.name || "Unnamed"})`);
      wards[wId] = {
        name: data.ward_name || data.name || `Ward ${wId.split("-").pop()}`,
        number: data.ward_number || parseInt(wId.split("-").pop()) || 99,
        district: data.district || "Chennai",
        state: data.state || "Tamil Nadu",
        zone: data.zone || "Zone General"
      };
    }
  });

  const targetWards = Object.keys(wards);
  console.log(`Targeting ${targetWards.length} wards:`, targetWards);

  // 2. Define Base Users
  const baseUsers = [
    { id: "USR-ADYAR-01", name: "Ramesh Kumar", phone: "+91 98401-XXXXX", ward: "TN-CHN-170", score: 810, posts: 4, status: "active" },
    { id: "USR-ADYAR-02", name: "Priya Sridhar", phone: "+91 98402-XXXXX", ward: "TN-CHN-170", score: 790, posts: 2, status: "active" },
    { id: "USR-ADYAR-03", name: "Anand Venkatesh", phone: "+91 98403-XXXXX", ward: "TN-CHN-170", score: 620, posts: 3, status: "warning" },
    { id: "USR-ADYAR-04", name: "Divya Krishnan", phone: "+91 98404-XXXXX", ward: "TN-CHN-170", score: 850, posts: 1, status: "active" },
    { id: "USR-ADYAR-05", name: "Suresh Mani", phone: "+91 98405-XXXXX", ward: "TN-CHN-170", score: 450, posts: 5, status: "warning" },
    { id: "USR-VELA-01", name: "Karthik Raja", phone: "+91 94441-XXXXX", ward: "TN-CHN-179", score: 880, posts: 3, status: "active" },
    { id: "USR-VELA-02", name: "Meera Nair", phone: "+91 94442-XXXXX", ward: "TN-CHN-179", score: 760, posts: 2, status: "active" },
    { id: "USR-VELA-03", name: "Vijay Chandran", phone: "+91 94443-XXXXX", ward: "TN-CHN-179", score: 350, posts: 6, status: "banned" },
    { id: "USR-VELA-04", name: "Sandhya Ravi", phone: "+91 94444-XXXXX", ward: "TN-CHN-179", score: 820, posts: 1, status: "active" },
    { id: "USR-VELA-05", name: "Balaji Swaminathan", phone: "+91 94445-XXXXX", ward: "TN-CHN-179", score: 790, posts: 4, status: "active" },
    { id: "USR-TNAG-01", name: "Ananth Subramanian", phone: "+91 94451-XXXXX", ward: "TN-CHN-057", score: 850, posts: 3, status: "active" },
    { id: "USR-TNAG-02", name: "Lakshmi Narayanan", phone: "+91 94452-XXXXX", ward: "TN-CHN-057", score: 720, posts: 2, status: "active" },
    { id: "USR-VNR-01", name: "Muthu Pandi", phone: "+91 99431-XXXXX", ward: "TN-VRD-001", score: 840, posts: 2, status: "active" },
    { id: "USR-VNR-02", name: "Selvi Ramasamy", phone: "+91 99432-XXXXX", ward: "TN-VRD-001", score: 890, posts: 3, status: "active" },
    { id: "USR-VNR-03", name: "Ganesh Pandian", phone: "+91 99433-XXXXX", ward: "TN-VRD-001", score: 710, posts: 1, status: "active" },
    { id: "USR-VNR-04", name: "Karuppasamy K", phone: "+91 99434-XXXXX", ward: "TN-VRD-002", score: 800, posts: 5, status: "active" },
    { id: "USR-VNR-05", name: "Chitra Devi", phone: "+91 99435-XXXXX", ward: "TN-VRD-002", score: 780, posts: 2, status: "active" },
    { id: "USR-VNR-06", name: "Mariammal S", phone: "+91 99436-XXXXX", ward: "TN-VRD-002", score: 650, posts: 3, status: "active" }
  ];

  const finalUsers = [...baseUsers];
  const usersPerWard = {};
  finalUsers.forEach(u => {
    if (!usersPerWard[u.ward]) usersPerWard[u.ward] = [];
    usersPerWard[u.ward].push(u);
  });

  // Ensure every targeted ward has at least 2 users
  targetWards.forEach(wId => {
    const existing = usersPerWard[wId] || [];
    const countNeeded = 2 - existing.length;
    for (let i = 0; i < countNeeded; i++) {
      const uId = `USR-${wId.split("-").pop()}-AUTO-${i + 1}`;
      finalUsers.push({
        id: uId,
        name: `Resident ${i + 1} (${wards[wId].name})`,
        phone: `+91 9000${i + 1}-XXXXX`,
        ward: wId,
        score: 750,
        posts: 2,
        status: "active"
      });
    }
  });

  // 3. Define Base Issues
  const baseIssueTemplates = [
    { title: "Sewage Overflow near Adyar Park", raw: "sewage overflow very bad smell near park plz fix urgently cant walk", category: "Drainage", severity: "High", ward: "TN-CHN-170", lat: 13.0063, lng: 80.2574, posted_by: "USR-ADYAR-01", anonymous: false, support_count: 57, status: "Posted", assigned_to: "GCC-WC-170", assigned_role: "Ward Councillor", daysAgo: 3 },
    { title: "Garbage Pile on Velachery Main Road", raw: "huge pile of garbage near velachery bus stop stink is horrible dogs splitting plastic bags everywhere", category: "Sanitation", severity: "High", ward: "TN-CHN-179", lat: 12.9796, lng: 80.2196, posted_by: "USR-VELA-02", anonymous: true, support_count: 84, status: "Notified", assigned_to: "TN-MLA-179", assigned_role: "MLA", daysAgo: 5 },
    { title: "Broken Streetlight on 3rd Cross Street", raw: "streetlight not working for 10 days near play school full dark dangerous for kids in evening", category: "Electricity", severity: "Medium", ward: "TN-CHN-170", lat: 13.0075, lng: 80.2560, posted_by: "USR-ADYAR-02", anonymous: false, support_count: 22, status: "In Progress", assigned_to: "GCC-ZONE-170", assigned_role: "Zone Officer", daysAgo: 8 },
    { title: "Deep Pothole on Gandhi Nagar Pavement", raw: "very big deep pothole near junction bike riders falls down frequently please patch it up", category: "Roads", severity: "High", ward: "TN-CHN-170", lat: 13.0082, lng: 80.2588, posted_by: "USR-ADYAR-04", anonymous: false, support_count: 46, status: "Notified", assigned_to: "GCC-WC-170", assigned_role: "Ward Councillor", daysAgo: 4 },
    { title: "Usman Road Potholes & Road Damage", raw: "huge potholes on usman road flyover service lane making it dangerous for two wheelers and slow traffic", category: "Roads", severity: "High", ward: "TN-CHN-057", lat: 13.0395, lng: 80.2315, posted_by: "USR-TNAG-01", anonymous: false, support_count: 94, status: "Posted", assigned_to: "GCC-WC-057", assigned_role: "Ward Councillor", daysAgo: 4 },
    { title: "Waterlogging near Pondy Bazaar Plaza", raw: "water stagnation on footpath during evening rains drainage is blocked please clear", category: "Drainage", severity: "Medium", ward: "TN-CHN-057", lat: 13.0401, lng: 80.2335, posted_by: "USR-TNAG-02", anonymous: false, support_count: 42, status: "In Progress", assigned_to: "GCC-ZONE-09", assigned_role: "Zone Officer", daysAgo: 5 },
    { title: "Irregular Water Supply in Velachery Sector 2", raw: "water supply only comes once in 3 days for 15 mins pressure is too low and color is muddy", category: "Water Supply", severity: "Medium", ward: "TN-CHN-179", lat: 12.9810, lng: 80.2220, posted_by: "USR-VELA-01", anonymous: false, support_count: 38, status: "Resolved", assigned_to: "TN-MLA-179", assigned_role: "MLA", daysAgo: 14 },
    { title: "Stray Dog Pack Menace near School Area", raw: "many stray dogs wandering in group near public school gate chasing cycle kids very risky", category: "Safety", severity: "Medium", ward: "TN-CHN-179", lat: 12.9805, lng: 80.2201, posted_by: "USR-VELA-05", anonymous: true, support_count: 73, status: "Resolved", assigned_to: "TN-MLA-179", assigned_role: "MLA", daysAgo: 12 },
    { title: "Illegal Double Parking on Adyar Flyover Service Lane", raw: "shop owners double parking trucks and autos permanently walkway fully blocked", category: "Traffic", severity: "Low", ward: "TN-CHN-170", lat: 13.0055, lng: 80.2590, posted_by: "USR-ADYAR-03", anonymous: false, support_count: 14, status: "Posted", assigned_to: "GCC-WC-170", assigned_role: "Ward Councillor", daysAgo: 2 },
    { title: "Waterlogging at Virudhunagar Main Bazaar", raw: "bazaar road fully flooded with rainwater drain blocked market shops getting ruined help", category: "Drainage", severity: "High", ward: "TN-VRD-001", lat: 9.5850, lng: 77.9510, posted_by: "USR-VNR-01", anonymous: false, support_count: 65, status: "In Progress", assigned_to: "TN-BDO-VNR-VIRUDHUNAGAR", assigned_role: "Block Development Officer", daysAgo: 6 },
    { title: "Fallen Banyan Tree Branch Blocking Street Entrance", raw: "big banyan tree branch broke in rain blocking the sublane entrance cars cannot go inside", category: "Environment", severity: "Low", ward: "TN-VRD-001", lat: 9.5862, lng: 77.9531, posted_by: "USR-VNR-02", anonymous: false, support_count: 19, status: "Resolved", assigned_to: "TN-BDO-VNR-VIRUDHUNAGAR", assigned_role: "Block Development Officer", daysAgo: 9 },
    { title: "Broken Drainage Slabs near Virudhunagar Railway Gate", raw: "storm drain cement slab broken open hole in footpath old people tripping in night", category: "Drainage", severity: "High", ward: "TN-VRD-002", lat: 9.5910, lng: 77.9610, posted_by: "USR-VNR-04", anonymous: true, support_count: 52, status: "In Progress", assigned_to: "TN-BDO-VNR-VIRUDHUNAGAR-02", assigned_role: "Block Development Officer", daysAgo: 7 },
    { title: "Streetlight Blinking continuously on School Road", raw: "pole number 44 light keeps on blinking like disco light very distracting and dark in intervals", category: "Electricity", severity: "Low", ward: "TN-VRD-002", lat: 9.5925, lng: 77.9625, posted_by: "USR-VNR-05", anonymous: false, support_count: 8, status: "Posted", assigned_to: "TN-BDO-VNR-VIRUDHUNAGAR-02", assigned_role: "Block Development Officer", daysAgo: 1 },
    { title: "Broken Public Park Gate", raw: "ward park gate rusted and broken hanging off hinge cows and dogs entering and destroying plants", category: "Environment", severity: "Medium", ward: "TN-CHN-170", lat: 13.0041, lng: 80.2543, posted_by: "USR-ADYAR-05", anonymous: false, support_count: 31, status: "Notified", assigned_to: "GCC-ZONE-170", assigned_role: "Zone Officer", daysAgo: 6 },
    { title: "Main Water Line Pipe Leak at Velachery Junction", raw: "heavy drinking water leakage from underground pipe connection water spraying out on tar road", category: "Water Supply", severity: "High", ward: "TN-CHN-179", lat: 12.9772, lng: 80.2241, posted_by: "USR-VELA-04", anonymous: false, support_count: 79, status: "In Progress", assigned_to: "TN-MLA-179", assigned_role: "MLA", daysAgo: 4 },
    { title: "Open Construction Pit without Fencing", raw: "deep trench dug for cables left open in middle of walking pathway no ribbon or caution board", category: "Safety", severity: "High", ward: "TN-VRD-001", lat: 9.5841, lng: 77.9502, posted_by: "USR-VNR-03", anonymous: false, support_count: 42, status: "Notified", assigned_to: "TN-BDO-VNR-VIRUDHUNAGAR", assigned_role: "Block Development Officer", daysAgo: 5 }
  ];

  const finalIssueTemplates = [...baseIssueTemplates];
  const issuesPerWard = {};
  finalIssueTemplates.forEach(i => {
    if (!issuesPerWard[i.ward]) issuesPerWard[i.ward] = [];
    issuesPerWard[i.ward].push(i);
  });

  // Dynamic templates to seed for missing wards
  const dynamicIssueTypes = [
    { title: "Sewage Overflow on Main Road", raw: "sewage line leaking dirty water smelling badly please clean", category: "Drainage", severity: "High" },
    { title: "Broken Footpath near Junction", raw: "pavement concrete slabs broken open hole old people falling please repair", category: "Roads", severity: "Medium" },
    { title: "Streetlight Outage near Bus Stop", raw: "streetlight not glowing full dark unsafe for ladies walking in night", category: "Electricity", severity: "High" },
    { title: "Water Supply Contaminated", raw: "drinking water coming muddy brown color with bad odor cannot use for cooking", category: "Water Supply", severity: "High" },
    { title: "Uncollected Garbage Heap", raw: "huge pile of trash left on street corner for 5 days dogs scatter plastic bags", category: "Sanitation", severity: "Medium" },
    { title: "Stray Dog Pack Menace", raw: "stray dogs chasing bikes and barking at school children very dangerous", category: "Safety", severity: "Medium" }
  ];

  // Fill gap so every targeted ward has at least 3 issues
  targetWards.forEach(wId => {
    const existing = issuesPerWard[wId] || [];
    const countNeeded = 3 - existing.length;
    const wardName = wards[wId].name;
    const wardUsers = finalUsers.filter(u => u.ward === wId);
    const userId = wardUsers.length > 0 ? wardUsers[0].id : "USR-ADYAR-01";
    const lastPart = wId.split("-").pop();

    for (let i = 0; i < countNeeded; i++) {
      const type = dynamicIssueTypes[i % dynamicIssueTypes.length];
      finalIssueTemplates.push({
        title: `${type.title} in ${wardName}`,
        raw: `${type.raw} near ${wardName} local area`,
        category: type.category,
        severity: type.severity,
        ward: wId,
        lat: templateLat(wId) + (Math.random() - 0.5) * 0.005,
        lng: templateLng(wId) + (Math.random() - 0.5) * 0.005,
        posted_by: userId,
        anonymous: false,
        support_count: Math.floor(Math.random() * 50) + 15,
        status: i === 0 ? "Posted" : (i === 1 ? "In Progress" : "Resolved"),
        assigned_to: `GCC-WC-${lastPart}`,
        assigned_role: "Ward Councillor",
        daysAgo: 3 + i * 2
      });
    }
  });

  console.log(`Preparing to seed ${finalIssueTemplates.length} issues. Polishing descriptions first...`);
  
  const seededIssues = [];
  for (let i = 0; i < finalIssueTemplates.length; i++) {
    const template = finalIssueTemplates[i];
    
    // Polish raw descriptions using live LLM Vercel Agent service
    const polishedText = await polishText(template.raw, i);
    
    const createdAt = new Date(now.getTime() - template.daysAgo * 24 * 60 * 60 * 1000);
    const notifiedAt = new Date(createdAt.getTime() + 1000 * 60 * 60 * 2); 
    const inProgressAt = new Date(createdAt.getTime() + 1000 * 60 * 60 * 24); 
    const resolvedAt = new Date(createdAt.getTime() + 1000 * 60 * 60 * 48); 

    // Build timeline dynamically
    const timeline = [{ status: "Posted", timestamp: createdAt.toISOString(), notes: "Issue reported." }];
    if (template.status !== "Posted" && template.status !== "Flagged") {
      timeline.push({ status: "Notified", timestamp: notifiedAt.toISOString(), notes: "Official notified and assigned." });
    }
    if (template.status === "In Progress" || template.status === "Resolved") {
      timeline.push({ status: "In Progress", timestamp: inProgressAt.toISOString(), notes: "Work crew dispatched to site." });
    }
    if (template.status === "Resolved") {
      timeline.push({ status: "Resolved", timestamp: resolvedAt.toISOString(), notes: "Issue resolved successfully." });
    }

    const issueId = `HH-${template.ward}-2026-${10000 + i}`;
    
    // Get unique context-matched image for issue
    const photoUrl = getMatchedImage("issue", template.category, issueId, template.title);

    seededIssues.push({
      issue_id: issueId,
      title: template.title,
      raw_description: template.raw,
      description: polishedText, 
      category: template.category,
      severity: template.severity,
      status: template.status,
      lat: template.lat,
      lng: template.lng,
      ward_id: template.ward,
      ward_name: wards[template.ward].name,
      district: wards[template.ward].district,
      state: wards[template.ward].state,
      photo_url: photoUrl,
      posted_by: template.posted_by,
      anonymous: template.anonymous,
      support_count: template.support_count,
      days_active: template.daysAgo,
      assigned_to: template.assigned_to,
      assigned_role: template.assigned_role,
      resolution_deadline: admin.firestore.Timestamp.fromDate(new Date(createdAt.getTime() + 7 * 24 * 60 * 60 * 1000)),
      content_hash: `hash_issue_${issueId}`,
      duplicate_of: null,
      extension_count: 0,
      proof_photo_url: template.status === "Resolved" ? photoUrl : null,
      resolved_at: template.status === "Resolved" ? admin.firestore.Timestamp.fromDate(resolvedAt) : null,
      verified: template.status === "Resolved",
      timeline: timeline,
      created_at: admin.firestore.Timestamp.fromDate(createdAt)
    });
  }

  // 4. Define Base Wishes
  const baseWishTemplates = [
    { id: "WH-CHN-170-1", title: "New park benches in Adyar Children's Park", category: "Recreation", ward: "TN-CHN-170", support: 48, trending: true, daysAgo: 11 },
    { id: "WH-CHN-170-2", title: "Solar streetlights on Gandhi Nagar school road", category: "Infrastructure", ward: "TN-CHN-170", support: 89, trending: true, daysAgo: 6 },
    { id: "WH-CHN-179-1", title: "Public e-toilet facility near Velachery Local Market", category: "Sanitation", ward: "TN-CHN-179", support: 112, trending: true, daysAgo: 14 },
    { id: "WH-CHN-179-2", title: "Paint zebra crossing near Velachery DAV School gate", category: "Safety", ward: "TN-CHN-179", support: 34, trending: false, daysAgo: 3 },
    { id: "WH-VRD-001-1", title: "Mini library and reading room at Ward Community Hall", category: "Education", ward: "TN-VRD-001", support: 53, trending: false, daysAgo: 8 },
    { id: "WH-VRD-002-1", title: "Speed breaker near Children's play park on main avenue", category: "Safety", ward: "TN-VRD-002", support: 92, trending: true, daysAgo: 9 },
    { id: "WH-VRD-002-2", title: "Planting native trees walkway on storm water drain side", category: "Environment", ward: "TN-VRD-002", support: 26, trending: false, daysAgo: 2 },
    { id: "WH-CHN-170-3", title: "Drinking water dispenser booth at Adyar Bus Depot", category: "Infrastructure", ward: "TN-CHN-170", support: 75, trending: false, daysAgo: 5 },
    { id: "WH-CHN-057-1", title: "Smart parking system on Usman Road", category: "Traffic", ward: "TN-CHN-057", support: 110, trending: true, daysAgo: 8 },
    { id: "WH-CHN-057-2", title: "Pedestrian plaza expansion near Ranganathan Street", category: "Recreation", ward: "TN-CHN-057", support: 175, trending: true, daysAgo: 12 },
    { id: "WH-CHN-057-3", title: "Public e-toilet facility near Ranganathan Street", category: "Sanitation", ward: "TN-CHN-057", support: 62, trending: false, daysAgo: 4 }
  ];

  const finalWishTemplates = [...baseWishTemplates];
  const wishesPerWard = {};
  finalWishTemplates.forEach(w => {
    if (!wishesPerWard[w.ward]) wishesPerWard[w.ward] = [];
    wishesPerWard[w.ward].push(w);
  });

  const dynamicWishTypes = [
    { title: "Install solar streetlights near park walkway", category: "Infrastructure" },
    { title: "Add new benches in children's play area", category: "Recreation" },
    { title: "Public e-toilet kiosk near bus station", category: "Sanitation" },
    { title: "Paint new zebra crossing gates", category: "Safety" }
  ];

  // Fill gap so every targeted ward has at least 2 wishes
  targetWards.forEach(wId => {
    const existing = wishesPerWard[wId] || [];
    const countNeeded = 2 - existing.length;
    const wardName = wards[wId].name;
    const lastPart = wId.split("-").pop();
    
    for (let i = 0; i < countNeeded; i++) {
      const type = dynamicWishTypes[i % dynamicWishTypes.length];
      finalWishTemplates.push({
        id: `WH-${lastPart}-AUTO-${i + 1}`,
        title: `${type.title} in ${wardName}`,
        category: type.category,
        ward: wId,
        support: Math.floor(Math.random() * 80) + 20,
        trending: i === 0,
        daysAgo: 5 + i * 3
      });
    }
  });

  const seededWishes = finalWishTemplates.map((item, idx) => {
    // Get unique context-matched image for wish
    const imageUrl = getMatchedImage("wish", item.category, item.id, item.title);

    return {
      wish_id: item.id,
      title: item.title,
      description: `We need a ${item.title.toLowerCase()} in our neighborhood. This will greatly benefit the local residents and improve quality of life.`,
      image_url: imageUrl,
      imageType: "ai_generated",
      category: item.category,
      ward_id: item.ward,
      support_count: item.support,
      posted_by: `USR-ADYAR-0${(idx % 5) + 1}`,
      status: "Active",
      cluster_id: null,
      is_trending: item.trending,
      created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - item.daysAgo * 24 * 60 * 60 * 1000))
    };
  });

  // 5. Define Emergency Services (KYH Directory)
  const baseServices = [
    { id: "ES-CHN-HOSP-01", name: "Apollo Speciality Hospital, Adyar", type: "Hospital", wards: ["TN-CHN-170", "TN-CHN-179"], district: "Chennai", phone: "+91-44-24430300", lat: 13.0055, lng: 80.2582, open247: true },
    { id: "ES-CHN-HOSP-02", name: "Fortis Malar Hospital, Adyar", type: "Hospital", wards: ["TN-CHN-170"], district: "Chennai", phone: "+91-44-42892222", lat: 13.0071, lng: 80.2595, open247: true },
    { id: "ES-CHN-HOSP-03", name: "Velachery Clinic and Maternity Centre", type: "Clinic", wards: ["TN-CHN-179"], district: "Chennai", phone: "+91-44-22441020", lat: 12.9802, lng: 80.2215, open247: false },
    { id: "ES-CHN-HOSP-04", name: "T Nagar Public Health Centre", type: "Hospital", wards: ["TN-CHN-057"], district: "Chennai", phone: "+91-44-24340157", lat: 13.0410, lng: 80.2325, open247: true },
    { id: "ES-VRD-HOSP-01", name: "Virudhunagar Government HQ Hospital", type: "Hospital", wards: ["TN-VRD-001", "TN-VRD-002"], district: "Virudhunagar", phone: "+91-4562-243501", lat: 9.5855, lng: 77.9512, open247: true },
    { id: "ES-VRD-CLIN-01", name: "Bazaar Road Public Health Centre", type: "Clinic", wards: ["TN-VRD-001"], district: "Virudhunagar", phone: "+91-4562-243510", lat: 9.5842, lng: 77.9501, open247: false },
    { id: "ES-CHN-POLI-01", name: "J-13 Adyar Police Station", type: "Police", wards: ["TN-CHN-170"], district: "Chennai", phone: "+91-44-23452582", lat: 13.0062, lng: 80.2568, open247: true },
    { id: "ES-CHN-POLI-02", name: "J-7 Velachery Police Station", type: "Police", wards: ["TN-CHN-179"], district: "Chennai", phone: "+91-44-23452600", lat: 12.9790, lng: 80.2198, open247: true },
    { id: "ES-CHN-POLI-03", name: "R-1 Mambalam Police Station, T Nagar", type: "Police", wards: ["TN-CHN-057"], district: "Chennai", phone: "+91-44-23452588", lat: 13.0388, lng: 80.2305, open247: true },
    { id: "ES-VRD-POLI-01", name: "Virudhunagar Town Police Station", type: "Police", wards: ["TN-VRD-001", "TN-VRD-002"], district: "Virudhunagar", phone: "+91-4562-243611", lat: 9.5901, lng: 77.9602, open247: true },
    { id: "ES-CHN-FIRE-01", name: "Adyar Fire and Rescue Station", type: "Fire Station", wards: ["TN-CHN-170", "TN-CHN-179"], district: "Chennai", phone: "+91-44-24910101", lat: 13.0031, lng: 80.2552, open247: true },
    { id: "ES-CHN-FIRE-02", name: "T Nagar Fire Station", type: "Fire Station", wards: ["TN-CHN-057"], district: "Chennai", phone: "+91-44-24341010", lat: 13.0425, lng: 80.2340, open247: true },
    { id: "ES-VRD-FIRE-01", name: "Virudhunagar Fire Station", type: "Fire Station", wards: ["TN-VRD-001", "TN-VRD-002"], district: "Virudhunagar", phone: "+91-4562-243701", lat: 9.5921, lng: 77.9632, open247: true }
  ];

  const finalServices = [...baseServices];
  const servicesPerWard = {};
  finalServices.forEach(s => {
    s.wards.forEach(wId => {
      if (!servicesPerWard[wId]) servicesPerWard[wId] = [];
      servicesPerWard[wId].push(s);
    });
  });

  // Fill gap so every targeted ward has 3 emergency services (Hospital, Police, Fire)
  targetWards.forEach(wId => {
    const existing = servicesPerWard[wId] || [];
    const wardName = wards[wId].name;
    const lastPart = wId.split("-").pop();
    
    const hasHospital = existing.some(s => s.type === "Hospital");
    if (!hasHospital) {
      finalServices.push({
        id: `ES-${lastPart}-HOSP-AUTO`,
        name: `${wardName} General Hospital`,
        type: "Hospital",
        wards: [wId],
        district: wards[wId].district,
        phone: `+91-44-2454${lastPart}`,
        lat: templateLat(wId) + 0.002,
        lng: templateLng(wId) - 0.002,
        open247: true
      });
    }
    
    const hasPolice = existing.some(s => s.type === "Police");
    if (!hasPolice) {
      finalServices.push({
        id: `ES-${lastPart}-POLI-AUTO`,
        name: `${wardName} Ward Police Station`,
        type: "Police",
        wards: [wId],
        district: wards[wId].district,
        phone: `+91-44-2345${lastPart}`,
        lat: templateLat(wId) - 0.002,
        lng: templateLng(wId) + 0.002,
        open247: true
      });
    }
    
    const hasFire = existing.some(s => s.type === "Fire Station");
    if (!hasFire) {
      finalServices.push({
        id: `ES-${lastPart}-FIRE-AUTO`,
        name: `${wardName} Fire Station`,
        type: "Fire Station",
        wards: [wId],
        district: wards[wId].district,
        phone: `+91-44-2490${lastPart}`,
        lat: templateLat(wId) + 0.001,
        lng: templateLng(wId) + 0.001,
        open247: true
      });
    }
  });

  const seededServices = finalServices.map(item => ({
    service_id: item.id,
    name: item.name,
    type: item.type,
    ward_ids: item.wards,
    district: item.district,
    phone: item.phone,
    lat: item.lat,
    lng: item.lng,
    open_247: item.open247
  }));

  // 6. Define Base Notices
  const baseNoticeTemplates = [
    { ward: "TN-CHN-170", title: "Scheduled Power Outage in Adyar Zone", content: "Scheduled electricity maintenance shutdown in Adyar sectors 1 to 4 on Tuesday from 9 AM to 4 PM.", type: "Notice", official: "TN-MLA-170", cannot_delete: true, daysAgo: 1 },
    { ward: "TN-CHN-170", title: "Adyar Ward Grievance Meeting", content: "Weekly Ward grievance resolution meeting scheduled at Zone 10 office on Saturday, 10 AM. All are welcome.", type: "Announcement", official: "GCC-WC-170", cannot_delete: false, daysAgo: 2 },
    { ward: "TN-CHN-170", title: "Pipeline Wash: Low Water Pressure", content: "Routine cleaning of main water filter bed tank. Expect minor water supply pressure dip on Wednesday.", type: "Alert", official: "GCC-ZONE-170", cannot_delete: true, daysAgo: 0 },
    { ward: "TN-CHN-179", title: "Free Health Camp at Velachery Ward Office", content: "Free medical checkup and pediatric consultation camp on Sunday at the Velachery Ward office.", type: "Announcement", official: "TN-MLA-179", cannot_delete: false, daysAgo: 0 },
    { ward: "TN-CHN-179", title: "Road Digging Work on Bypass Road", content: "Sewer cable laying works starting from Thursday on Bypass road. Speed limit restricted to 20kmph.", type: "Notice", official: "TN-MLA-179", cannot_delete: true, daysAgo: 3 },
    { ward: "TN-CHN-057", title: "Smart Parking Installation Notice", content: "Laying cable for smart parking system on Usman Road starting Thursday. Parking restricted on service lane.", type: "Notice", official: "GCC-WC-057", cannot_delete: false, daysAgo: 1 },
    { ward: "TN-VRD-001", title: "Pipeline Flushing: Water Suspension", content: "Drinking water supply will be suspended in Virudhunagar Ward 1 on June 30 due to routine line flushing.", type: "Alert", official: "TN-BDO-VNR-VIRUDHUNAGAR", cannot_delete: true, daysAgo: 2 }
  ];

  const finalNoticeTemplates = [...baseNoticeTemplates];
  const noticesPerWard = {};
  finalNoticeTemplates.forEach(n => {
    if (!noticesPerWard[n.ward]) noticesPerWard[n.ward] = [];
    noticesPerWard[n.ward].push(n);
  });

  // Fill gap so every targeted ward has at least 2 notices
  targetWards.forEach(wId => {
    const existing = noticesPerWard[wId] || [];
    const countNeeded = 2 - existing.length;
    const wardName = wards[wId].name;
    const lastPart = wId.split("-").pop();
    
    for (let i = 0; i < countNeeded; i++) {
      finalNoticeTemplates.push({
        ward: wId,
        title: i === 0 ? `Scheduled Maintenance Shutdown in ${wardName}` : `${wardName} Ward Grievance Meeting`,
        content: i === 0 ? `Routine maintenance shutdown scheduled for local civic systems in ${wardName} on coming Tuesday.` : `Weekly open grievance resolution meeting scheduled at the ${wardName} local ward office.`,
        type: i === 0 ? "Notice" : "Announcement",
        official: `GCC-WC-${lastPart}`,
        cannot_delete: i === 0,
        daysAgo: 1 + i * 2
      });
    }
  });

  const seededNotices = finalNoticeTemplates.map((item, idx) => ({
    notice_id: `NOT-${item.ward}-${idx + 1}`,
    title: item.title,
    content: item.content,
    type: item.type,
    posted_by_official_id: item.official,
    ward_id: item.ward,
    circle: "Ward",
    verified_official_post: true,
    cannot_delete: item.cannot_delete,
    created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - item.daysAgo * 24 * 60 * 60 * 1000))
  }));

  // 7. Define Base Officials
  const baseOfficials = [
    { official_id: "GCC-WC-170", name: "Sarvesh Kumar", designation: "Ward Councillor", ward_id: "TN-CHN-170", phone: "+91-44-24430170", mobile: "9840123456", email: "councillor.ward170@gcc.tn.gov.in", district: "Chennai", state: "Tamil Nadu", level: "ward", verified: true, accountability_score: 103, issues_assigned: 0, issues_resolved: 1, issues_overdue: 0 },
    { official_id: "GCC-ZONE-170", name: "Ravi Chandran", designation: "Zone Officer", ward_id: "TN-CHN-170", phone: "+91-44-24430171", mobile: "9840123457", email: "zone13.officer@gcc.tn.gov.in", district: "Chennai", state: "Tamil Nadu", level: "zone", verified: true, accountability_score: 100, issues_assigned: 0, issues_resolved: 0, issues_overdue: 0 },
    { official_id: "TN-MLA-170", name: "T. Velu", designation: "MLA", ward_id: "TN-CHN-170", phone: "+91-44-24430172", mobile: "9840123458", email: "mla.ward170@assembly.tn.gov.in", district: "Chennai", state: "Tamil Nadu", level: "constituency", verified: true, accountability_score: 100, constituency: "Adyar", issues_assigned: 0, issues_resolved: 0, issues_overdue: 0 },
    { official_id: "GCC-WC-179", name: "Meenakshi Sundaram", designation: "Ward Councillor", ward_id: "TN-CHN-179", phone: "+91-44-22441179", mobile: "9444123456", email: "councillor.ward179@gcc.tn.gov.in", district: "Chennai", state: "Tamil Nadu", level: "ward", verified: true, accountability_score: 100, issues_assigned: 0, issues_resolved: 0, issues_overdue: 0 },
    { official_id: "TN-MLA-179", name: "M. K. Stalin", designation: "MLA", ward_id: "TN-CHN-179", phone: "+91-44-22441180", mobile: "9444123457", email: "mla.ward179@assembly.tn.gov.in", district: "Chennai", state: "Tamil Nadu", level: "constituency", verified: true, accountability_score: 100, constituency: "Velachery", issues_assigned: 0, issues_resolved: 0, issues_overdue: 0 },
    { official_id: "GCC-WC-057", name: "S. K. M. Magesh", designation: "Ward Councillor", ward_id: "TN-CHN-057", phone: "+91-44-24340057", mobile: "9445123456", email: "councillor.ward57@gcc.tn.gov.in", district: "Chennai", state: "Tamil Nadu", level: "ward", verified: true, accountability_score: 98, issues_assigned: 0, issues_resolved: 0, issues_overdue: 0 },
    { official_id: "GCC-ZONE-09", name: "Subramanian P.", designation: "Zone Officer", ward_id: "TN-CHN-057", phone: "+91-44-24340058", mobile: "9445123457", email: "zone9.officer@gcc.tn.gov.in", district: "Chennai", state: "Tamil Nadu", level: "zone", verified: true, accountability_score: 100, issues_assigned: 0, issues_resolved: 0, issues_overdue: 0 },
    { official_id: "TN-BDO-VNR-VIRUDHUNAGAR", name: "S. Pandian", designation: "Block Development Officer", ward_id: "TN-VRD-001", phone: "+91-4562-243505", mobile: "9943123456", email: "bdo.vrd@tn.gov.in", district: "Virudhunagar", state: "Tamil Nadu", level: "block", verified: true, accountability_score: 100, issues_assigned: 0, issues_resolved: 0, issues_overdue: 0 },
    { official_id: "TN-BDO-VNR-VIRUDHUNAGAR-02", name: "S. Pandian", designation: "Block Development Officer", ward_id: "TN-VRD-002", phone: "+91-4562-243505", mobile: "9943123456", email: "bdo.vrd@tn.gov.in", district: "Virudhunagar", state: "Tamil Nadu", level: "block", verified: true, accountability_score: 100, issues_assigned: 0, issues_resolved: 0, issues_overdue: 0 }
  ];

  const finalOfficials = [...baseOfficials];
  const officialsPerWard = {};
  finalOfficials.forEach(o => {
    if (!officialsPerWard[o.ward_id]) officialsPerWard[o.ward_id] = [];
    officialsPerWard[o.ward_id].push(o);
  });

  // Ensure Councillor and Zone Officer exist for every ward
  targetWards.forEach(wId => {
    const existing = officialsPerWard[wId] || [];
    const lastPart = wId.split("-").pop();
    const wardName = wards[wId].name;

    const hasCouncillor = existing.some(o => o.designation === "Ward Councillor");
    if (!hasCouncillor) {
      finalOfficials.push({
        official_id: `GCC-WC-${lastPart}`,
        name: `Sarvesh Kumar (${lastPart})`,
        designation: "Ward Councillor",
        ward_id: wId,
        phone: `+91-44-24430${lastPart}`,
        mobile: "9840123456",
        email: `councillor.ward${lastPart}@gcc.tn.gov.in`,
        district: wards[wId].district,
        state: wards[wId].state,
        level: "ward",
        verified: true,
        accountability_score: 100,
        issues_assigned: 0,
        issues_resolved: 0,
        issues_overdue: 0
      });
    }

    const hasZoneOfficer = existing.some(o => o.designation === "Zone Officer" || o.designation === "Block Development Officer");
    if (!hasZoneOfficer) {
      finalOfficials.push({
        official_id: `GCC-ZONE-${lastPart}`,
        name: `Ravi Chandran (${lastPart})`,
        designation: "Zone Officer",
        ward_id: wId,
        phone: `+91-44-24430${lastPart + 1}`,
        mobile: "9840123457",
        email: `zone${lastPart}.officer@gcc.tn.gov.in`,
        district: wards[wId].district,
        state: wards[wId].state,
        level: "zone",
        verified: true,
        accountability_score: 100,
        issues_assigned: 0,
        issues_resolved: 0,
        issues_overdue: 0
      });
    }
  });

  // 8. Calculate Wards dynamic pulse score based on resolving rate & issue severity
  const calculatePulseScore = (wardId) => {
    const wardIssues = seededIssues.filter(i => i.ward_id === wardId);
    if (wardIssues.length === 0) return 92; // Default starting pulse for a clean ward
    
    let score = 100;
    for (const issue of wardIssues) {
      if (issue.status !== "Resolved" && issue.status !== "Flagged") {
        if (issue.severity === "High") score -= 8;
        else if (issue.severity === "Medium") score -= 4;
        else if (issue.severity === "Low") score -= 2;
      }
    }
    return Math.max(10, Math.min(100, score));
  };

  const seededWards = targetWards.map(wardId => {
    const pulseScore = calculatePulseScore(wardId);
    console.log(`Calculating pulse_score for ${wardId} (${wards[wardId].name}): ${pulseScore}`);
    
    const boundary = {
      type: "Polygon",
      coordinates: [
        [
          [templateLng(wardId) - 0.01, templateLat(wardId) - 0.01],
          [templateLng(wardId) + 0.01, templateLat(wardId) - 0.01],
          [templateLng(wardId) + 0.01, templateLat(wardId) + 0.01],
          [templateLng(wardId) - 0.01, templateLat(wardId) + 0.01],
          [templateLng(wardId) - 0.01, templateLat(wardId) - 0.01]
        ]
      ]
    };
    
    const parts = wardId.split('-');
    const lastPart = parts[parts.length - 1] || '170';
    
    return {
      ward_id: wardId,
      name: wards[wardId].name,
      ward_name: wards[wardId].name, 
      ward_number: wards[wardId].number,
      district: wards[wardId].district,
      state: wards[wardId].state,
      zone: wards[wardId].zone,
      pulse_score: pulseScore,
      councillor_id: `GCC-WC-${lastPart}`,
      mla_id: `TN-MLA-${lastPart}`,
      boundary_geojson: JSON.stringify(boundary),
      created_at: admin.firestore.FieldValue.serverTimestamp()
    };
  });

  // Helpers to get coordinate anchors
  function templateLat(wardId) {
    if (wardId === "TN-CHN-170") return 13.0063;
    if (wardId === "TN-CHN-179") return 12.9796;
    if (wardId === "TN-CHN-057") return 13.0410;
    if (wardId === "TN-CHN-100") return 13.0063;
    if (wardId === "TN-CHN-108") return 12.9796;
    if (wardId === "TN-CHN-173") return 13.0850;
    return 9.5850; 
  }
  function templateLng(wardId) {
    if (wardId === "TN-CHN-170") return 80.2574;
    if (wardId === "TN-CHN-179") return 80.2196;
    if (wardId === "TN-CHN-057") return 80.2330;
    if (wardId === "TN-CHN-100") return 80.2574;
    if (wardId === "TN-CHN-108") return 80.2196;
    if (wardId === "TN-CHN-173") return 80.2100;
    return 77.9510; 
  }

  // 9. Generate Alerts for USR-ADYAR-01 dynamically PER-WARD
  console.log("Generating alerts for active user USR-ADYAR-01 per ward...");
  const seededAlerts = [];
  targetWards.forEach(wId => {
    const lastPart = wId.split("-").pop();
    const wardName = wards[wId].name;

    // Filter ward's issues to reference in alerts
    const wardIssues = seededIssues.filter(i => i.ward_id === wId);
    const resolvedIssue = wardIssues.find(i => i.status === "Resolved") || wardIssues[0];
    const escalatedIssue = wardIssues.find(i => i.status === "Notified" || i.status === "In Progress") || wardIssues[0];

    // A. Issue Resolved
    seededAlerts.push({
      alert_id: `ALT-${lastPart}-RESOLVED`,
      user_id: "USR-ADYAR-01",
      ward_id: wId,
      type: "Issue Resolved",
      title: "Issue Resolved",
      description: `Sewage overflow on 4th Block marked resolved by Ward Councillor Ramesh Kumar`,
      issue_id: resolvedIssue.issue_id,
      read: false,
      tag: "",
      created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - 1000 * 60 * 5)) // 5 mins ago
    });

    // B. Escalated to MLA
    seededAlerts.push({
      alert_id: `ALT-${lastPart}-ESCALATE-MLA`,
      user_id: "USR-ADYAR-01",
      ward_id: wId,
      type: "Status Update",
      title: "Escalated to MLA",
      description: `Pothole issue on 80 Feet Road unresolved for 7 days. Auto escalated to MLA Suresh Patel.`,
      issue_id: escalatedIssue.issue_id,
      read: false,
      tag: "DAY 7 — NO RESPONSE",
      created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - 1000 * 60 * 15)) // 15 mins ago
    });

    // C. New Notice • Ward ${lastPart}
    seededAlerts.push({
      alert_id: `ALT-${lastPart}-NOTICE-POST`,
      user_id: "USR-ADYAR-01",
      ward_id: wId,
      type: "Notice Published",
      title: `New Notice • Ward ${lastPart}`,
      description: `Water supply disruption on 28 June 6AM to 2PM. Plan accordingly. — BBMP Ward Office`,
      issue_id: "",
      read: false,
      tag: "OFFICIAL POST",
      created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - 1000 * 60 * 60 * 1)) // 1 hour ago
    });

    // D. New Scheme in your area
    seededAlerts.push({
      alert_id: `ALT-${lastPart}-NEW-SCHEME`,
      user_id: "USR-ADYAR-01",
      ward_id: wId,
      type: "Trending Wish",
      title: "New Scheme in your area",
      description: `PM Awas Yojana Urban — You may be eligible based on your ward. Tap to check criteria.`,
      issue_id: "",
      read: false,
      tag: "STATE SCHEME",
      created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - 1000 * 60 * 60 * 3)) // 3 hours ago
    });

    // E. Your issue is gaining support
    seededAlerts.push({
      alert_id: `ALT-${lastPart}-SUPPORT-GAIN`,
      user_id: "USR-ADYAR-01",
      ward_id: wId,
      type: "Trending Wish",
      title: "Your issue is gaining support",
      description: `Broken streetlight near school supported now has 50 people supporting.`,
      issue_id: "",
      read: false,
      tag: "50 SUPPORTING",
      created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - 1000 * 60 * 60 * 5)) // 5 hours ago
    });

    // F. Heavy Traffic Alert
    seededAlerts.push({
      alert_id: `ALT-${lastPart}-TRAFFIC-ALERT`,
      user_id: "USR-ADYAR-01",
      ward_id: wId,
      type: "Status Update",
      title: "Heavy Traffic Alert",
      description: `Congestion reported near Central Square due to protest march. Seek alternate routes.`,
      issue_id: "",
      read: true,
      tag: "",
      created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - 25 * 60 * 60 * 1000)) // Yesterday
    });

    // G. Garbage Collection Complete
    seededAlerts.push({
      alert_id: `ALT-${lastPart}-GARBAGE-COMPLETE`,
      user_id: "USR-ADYAR-01",
      ward_id: wId,
      type: "Issue Resolved",
      title: "Garbage Collection Complete",
      description: `Morning sweep and collection in Block B has been completed for today.`,
      issue_id: "",
      read: true,
      tag: "",
      created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - 26 * 60 * 60 * 1000)) // Yesterday
    });
  });

  // 10. DB Batch Writing
  const writeBatch = async (collection, list, idField) => {
    console.log(`Writing ${list.length} docs to collection: "${collection}"...`);
    let count = 0;
    let batch = db.batch();
    for (const item of list) {
      const docId = item[idField];
      const docRef = db.collection(collection).doc(docId);
      batch.set(docRef, item);
      count++;
      if (count === 500) {
        await batch.commit();
        batch = db.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
  };

  // Map user documents
  const userDocuments = finalUsers.map(u => ({
    display_name: u.name,
    phone_number: u.phone,
    aadhaar_token: `aadhaar_hash_${u.id.toLowerCase()}`,
    home_ward_id: u.ward,
    home_area_name: wards[u.ward].name,
    home_district: wards[u.ward].district,
    home_state: wards[u.ward].state,
    verified: true,
    civic_score: u.score,
    posts_count: u.posts,
    supported_count: Math.floor(Math.random() * 30) + 5,
    wishes_count: Math.floor(Math.random() * 3),
    language: "ta",
    created_at: admin.firestore.Timestamp.fromDate(new Date(now.getTime() - 40 * 24 * 60 * 60 * 1000)),
    account_status: u.status
  }));
  
  await writeBatch("users", finalUsers.map((u, idx) => ({ ...userDocuments[idx], user_id: u.id })), "user_id");
  await writeBatch("issues", seededIssues, "issue_id");
  await writeBatch("wishes", seededWishes, "wish_id");
  await writeBatch("emergency_services", seededServices, "service_id");
  await writeBatch("notices", seededNotices, "notice_id");
  await writeBatch("officials", finalOfficials, "official_id");
  await writeBatch("wards", seededWards, "ward_id");
  await writeBatch("alerts", seededAlerts, "alert_id");

  // Mark Seeding as Completed
  const statusRef = db.collection("metadata").doc("seeding_status");
  await statusRef.set({ seeded_v1: true, seeded_v2: true, seeded_v3: true, seeded_v4: true, seeded_at: admin.firestore.Timestamp.fromDate(now) });

  console.log("====================================================");
  console.log("DEMO CONTENT SEEDING COMPLETED SUCCESSFULLY!");
  console.log(`- Wards targeted: ${targetWards.length}`);
  console.log(`- Users seeded: ${finalUsers.length}`);
  console.log(`- Issues seeded (and polished): ${seededIssues.length}`);
  console.log(`- Wishes seeded: ${seededWishes.length}`);
  console.log(`- KYH Emergency Services seeded: ${seededServices.length}`);
  console.log(`- Ward Notices seeded: ${seededNotices.length}`);
  console.log(`- Officials seeded: ${finalOfficials.length}`);
  console.log(`- Alerts seeded (Stitch spec per ward): ${seededAlerts.length}`);
  console.log("====================================================");
}

seedData().catch((err) => {
  console.error("Fatal Seeding Error: ", err);
  process.exit(1);
});
