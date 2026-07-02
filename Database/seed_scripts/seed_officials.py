import urllib.request
import urllib.parse
import ssl
import json
import re
import os
import sys
from bs4 import BeautifulSoup
from concurrent.futures import ThreadPoolExecutor, as_completed

# Set output encoding to UTF-8
if sys.stdout.encoding != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

# SSL context to ignore certificate verification errors
ssl_context = ssl._create_unverified_context()

BASE_DIR = "D:\\Vibe Coding\\Database\\seed_data"
if not os.path.exists(BASE_DIR):
    os.makedirs(BASE_DIR)

def clean_text(text):
    if not text:
        return ""
    # Remove excessive spaces and linebreaks
    text = re.sub(r'\s+', ' ', text)
    # Remove leading/trailing non-breaking spaces or common junk
    return text.strip().strip('\u200b')

def deobfuscate_email(email_str):
    if not email_str:
        return ""
    email_str = clean_text(email_str)
    # Replace obfuscation: [at], (at), [dot], (dot), etc.
    email_str = email_str.replace('[at]', '@').replace('(at)', '@').replace('{at}', '@').replace(' at ', '@')
    email_str = email_str.replace('[dot]', '.').replace('(dot)', '.').replace('{dot}', '.').replace(' dot ', '.')
    # Final strip
    return email_str.strip()

def fetch_html(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'})
    with urllib.request.urlopen(req, context=ssl_context, timeout=15) as r:
        return r.read()

# ----------------- 1. SCRAPE MLAs -----------------
def scrape_mlas():
    print("Scraping MLAs...")
    url = "https://assembly.tn.gov.in/17thassembly_members.php"
    try:
        html = fetch_html(url)
        soup = BeautifulSoup(html, 'html.parser')
        table = soup.find('table')
        if not table:
            print("No MLA table found.")
            return []
            
        mlas = []
        rows = table.find_all('tr')
        # Expecting headers: Const. No., Constituency, Member, Party, Email
        for row in rows[1:]:
            cols = [clean_text(td.get_text()) for td in row.find_all('td')]
            if len(cols) >= 5:
                const_no = cols[0]
                constituency = cols[1]
                member = cols[2]
                party = cols[3]
                email = deobfuscate_email(cols[4])
                
                mla_id = f"TN-MLA-{int(const_no):03d}" if const_no.isdigit() else f"TN-MLA-{const_no}"
                
                mlas.append({
                    "official_id": mla_id,
                    "name": member,
                    "constituency": constituency,
                    "party": party,
                    "email": email,
                    "designation": "MLA",
                    "level": "constituency",
                    "state": "Tamil Nadu",
                    "verified": True,
                    "accountability_score": 100
                })
        print(f"Scraped {len(mlas)} MLAs.")
        return mlas
    except Exception as e:
        print(f"Error scraping MLAs: {e}")
        return []

# ----------------- 2. SCRAPE MINISTERS -----------------
def scrape_ministers():
    print("Scraping Ministers...")
    url = "https://www.tn.gov.in/minister_list.php"
    try:
        html = fetch_html(url)
        soup = BeautifulSoup(html, 'html.parser')
        desc_divs = soup.find_all(class_='minister_col_description')
        
        ministers = []
        for i, div in enumerate(desc_divs):
            h4s = div.find_all('h4')
            name = clean_text(h4s[0].get_text()) if len(h4s) > 0 else ""
            designation = clean_text(h4s[1].get_text()) if len(h4s) > 1 else ""
            
            p_tag = div.find('p')
            portfolio = clean_text(p_tag.get_text()) if p_tag else ""
            
            ministers.append({
                "official_id": f"TN-MIN-{i+1:02d}",
                "name": name,
                "designation": designation,
                "portfolio": portfolio,
                "level": "state",
                "state": "Tamil Nadu",
                "verified": True,
                "accountability_score": 100
            })
        print(f"Scraped {len(ministers)} Ministers.")
        return ministers
    except Exception as e:
        print(f"Error scraping Ministers: {e}")
        return []

# ----------------- 3. SCRAPE SECRETARIES -----------------
def scrape_secretaries():
    print("Scraping Secretaries...")
    base_url = "https://www.tn.gov.in/"
    list_url = "https://www.tn.gov.in/cont_dir_department_list.php"
    try:
        html = fetch_html(list_url)
        soup = BeautifulSoup(html, 'html.parser')
        links = soup.find_all('a')
        
        dept_urls = []
        for l in links:
            href = l.get('href')
            if href and "cont_dir_dept_view.php" in href:
                full_url = urllib.parse.urljoin(base_url, href)
                dept_urls.append((clean_text(l.get_text()), full_url))
                
        print(f"Found {len(dept_urls)} department links.")
        
        secretaries = []
        # Fetch in parallel
        def fetch_dept(dept_name, url):
            try:
                dept_html = fetch_html(url)
                dept_soup = BeautifulSoup(dept_html, 'html.parser')
                table = dept_soup.find('table')
                if not table:
                    return []
                tds = table.find_all('td')
                dept_officials = []
                idx = 1
                for i in range(0, len(tds) - 3, 4):
                    desig = clean_text(tds[i].get_text())
                    name = clean_text(tds[i+1].get_text())
                    phone = clean_text(tds[i+2].get_text())
                    residence = clean_text(tds[i+3].get_text())
                    
                    if not name or name == "-":
                        continue
                        
                    dept_officials.append({
                        "official_id": f"TN-SEC-{dept_name[:3].upper()}-{idx:02d}",
                        "name": name,
                        "designation": desig,
                        "department": dept_name,
                        "phone": phone,
                        "residence": residence,
                        "level": "department",
                        "state": "Tamil Nadu",
                        "verified": True,
                        "accountability_score": 100
                    })
                    idx += 1
                return dept_officials
            except Exception as e:
                print(f"Error fetching dept {dept_name}: {e}")
                return []
                
        with ThreadPoolExecutor(max_workers=5) as executor:
            futures = {executor.submit(fetch_dept, name, url): name for name, url in dept_urls}
            for fut in as_completed(futures):
                secretaries.extend(fut.result())
                
        print(f"Scraped {len(secretaries)} Department Secretaries.")
        return secretaries
    except Exception as e:
        print(f"Error scraping Secretaries: {e}")
        return []

# ----------------- 4. SCRAPE HODs -----------------
def scrape_hods():
    print("Scraping HODs...")
    base_url = "https://www.tn.gov.in/"
    list_url = "https://www.tn.gov.in/cont_dir_All_hod_list.php"
    try:
        html = fetch_html(list_url)
        soup = BeautifulSoup(html, 'html.parser')
        links = soup.find_all('a')
        
        hod_urls = []
        for l in links:
            href = l.get('href')
            if href and "detail_contact_hod.php" in href:
                full_url = urllib.parse.urljoin(base_url, href)
                hod_urls.append((clean_text(l.get_text()), full_url))
                
        print(f"Found {len(hod_urls)} HOD links.")
        
        # Scrape a subset or all, but let's do all.
        hods = []
        def fetch_hod(hod_name, url):
            try:
                hod_html = fetch_html(url)
                hod_soup = BeautifulSoup(hod_html, 'html.parser')
                table = hod_soup.find('table')
                if not table:
                    return []
                tds = table.find_all('td')
                hod_officials = []
                idx = 1
                for i in range(0, len(tds) - 3, 4):
                    desig = clean_text(tds[i].get_text())
                    name = clean_text(tds[i+1].get_text())
                    phone = clean_text(tds[i+2].get_text())
                    residence = clean_text(tds[i+3].get_text())
                    
                    if not name or name == "-":
                        continue
                        
                    hod_officials.append({
                        "official_id": f"TN-HOD-{hod_name[:3].upper()}-{idx:02d}",
                        "name": name,
                        "designation": desig,
                        "organisation": hod_name,
                        "phone": phone,
                        "residence": residence,
                        "level": "hod",
                        "state": "Tamil Nadu",
                        "verified": True,
                        "accountability_score": 100
                    })
                    idx += 1
                return hod_officials
            except Exception as e:
                print(f"Error fetching HOD {hod_name}: {e}")
                return []
                
        with ThreadPoolExecutor(max_workers=5) as executor:
            futures = {executor.submit(fetch_hod, name, url): name for name, url in hod_urls}
            for fut in as_completed(futures):
                hods.extend(fut.result())
                
        print(f"Scraped {len(hods)} HOD officials.")
        return hods
    except Exception as e:
        print(f"Error scraping HODs: {e}")
        return []

# ----------------- 5. SCRAPE DISTRICT-LEVEL OFFICERS -----------------
# Map subdomains for the districts
district_subdomains = {
    "Ariyalur": "ariyalur", "Chengalpattu": "chengalpattu", "Chennai": "chennai",
    "Coimbatore": "coimbatore", "Cuddalore": "cuddalore", "Dharmapuri": "dharmapuri",
    "Dindigul": "dindigul", "Erode": "erode", "Kallakurichi": "kallakurichi",
    "Kancheepuram": "kancheepuram", "Kanniyakumari": "kanniyakumari", "Karur": "karur",
    "Krishnagiri": "krishnagiri", "Madurai": "madurai", "Mayiladuthurai": "mayiladuthurai",
    "Nagapattinam": "nagapattinam", "Namakkal": "namakkal", "Perambalur": "perambalur",
    "Pudukkottai": "pudukkottai", "Ramanathapuram": "ramanathapuram", "Ranipet": "ranipet",
    "Salem": "salem", "Sivaganga": "sivaganga", "Tenkasi": "tenkasi", "Thanjavur": "thanjavur",
    "Theni": "theni", "The Nilgiris": "nilgiris", "Thoothukudi": "thoothukudi",
    "Tiruchirappalli": "tiruchirappalli", "Tirunelveli": "tirunelveli", "Tirupathur": "tirupathur",
    "Tiruppur": "tiruppur", "Tiruvallur": "tiruvallur", "Tiruvannamalai": "tiruvannamalai",
    "Tiruvarur": "tiruvarur", "Vellore": "vellore", "Viluppuram": "viluppuram",
    "Virudhunagar": "virudhunagar"
}

def fetch_district_officers(dist_name, subdomain):
    # Determine the exact directory URL
    if dist_name == "Theni":
        url = "https://theni.nic.in/contact_directory/"
    elif dist_name == "Kanniyakumari":
        url = "https://kanniyakumari.nic.in/contactdirectorydatatable/"
    else:
        url = f"https://{subdomain}.nic.in/contact-directory/"
        
    try:
        html = fetch_html(url)
        soup = BeautifulSoup(html, 'html.parser')
        tables = soup.find_all('table')
        
        officers = []
        for table in tables:
            rows = table.find_all('tr')
            if not rows:
                continue
            # Read header to map column indexes
            headers = [clean_text(th.get_text()).lower() for th in rows[0].find_all(['th', 'td'])]
            
            # Identify columns
            desig_idx, email_idx, mobile_idx, phone_idx = -1, -1, -1, -1
            for idx, h in enumerate(headers):
                if "designation" in h:
                    desig_idx = idx
                elif "email" in h:
                    email_idx = idx
                elif "mobile" in h:
                    mobile_idx = idx
                elif "phone" in h or "landline" in h:
                    phone_idx = idx
                    
            if desig_idx == -1:
                # Fallback mapping if headers are missing/different
                desig_idx = 0
                email_idx = 1 if len(headers) > 1 else -1
                mobile_idx = 2 if len(headers) > 2 else -1
                phone_idx = 3 if len(headers) > 3 else -1
                
            for row in rows[1:]:
                tds = row.find_all('td')
                if len(tds) <= desig_idx:
                    continue
                desig = clean_text(tds[desig_idx].get_text())
                email = deobfuscate_email(tds[email_idx].get_text()) if email_idx != -1 and len(tds) > email_idx else ""
                mobile = clean_text(tds[mobile_idx].get_text()) if mobile_idx != -1 and len(tds) > mobile_idx else ""
                phone = clean_text(tds[phone_idx].get_text()) if phone_idx != -1 and len(tds) > phone_idx else ""
                
                # Clean up designations and skip empty ones
                if not desig or desig == "-":
                    continue
                # Skip if name/details are empty
                if not email and not mobile and not phone:
                    continue
                    
                # Standardize level based on designation keyword
                level = "district"
                desig_lower = desig.lower()
                if "tahsildar" in desig_lower:
                    level = "taluk"
                elif "bdo" in desig_lower or "block development" in desig_lower:
                    level = "block"
                elif "commissioner" in desig_lower and "municipal" in desig_lower:
                    level = "municipality"
                    
                officers.append({
                    "official_id": f"TN-DIST-{dist_name[:3].upper()}-{len(officers)+1:03d}",
                    "name": "", # S3WAS contact directory usually only has Designation + Contact info
                    "designation": desig,
                    "district": dist_name,
                    "email": email,
                    "mobile": mobile,
                    "phone": phone,
                    "level": level,
                    "state": "Tamil Nadu",
                    "verified": True,
                    "accountability_score": 100
                })
        return officers
    except Exception as e:
        print(f"Error fetching district {dist_name}: {e}")
        return []

def scrape_all_districts():
    print("Scraping all 38 districts...")
    all_officers = []
    
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = {executor.submit(fetch_district_officers, name, sub): name for name, sub in district_subdomains.items()}
        for fut in as_completed(futures):
            name = futures[fut]
            officers = fut.result()
            print(f"  Scraped {len(officers)} officers from {name}")
            all_officers.extend(officers)
            
    print(f"Scraped total {len(all_officers)} district-level officers.")
    return all_officers

# ----------------- MAIN RUNNER -----------------
def main():
    # Scrape all
    mlas = scrape_mlas()
    ministers = scrape_ministers()
    secretaries = scrape_secretaries()
    hods = scrape_hods()
    district_officers = scrape_all_districts()
    
    # Save as JSON files
    with open(os.path.join(BASE_DIR, "mlas.json"), "w") as f:
        json.dump(mlas, f, indent=2)
    with open(os.path.join(BASE_DIR, "ministers.json"), "w") as f:
        json.dump(ministers, f, indent=2)
    with open(os.path.join(BASE_DIR, "secretaries.json"), "w") as f:
        json.dump(secretaries, f, indent=2)
    with open(os.path.join(BASE_DIR, "hods.json"), "w") as f:
        json.dump(hods, f, indent=2)
    with open(os.path.join(BASE_DIR, "district_officers.json"), "w") as f:
        json.dump(district_officers, f, indent=2)
        
    print("\n--- Scraping Success ---")
    print(f"Saved mlas.json ({len(mlas)} records)")
    print(f"Saved ministers.json ({len(ministers)} records)")
    print(f"Saved secretaries.json ({len(secretaries)} records)")
    print(f"Saved hods.json ({len(hods)} records)")
    print(f"Saved district_officers.json ({len(district_officers)} records)")

if __name__ == "__main__":
    main()
