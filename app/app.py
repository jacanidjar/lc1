import os
from flask import Flask, jsonify

# Initialize Flask application
# Inicializa a aplicação Flask
app = Flask(__name__)

# Main route returning JSON with candidate info
# Rota principal retornando JSON com informações do candidato
@app.route('/')
def hello():
    return jsonify({
        "message": "Hello World",
        "candidate": "Ledn Candidate",
        "environment": "prod",
        "version": "1.0.0",
        # Get commit ID from environment variable or default to unknown
        # Obtém o ID do commit da variável de ambiente ou define como unknown
        "commit_id": os.getenv("COMMIT_ID", "unknown")
    })

# Health check endpoint for Load Balancer/K8s probes
# Endpoint de verificação de saúde para sondas do Load Balancer/K8s
@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    # Run the app on all interfaces at port 5000
    # Executa a aplicação em todas as interfaces na porta 5000
    app.run(host='0.0.0.0', port=5000)
