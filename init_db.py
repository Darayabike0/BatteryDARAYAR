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