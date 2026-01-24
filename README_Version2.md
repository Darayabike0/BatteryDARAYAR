# BatteryDARAYAR

12V 3S2P 18650 PowerPack — repository นี้เก็บหน้าเว็บ ตัวอย่างข้อมูล และ API เพื่อเชื่อมต่อกับฐานข้อมูล SQLite

สิ่งที่รวมมา:
- index.html, style.css, script.js — หน้าเว็บข้อมูลผลิตภัณฑ์
- data/batteries.json — ข้อมูลตัวอย่าง (JSON)
- db/schema.sql — SQL schema สำหรับสร้างตาราง
- scripts/init_db.py — สรipts สร้างฐานข้อมูล SQLite และเติมข้อมูลจาก `data/batteries.json`
- api/flask_app.py — ตัวอย่าง REST API ด้วย Flask (Python)
- api/express/server.js — ตัวอย่าง REST API ด้วย Express (Node.js)
- .gitignore, package.json (สำหรับ Express), requirements.txt (สำหรับ Flask)

API endpoints (ทั้ง Flask และ Express ใช้ path เดียวกัน):
- GET /api/batteries — ดึงรายการแบตเตอรี่ทั้งหมด
- GET /api/batteries/<id> — ดึงแบตเตอรี่ตาม id
- POST /api/batteries — สร้างรายการใหม่ (JSON body)
- PUT /api/batteries/<id> — อัพเดตรายการ (JSON body)
- DELETE /api/batteries/<id> — ลบรายการ

วิธีใช้ (แบบรวดเร็ว)
1. ส���้างฐานข้อมูล SQLite และเติมข้อมูล
   ```
   python3 scripts/init_db.py
   ```
   จะสร้างไฟล์ `data/batteries.db`

2. รัน API — เลือกทางใดทางหนึ่ง

   a) Flask (Python)
   ```
   python3 -m venv venv
   source venv/bin/activate   # macOS/Linux
   venv\Scripts\activate      # Windows
   pip install -r requirements.txt
   python api/flask_app.py
   ```
   แอพจะรันที่ http://127.0.0.1:5000

   b) Express (Node.js)
   ```
   cd api/express
   npm install
   npm start
   ```
   แอพจะรันที่ http://127.0.0.1:3000

3. เปิด `index.html` ในเบราว์เซอร์เพื่อดูหน้าเว็บ (Frontend ปัจจุบันเป็น static; ถ้าต้องการให้ frontend เรียก API เพิ่มเติม ผมสามารถอัปเดต script.js ให้เรียกข้อมูลจาก API ได้)

Notes:
- ตัวอย่างนี้ใช้ SQLite ที่เก็บไฟล์ `data/batteries.db` เพื่อความง่าย — ถ้าต้องการ PostgreSQL/MySQL หรือ Docker Compose บอกผมได้
- ถ้าต้องการให้ผม push ทั้งหมดขึ้น GitHub ให้บอก owner, repo name, และ public/private
