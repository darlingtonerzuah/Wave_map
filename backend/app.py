from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Mock data for now
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