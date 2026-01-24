# BatteryDARAYAR

12V 3S2P 18650 PowerPack — repository นี้เก็บหน้าเว็บ ตัวอย่างข้อมูล และ API เพื่อเชื่อมต่อกับฐานข้อมูล SQLite

สิ่งที่รวมมา:
- `index.html`, `style.css`, `script.js` — หน้าเว็บข้อมูลผลิตภัณฑ์
- `data/batteries.json` — ข้อมูลตัวอย่าง (JSON)
- `db/schema.sql` — SQL schema สำหรับสร้างตาราง
- `scripts/init_db.py` — สคริปต์สร้างฐานข้อมูล SQLite และเติมข้อมูลจาก `data/batteries.json`
- `api/flask_app.py` — ตัวอย่าง REST API ด้วย Flask (Python)
- `api/express/server.js` และ `api/express/package.json` — ตัวอย่าง REST API ด้วย Express (Node.js)
- `requirements.txt`, `.gitignore`, `LICENSE` (MIT)

วิธีใช้งานแบบรวดเร็ว
1. สร้างฐานข้อมูล SQLite และเติมข้อมูล:
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

3. เปิด `index.html` ในเบราว์เซอร์เพื่อดูหน้าเว็บ (Frontend ปัจจุบันเป็น static; หากต้องการให้ frontend ดึงข้อมูลจาก API ผมจะอัปเดต `script.js` ให้)

หมายเหตุ
- ตัวอย่างนี้ใช้ SQLite (ไฟล์ `data/batteries.db`) เพื่อความง่าย — ถ้าต้องการ PostgreSQL/MySQL หรือ docker-compose ให้บอกได้
- ไฟล์ `.db` ถูกละไว้ใน `.gitignore` ตามที่คุณต้องการ (ไม่ได้รวมใน repo โดยอัตโนมัติ)