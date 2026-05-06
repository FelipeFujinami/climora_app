import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../repositories/api_repository.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _api = ApiRepository();

  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _nascimentoCtrl = TextEditingController();
  final _responsavelCtrl = TextEditingController();
  final _dddCtrl = TextEditingController();
  final _numCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _emailRecCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaSenhaCtrl = TextEditingController();

  bool _isMenorDeIdade = false;
  bool _isLoading = false;

  // Função simples pra checar idade por aproximação de ano pra mostrar o campo do responsável
  void _verificarIdade(String data) {
    try {
      int anoNasc = int.parse(data.split('/').last);
      int anoAtual = DateTime.now().year;
      setState(() {
        _isMenorDeIdade = (anoAtual - anoNasc) < 18;
      });
    } catch (e) {
      // Ignorar erro de formatação enquanto digita
    }
  }

  void _registrar() async {
    if (_senhaCtrl.text != _confirmaSenhaCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> dados = {
      'nome': _nomeCtrl.text,
      'cpf': _cpfCtrl.text,
      'nascimento': _nascimentoCtrl.text,
      'responsavel': _responsavelCtrl.text,
      'ddd': _dddCtrl.text,
      'numero': _numCtrl.text,
      'cep': _cepCtrl.text,
      'endereco': _endCtrl.text,
      'email': _emailCtrl.text,
      'email_recuperacao': _emailRecCtrl.text,
      'senha': _senhaCtrl.text,
      'confirmar_senha': _confirmaSenhaCtrl.text,
    };

    final result = await _api.cadastrar(dados);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.containsKey('erro')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['erro']), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Volta pro login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _campoTexto('Nome Completo', _nomeCtrl),
            _campoTexto('CPF', _cpfCtrl, numerico: true),
            TextField(
              controller: _nascimentoCtrl,
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento (DD/MM/AAAA)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
              onChanged: _verificarIdade,
            ),
            const SizedBox(height: 16),
            if (_isMenorDeIdade)
              _campoTexto('Nome do Responsável', _responsavelCtrl),

            // Layout do Telefone
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _dddCtrl,
                    decoration: const InputDecoration(
                      labelText: 'DDD',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: _numCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Número',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _campoTexto('CEP', _cepCtrl, numerico: true),
            _campoTexto('Endereço Completo', _endCtrl),
            _campoTexto('E-mail Principal', _emailCtrl, email: true),
            _campoTexto('E-mail de Recuperação', _emailRecCtrl, email: true),
            _campoTexto('Senha', _senhaCtrl, oculta: true),
            _campoTexto('Confirmar Senha', _confirmaSenhaCtrl, oculta: true),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _registrar,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CRIAR CONTA'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    bool oculta = false,
    bool numerico = false,
    bool email = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: oculta,
        keyboardType: numerico
            ? TextInputType.number
            : (email ? TextInputType.emailAddress : TextInputType.text),
        inputFormatters: numerico
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
