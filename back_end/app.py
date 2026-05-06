from flask import Flask, request, jsonify
from pymongo import MongoClient
import bcrypt
import uuid
import re
import os
from dotenv import load_dotenv

app = Flask(__name__)

# Carrega senhas do .env com segurança
load_dotenv()

# Puxa a URL com segurança
uri = os.getenv("MONGO_URI")
client = MongoClient(uri)

db = client.climora_db
users_collection = db.users

# conexão com banco de dados
client = MongoClient("mongodb+srv://adminf_climora:<db_password>@climora.iota2fu.mongodb.net/?appName=climora")
db = client.climora_db
users_collection = db.users

# formatação do numero de telefone
def formatar_telefone(ddd, numero):
    ddd_limpo = re.sub(r'\D', '', str(ddd))
    num_limpo = re.sub(r'\D', '', str(numero))
    return f"({ddd_limpo}) {num_limpo[:5]}-{num_limpo[5:]}"

@app.route('/api/register', methods=['POST'])
def register():
    dados = request.json
    
    # Verificação de senha
    if dados.get('senha') != dados.get('confirmar_senha'):
        return jsonify({"erro": "As senhas não batem."}), 400

    # Verifica se o email já existe
    if users_collection.find_one({"email": dados.get('email')}):
        return jsonify({"erro": "Email já cadastrado."}), 409

    # Hash da senha e ID interno
    id_interno = str(uuid.uuid4())
    telefone_formatado = formatar_telefone(dados.get('ddd'), dados.get('numero'))
    
    # Converter senha em hash
    senha_bytes = dados['senha'].encode('utf-8')
    hash_senha = bcrypt.hashpw(senha_bytes, bcrypt.gensalt()).decode('utf-8')

    novo_usuario = {
        "user_id": id_interno,
        "nome": dados.get('nome'),
        "cpf": dados.get('cpf'),
        "data_nascimento": dados.get('nascimento'),
        "responsavel": dados.get('responsavel', ''),
        "telefone": telefone_formatado,
        "cep": dados.get('cep'),
        "endereco": dados.get('endereco'),
        "email": dados.get('email'),
        "email_recuperacao": dados.get('email_recuperacao'),
        "password_hash": hash_senha
    }

    users_collection.insert_one(novo_usuario)
    return jsonify({"mensagem": "Conta criada com sucesso!"}), 201

@app.route('/api/login', methods=['POST'])
def login():
    dados = request.json
    email = dados.get('email')
    senha = dados.get('senha')

    user = users_collection.find_one({"email": email})

    if user:
        # Checa a senha do banco com a que o usuário digitou
        if bcrypt.checkpw(senha.encode('utf-8'), user['password_hash'].encode('utf-8')):
            # Simula a passagem para a tela de 2FA
            return jsonify({
                "mensagem": "Login aceito. Requer 2FA.",
                "user_id": user['user_id']
            }), 200
            
    return jsonify({"erro": "Credenciais inválidas."}), 401

if __name__ == '__main__':
    # Rodando na porta 5000
    app.run(host='0.0.0.0', port=5000, debug=True)