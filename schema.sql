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
  applications TEXT, -- JSON string or comma-separated
  warranty TEXT
);