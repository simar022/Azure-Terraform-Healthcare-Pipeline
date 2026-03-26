from flask import Flask, jsonify
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import logging

app = Flask(__name__)
# Explicitly allow the ALB IP and Frontend Port
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Configuration from Environment Variables
DB_URL = os.environ.get('DB_URL', "postgresql://dbuser:securepass@postgres-service:5432/healthcare")

def get_db_connection():
    try:
        conn = psycopg2.connect(DB_URL, cursor_factory=RealDictCursor, connect_timeout=5)
        return conn
    except Exception as e:
        logging.error(f"Database Connection Failed: {e}")
        return None

@app.route('/api/patients', methods=['GET'])
def get_patients():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database unavailable"}), 503
    
    try:
        cur = conn.cursor()
        cur.execute('SELECT id, name, condition, admitted_at FROM patients ORDER BY id DESC;')
        patients = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify(patients)
    except Exception as e:
        return jsonify({"error": "Query failed", "details": str(e)}), 500

if __name__ == '__main__':
    # Listen on all interfaces for Azure ALB compatibility
    app.run(host='0.0.0.0', port=5000, debug=False)
