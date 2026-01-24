#!/usr/bin/env bash
set -euo pipefail

# ปรับค่าต่อไปนี้ตามต้องการ
REPO_URL="https://github.com/Darayabike0/BatteryDARAYAR.git"
BRANCH_NAME="หลัก"             # เปลี่ยนเป็น "main" ถ้าต้องการ
COMMIT_MSG="การยอมรับครั้งแรก"
TMP_DIR="$(mktemp -d)"

echo "สร้างไฟล์ในโฟลเดอร์ชั่วคราว: $TMP_DIR"
cd "$TMP_DIR"

# สร้างโครงสร้างโฟลเดอร์
mkdir -p api/express db scripts data

# ----- README.md -----
cat > README.md <<'EOF'
# BatteryDARAYAR

12V 3S2P 18650 PowerPack — repository นี้เก็บหน้าเว็บ ตัวอย่างข้อมูล และ API เพื่อเชื่อมต่อกับฐานข้อมูล SQLite

สิ่งที่รวมมา:
- index.html, style.css, script.js — หน้าเว็บข้อมูลผลิตภัณฑ์
- data/batteries.json — ข้อมูลตัวอย่าง (JSON)
- db/schema.sql — SQL schema สำหรับสร้างตาราง
- scripts/init_db.py — สครipts สร้างฐานข้อมูล SQLite แ��ะเติมข้อมูลจาก `data/batteries.json`
- api/flask_app.py — ตัวอย่าง REST API ด้วย Flask (Python)
- api/express/server.js — ตัวอย่าง REST API ด้วย Express (Node.js)
- api/express/package.json
- requirements.txt, .gitignore, LICENSE (MIT)

วิธีใช้งานแบบเร็ว:
1. สร้างฐานข้อมูล SQLite และเติมข้อมูล:python3 scripts/init_db.py

Code
จะสร้างไฟล์ `data/batteries.db`

2. รัน API — เลือกทางใดทางหนึ่ง:

a) Flask (Python):python3 -m venv venv source venv/bin/activate # macOS/Linux venv\Scripts\activate # Windows pip install -r requirements.txt python api/flask_app.py

Code
แอพจะรันที่ http://127.0.0.1:5000

b) Express (Node.js):cd api/express npm install npm start

Code
แอพจะรันที่ http://127.0.0.1:3000

3. เปิด `index.html` ในเบราว์เซอร์เพื่อดูหน้าเว็บ (Frontend ปัจจุบันเป็น static)

Notes:
- ตัวอย่างนี้ใช้ SQLite ที่เก็บไฟล์ `data/batteries.db` เพื่อความง่าย — ถ้าต้องการ PostgreSQL/MySQL หรือ Docker Compose บอกผมได้
- ถ้าต้องการให้ผมปรับ frontend ให้เรียก API โดยตรง บอกผมได้
EOF

# ----- LICENSE (MIT) -----
cat > LICENSE <<'EOF'
MIT License

Copyright (c) 2026 Darayabike0

Permission is hereby granted, free of charge, to any person obtaining a copy
... (standard MIT -- truncated here for brevity in script; full text below in repo) ...
EOF

# Write the full MIT license file (replace truncated above)
cat > LICENSE <<'EOF'
MIT License

Copyright (c) 2026 Darayabike0

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
EOF

# ----- .gitignore -----
cat > .gitignore <<'EOF'
# Python
__pycache__/
*.pyc
venv/
env/

# Node
node_modules/

# Database
data/*.db

# Editor
.vscode/
.idea/
EOF

# ----- requirements.txt -----
cat > requirements.txt <<'EOF'
Flask>=2.0
Flask-Cors>=3.0
EOF

# ----- data/batteries.json -----
cat > data/batteries.json <<'EOF'
[
{
 "id": 1,
 "name": "BatteryDARAYAR 12V 3S2P 18650",
 "cell_type": "18650 Li-ion",
 "configuration": "3S2P",
 "nominal_voltage_v": 11.1,
 "max_voltage_v": 12.6,
 "typical_capacity_mAh": 8000,
 "cell_count": 6,
 "weight_g": 260,
 "shell_material": "Aluminum/Polymer",
 "applications": ["E-bikes", "portable tools", "audio gear"],
 "warranty": "1 year"
}
]
EOF

# ----- db/schema.sql -----
cat > db/schema.sql <<'EOF'
-- Schema for batteries (SQLite / PostgreSQL compatible)
CREATE TABLE IF NOT EXISTS batteries (
id INTEGER PRIMARY KEY,
name TEXT NOT NULL,
cell_type TEXT,
configuration TEXT,
nominal_voltage_v REAL,
max_voltage_v REAL,
typical_capacity_mAh INTEGER,
cell_count INTEGER,
weight_g REAL,
shell_material TEXT,
applications TEXT, -- stored as JSON string
warranty TEXT
);
EOF

# ----- scripts/init_db.py -----
cat > scripts/init_db.py <<'EOF'
#!/usr/bin/env python3
import sqlite3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / "data"
DATA_FILE = DATA_DIR / "batteries.json"
DB_FILE = DATA_DIR / "batteries.db"
SCHEMA_FILE = ROOT / "db" / "schema.sql"

def ensure_dirs():
 DATA_DIR.mkdir(parents=True, exist_ok=True)
 (ROOT / "db").mkdir(parents=True, exist_ok=True)

def load_schema():
 if SCHEMA_FILE.exists():
     return SCHEMA_FILE.read_text(encoding="utf-8")
 # fallback minimal schema if file missing
 return """
 CREATE TABLE IF NOT EXISTS batteries (
   id INTEGER PRIMARY KEY,
   name TEXT NOT NULL,
   cell_type TEXT,
   configuration TEXT,
   nominal_voltage_v REAL,
   max_voltage_v REAL,
   typical_capacity_mAh INTEGER,
   cell_count INTEGER,
   weight_g REAL,
   shell_material TEXT,
   applications TEXT,
   warranty TEXT
 );
 """

def main():
 ensure_dirs()
 if not DATA_FILE.exists():
     print(f"Data file not found: {DATA_FILE}")
     return

 with open(DATA_FILE, "r", encoding="utf-8") as f:
     batteries = json.load(f)

 schema_sql = load_schema()

 conn = sqlite3.connect(DB_FILE)
 cur = conn.cursor()
 cur.executescript(schema_sql)
 cur.execute("DELETE FROM batteries;")

 for b in batteries:
     cur.execute("""
     INSERT INTO batteries (id, name, cell_type, configuration, nominal_voltage_v, max_voltage_v,
                            typical_capacity_mAh, cell_count, weight_g, shell_material, applications, warranty)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
     """, (
         b.get("id"),
         b.get("name"),
         b.get("cell_type"),
         b.get("configuration"),
         b.get("nominal_voltage_v"),
         b.get("max_voltage_v"),
         b.get("typical_capacity_mAh"),
         b.get("cell_count"),
         b.get("weight_g"),
         b.get("shell_material"),
         json.dumps(b.get("applications", []), ensure_ascii=False),
         b.get("warranty")
     ))
 conn.commit()
 conn.close()
 print(f"Database created: {DB_FILE}")

if __name__ == "__main__":
 main()
EOF
chmod +x scripts/init_db.py

# ----- index.html -----
cat > index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>BatteryDARAYAR - 12V 3S2P 18650 PowerPack</title>
<link rel="stylesheet" href="style.css">
<script src="script.js" defer></script>
</head>
<body>
<header>
 <h1>BatteryDARAYAR</h1>
 <p>12V 3S2P 18650 PowerPack</p>
</header>

<section>
 <h2>Configuration</h2>
 <ul>
   <li>3S2P (3 series × 2 parallel)</li>
   <li>Nominal Voltage: 12.6V (max), 11.1V (nominal)</li>
   <li>Cell Type: 18650 Li-ion</li>
   <li>Capacity: ~ 5,200–6,000 mAh (depends on cell rating)</li>
 </ul>
</section>

<section>
 <h2>Specifications</h2>
 <table>
   <tr>
     <th>Parameter</th>
     <th>Value</th>
   </tr>
   <tr>
     <td>Cell Count</td>
     <td>6 (3S2P)</td>
   </tr>
   <tr>
     <td>Nominal Voltage</td>
     <td>11.1V</td>
   </tr>
   <tr>
     <td>Max Voltage</td>
     <td>12.6V</td>
   </tr>
   <tr>
     <td>Capacity</td>
     <td>Depends on cell (e.g., 2600mAh × 2 = 5200mAh)</td>
   </tr>
   <tr>
     <td>Dimensions</td>
     <td>Custom pack size</td>
   </tr>
   <tr>
     <td>Applications</td>
     <td>SpotWeld Pro, e-bikes, portable tools</td>
   </tr>
 </table>
</section>

<section>
 <h2>Notes</h2>
 <p>
   This pack is designed under DALAYAR’s <em>เจ้าเป่า</em> philosophy: clarity, trust, and sustainable excellence.
   Ensure proper BMS integration for safety and longevity.
 </p>
</section>

<footer>
 &copy; 2026 DALAYAR Bicycle Lifestyle Co., Ltd. — BatteryDARAYAR Documentation
</footer>
</body>
</html>
EOF

# ----- style.css -----
cat > style.css <<'EOF'
body {
font-family: Arial, sans-serif;
margin: 20px;
background-color: #f9f9f9;
color: #333;
}

header {
text-align: center;
padding: 10px;
background: #222;
color: #fff;
}

section {
margin: 20px 0;
padding: 15px;
background: #fff;
border-radius: 6px;
box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

h2 {
border-bottom: 2px solid #ddd;
padding-bottom: 5px;
}

table {
width: 100%;
border-collapse: collapse;
margin-top: 10px;
}

table, th, td {
border: 1px solid #ccc;
}

th, td {
padding: 8px;
text-align: left;
}

footer {
text-align: center;
margin-top: 30px;
font-size: 0.9em;
color: #666;
}

/* Dark mode styles */
body.dark-mode {
background: #121212;
color: #eaeaea;
}

body.dark-mode header {
background: #000;
}
EOF

# ----- script.js -----
cat > script.js <<'EOF'
document.addEventListener("DOMContentLoaded", () => {
// ====== Table Sorting ======
const table = document.querySelector("table");
const headers = table.querySelectorAll("th");

headers.forEach((header, index) => {
 header.addEventListener("click", () => {
   sortTable(table, index);
 });
});

function sortTable(table, colIndex) {
 const rows = Array.from(table.rows).slice(1);
 const sorted = rows.sort((a, b) => {
   const valA = a.cells[colIndex].innerText.toLowerCase();
   const valB = b.cells[colIndex].innerText.toLowerCase();
   return valA.localeCompare(valB);
 });
 sorted.forEach(row => table.appendChild(row));
}

// ====== Section Toggle ======
document.querySelectorAll("section h2").forEach(h2 => {
 h2.style.cursor = "pointer";
 h2.addEventListener("click", () => {
   const content = h2.nextElementSibling;
   content.style.display =
     content.style.display === "none" ? "block" : "none";
 });
});

// ====== Dark Mode Toggle ======
const footer = document.querySelector("footer");
const toggleBtn = document.createElement("button");
toggleBtn.innerText = "Toggle Dark Mode";
toggleBtn.style.marginTop = "10px";
footer.appendChild(toggleBtn);

toggleBtn.addEventListener("click", () => {
 document.body.classList.toggle("dark-mode");
});

// ====== Highlight on Hover ======
const tableCells = table ? table.querySelectorAll("td") : [];
tableCells.forEach(cell => {
 cell.addEventListener("mouseenter", () => {
   cell.style.backgroundColor = "#ffeaa7";
 });
 cell.addEventListener("mouseleave", () => {
   cell.style.backgroundColor = "";
 });
});
});
EOF

# ----- api/flask_app.py -----
cat > api/flask_app.py <<'EOF'
from flask import Flask, g, jsonify, request, abort
from flask_cors import CORS
import sqlite3
import json
from pathlib import Path

DB_PATH = Path(__file__).resolve().parents[1] / "data" / "batteries.db"

app = Flask(__name__)
CORS(app)

def get_db():
 db = getattr(g, "_database", None)
 if db is None:
     db = sqlite3.connect(DB_PATH)
     db.row_factory = sqlite3.Row
     g._database = db
 return db

@app.teardown_appcontext
def close_connection(exception):
 db = getattr(g, "_database", None)
 if db is not None:
     db.close()

def row_to_dict(row):
 d = dict(row)
 # parse applications if stored as JSON string
 if d.get("applications"):
     try:
         d["applications"] = json.loads(d["applications"])
     except Exception:
         pass
 return d

@app.route("/api/batteries", methods=["GET"])
def list_batteries():
 cur = get_db().cursor()
 cur.execute("SELECT * FROM batteries")
 rows = cur.fetchall()
 return jsonify([row_to_dict(r) for r in rows])

@app.route("/api/batteries/<int:item_id>", methods=["GET"])
def get_battery(item_id):
 cur = get_db().cursor()
 cur.execute("SELECT * FROM batteries WHERE id = ?", (item_id,))
 row = cur.fetchone()
 if not row:
     abort(404)
 return jsonify(row_to_dict(row))

@app.route("/api/batteries", methods=["POST"])
def create_battery():
 data = request.get_json()
 if not data or "name" not in data:
     abort(400)
 applications = json.dumps(data.get("applications", []), ensure_ascii=False)
 cur = get_db().cursor()
 cur.execute("""
   INSERT INTO batteries (name, cell_type, configuration, nominal_voltage_v, max_voltage_v,
                          typical_capacity_mAh, cell_count, weight_g, shell_material, applications, warranty)
   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
 """, (
     data.get("name"),
     data.get("cell_type"),
     data.get("configuration"),
     data.get("nominal_voltage_v"),
     data.get("max_voltage_v"),
     data.get("typical_capacity_mAh"),
     data.get("cell_count"),
     data.get("weight_g"),
     data.get("shell_material"),
     applications,
     data.get("warranty")
 ))
 get_db().commit()
 new_id = cur.lastrowid
 return jsonify({"id": new_id}), 201

@app.route("/api/batteries/<int:item_id>", methods=["PUT"])
def update_battery(item_id):
 data = request.get_json()
 if not data:
     abort(400)
 applications = json.dumps(data.get("applications", []), ensure_ascii=False)
 cur = get_db().cursor()
 cur.execute("""
   UPDATE batteries SET name=?, cell_type=?, configuration=?, nominal_voltage_v=?, max_voltage_v=?,
                       typical_capacity_mAh=?, cell_count=?, weight_g=?, shell_material=?, applications=?, warranty=?
   WHERE id=?
 """, (
     data.get("name"),
     data.get("cell_type"),
     data.get("configuration"),
     data.get("nominal_voltage_v"),
     data.get("max_voltage_v"),
     data.get("typical_capacity_mAh"),
     data.get("cell_count"),
     data.get("weight_g"),
     data.get("shell_material"),
     applications,
     data.get("warranty"),
     item_id
 ))
 get_db().commit()
 if cur.rowcount == 0:
     abort(404)
 return jsonify({"updated": item_id})

@app.route("/api/batteries/<int:item_id>", methods=["DELETE"])
def delete_battery(item_id):
 cur = get_db().cursor()
 cur.execute("DELETE FROM batteries WHERE id = ?", (item_id,))
 get_db().commit()
 if cur.rowcount == 0:
     abort(404)
 return jsonify({"deleted": item_id})

if __name__ == "__main__":
 if not DB_PATH.exists():
     print(f"Database not found at {DB_PATH}. Run scripts/init_db.py first.")
 app.run(debug=True, host="0.0.0.0", port=5000)
EOF

# ----- api/express/package.json -----
cat > api/express/package.json <<'EOF'
{
"name": "batterydarayar-api",
"version": "1.0.0",
"description": "Express API for BatteryDARAYAR using SQLite",
"main": "server.js",
"scripts": {
 "start": "node server.js",
 "dev": "nodemon server.js"
},
"dependencies": {
 "body-parser": "^1.20.2",
 "cors": "^2.8.5",
 "express": "^4.18.2",
 "sqlite3": "^5.1.6"
},
"devDependencies": {
 "nodemon": "^2.0.22"
}
}
EOF

# ----- api/express/server.js -----
cat > api/express/server.js <<'EOF'
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const sqlite3 = require("sqlite3").verbose();
const path = require("path");
const DB_PATH = path.resolve(__dirname, "..", "data", "batteries.db");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const db = new sqlite3.Database(DB_PATH, sqlite3.OPEN_READWRITE, (err) => {
if (err) {
 console.error("Failed to open DB:", err.message);
} else {
 console.log("Connected to SQLite DB:", DB_PATH);
}
});

function rowToObj(row) {
if (!row) return null;
if (row.applications) {
 try {
   row.applications = JSON.parse(row.applications);
 } catch (e) {}
}
return row;
}

app.get("/api/batteries", (req, res) => {
db.all("SELECT * FROM batteries", [], (err, rows) => {
 if (err) return res.status(500).json({ error: err.message });
 res.json(rows.map(rowToObj));
});
});

app.get("/api/batteries/:id", (req, res) => {
const id = req.params.id;
db.get("SELECT * FROM batteries WHERE id = ?", [id], (err, row) => {
 if (err) return res.status(500).json({ error: err.message });
 if (!row) return res.status(404).end();
 res.json(rowToObj(row));
});
});

app.post("/api/batteries", (req, res) => {
const data = req.body;
const apps = JSON.stringify(data.applications || []);
const stmt = `
 INSERT INTO batteries (name, cell_type, configuration, nominal_voltage_v, max_voltage_v,
   typical_capacity_mAh, cell_count, weight_g, shell_material, applications, warranty)
 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
`;
db.run(stmt, [
 data.name, data.cell_type, data.configuration, data.nominal_voltage_v, data.max_voltage_v,
 data.typical_capacity_mAh, data.cell_count, data.weight_g, data.shell_material, apps, data.warranty
], function(err) {
 if (err) return res.status(500).json({ error: err.message });
 res.status(201).json({ id: this.lastID });
});
});

app.put("/api/batteries/:id", (req, res) => {
const id = req.params.id;
const data = req.body;
const apps = JSON.stringify(data.applications || []);
const stmt = `
 UPDATE batteries
 SET name=?, cell_type=?, configuration=?, nominal_voltage_v=?, max_voltage_v=?,
     typical_capacity_mAh=?, cell_count=?, weight_g=?, shell_material=?, applications=?, warranty=?
 WHERE id=?
`;
db.run(stmt, [
 data.name, data.cell_type, data.configuration, data.nominal_voltage_v, data.max_voltage_v,
 data.typical_capacity_mAh, data.cell_count, data.weight_g, data.shell_material, apps, data.warranty,
 id
], function(err) {
 if (err) return res.status(500).json({ error: err.message });
 if (this.changes === 0) return res.status(404).end();
 res.json({ updated: id });
});
});

app.delete("/api/batteries/:id", (req, res) => {
const id = req.params.id;
db.run("DELETE FROM batteries WHERE id = ?", [id], function(err) {
 if (err) return res.status(500).json({ error: err.message });
 if (this.changes === 0) return res.status(404).end();
 res.json({ deleted: id });
});
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
console.log(`Express API listening on http://localhost:${PORT}`);
});
EOF

# Initialize git repo, add, commit, and push
echo "เริ่มต้น git,สร้าง branch: $BRANCH_NAME, commit, และ push ขึ้น $REPO_URL"

git init
git checkout -b "$BRANCH_NAME" || git switch -c "$BRANCH_NAME"
git add .
git commit -m "$COMMIT_MSG"

# ตรวจสอบ remote
if git remote | grep -q origin; then
git remote remove origin
fi
git remote add origin "$REPO_URL"

echo "กำลัง push สาขา $BRANCH_NAME ไปยัง $REPO_URL ..."
git push -u origin "$BRANCH_NAME"

echo "เสร็จสิ้น: ไฟล์ทั้งหมดถูก push ไปยัง $REPO_URL (สาขา: $BRANCH_NAME)"
echo "โฟลเดอร์ชั่วคราว: $TMP_DIR (ไม่ถูกลบ — หากต้องการลบ ให้รัน: rm -rf \"$TMP_DIR\")"
EOF
