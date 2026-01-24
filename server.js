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