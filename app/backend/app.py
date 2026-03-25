from flask import Flask, jsonify
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import os

app = Flask(__name__)
CORS(app)

DB_URL = os.environ.get('DB_URL', "postgresql://dbuser:securepass@postgres-service:5432/healthcare")

def get_db():
    return psycopg2.connect(DB_URL, cursor_factory=RealDictCursor)

@app.route('/api/status')
def status():
    return jsonify({"status": "Online", "service": "Healthcare-Backend"})

@app.route('/api/patients')
def get_patients():
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute('SELECT id, name, condition, admitted_at FROM patients ORDER BY admitted_at DESC;')
        patients = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify(patients)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
