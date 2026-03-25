from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

def get_db_connection():
    return psycopg2.connect(os.environ.get('DB_URL'))

@app.route('/api/status')
def status():
    return jsonify({"status": "Healthcare System Online", "version": "1.1"})

@app.route('/api/patients')
def get_patients():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT name, condition FROM patients;')
    patients = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(patients)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)