from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
import datetime

app = Flask(__name__)
CORS(app)

app.config['JWT_SECRET_KEY'] = 'wifiar-secret-key-change-in-prod'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = datetime.timedelta(days=7)
jwt = JWTManager(app)

# Mock users db
USERS = {
    'demo@wifiar.com': {'password': 'demo123', 'plan': 'free'},
    'pro@wifiar.com': {'password': 'pro123', 'plan': 'pro'},
}

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    user = USERS.get(email)
    if not user or user['password'] != password:
        return jsonify({'error': 'Invalid credentials'}), 401

    token = create_access_token(identity={'email': email, 'plan': user['plan']})
    return jsonify({'token': token, 'plan': user['plan'], 'email': email})

@app.route('/api/devices')
def get_devices():
    return jsonify([
        {'name': 'iPhone 13', 'ip': '192.168.1.2', 'rssi': -45, 'status': 'Strong'},
        {'name': 'Samsung TV', 'ip': '192.168.1.3', 'rssi': -67, 'status': 'Okay'},
        {'name': 'Unknown Device', 'ip': '192.168.1.4', 'rssi': -82, 'status': 'Weak'},
        {'name': 'MacBook Pro', 'ip': '192.168.1.5', 'rssi': -51, 'status': 'Strong'},
    ])

@app.route('/api/diagnostics')
def get_diagnostics():
    return jsonify({
        'network_name': 'MyWiFi_5G',
        'signal_quality': 78,
        'ping': 12,
        'download': 54,
        'connected_devices': 4,
        'ip': '192.168.1.1'
    })

@app.route('/api/heatmap', methods=['GET'])
def get_heatmap():
    return jsonify([])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)