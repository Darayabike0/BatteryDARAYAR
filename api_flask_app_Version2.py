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