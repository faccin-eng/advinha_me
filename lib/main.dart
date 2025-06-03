import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //duplicado?
import 'package:flutter/services.dart' show rootBundle;

void main(List<String> args) {
  runApp(MenuApp());
}

class MenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu de Jogos',
      initialRoute: '/',
      routes: {
        '/': (context) => MenuScreen(),
        '/mimica': (context) => JogoScreen(
          titulo: 'Jogo da Mímica',
          assetPath: 'assets/mimica.json',
          corFundo: Color.fromRGBO(110, 110, 201, 0.8),
          corBotaoVoltar: Color.fromRGBO(179, 51, 128, 1),
          corBotaoGerar: Color.fromRGBO(51, 128, 0, 1),
          corTexto: Colors.white,
          modoPaisagem: false,
          usarTemporizador: false,
        ),
        '/advinha': (context) => JogoScreen(
          titulo: 'Advinha Quem',
          assetPath: 'assets/advinha.json',
          corFundo: Color.fromRGBO(89, 89, 136, 0.98),
          corBotaoVoltar: Color.fromRGBO(179, 51, 128, 1),
          corBotaoGerar: Color.fromRGBO(0, 128, 179, 1),
          corTexto: Colors.black,
          modoPaisagem: true,
          usarTemporizador: true,
        ),
      },
    );
  }
}

class MenuScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Advinha-Me'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(131, 138, 0, 1),
      ),
      body: Container(
        color: const Color.fromARGB(255, 7, 31, 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 500,
              height: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(102, 0, 128, 1),
                  foregroundColor: Colors.black,
                  textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: (){
                  Navigator.pushNamed(context, '/mimica');
                },
                child: Text('Jogo da Mimica'),
                ),
              ),
              SizedBox(height:20),
              SizedBox(
                width: 500,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(0, 102, 0, 1),
                    foregroundColor: Colors.black,
                    textStyle: TextStyle(fontSize:20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: (){
                    Navigator.pushNamed(context, '/advinha');
                  },
                  child: Text('Advinha Quem')
              ),
            ),
          ],
        )
      ),
    );
  }
}
class JogoScreen extends StatefulWidget {
  final String titulo;
  final String assetPath;
  final Color corFundo;
  final Color corBotaoVoltar;
  final Color corBotaoGerar;
  final Color corTexto;
  final bool modoPaisagem;
  final bool usarTemporizador;

  JogoScreen({
    required this.titulo,
    required this.assetPath,
    required this.corFundo,
    required this.corBotaoVoltar,
    required this.corBotaoGerar,
    required this.corTexto,
    required this.modoPaisagem,
    required this.usarTemporizador,
  });

  @override
  _JogoScreenState createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen> {
  List<String> _palavras = [];
  String _palavraAtual = '';
  bool _mostraPalavra = false; //se a palavra é exibida em função do temporizador
  int _contador = 3;

  @override
  void initState() {
    super.initState();
    if (widget.modoPaisagem){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
       DeviceOrientation.landscapeRight,
      ]);
    }
    _carregarPalavras();
    if (widget.usarTemporizador){
      _startTemporizador();
    } else {
      _gerarNovaPalavra();
      _mostraPalavra = true;
    }
  }

  @override
  void dispose(){
    super.dispose();
    if (widget.modoPaisagem){
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  Future<void> _carregarPalavras() async {
    try {
    final jsonString = await rootBundle.loadString(widget.assetPath);
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final List<dynamic> lista = data['palavras'];
    setState(() {
      _palavras = lista.map((e) => e.toString()).toList();
      if (!widget.usarTemporizador){
      _gerarNovaPalavra();}
    });
    } catch (e) {
      print('Erro ao carregar ${widget.assetPath}: $e');
    }
  }

  void _gerarNovaPalavra() {
    if (_palavras.isEmpty) return;
    final rnd = Random();
    final idx = rnd.nextInt(_palavras.length);
    setState(() {
      _palavraAtual = _palavras[idx];
      _mostraPalavra = true;
    });
  }

void _startTemporizador(){
  setState(() {
    _mostraPalavra = false;
    _contador = 3;
  });
  Timer.periodic(Duration(seconds: 1), (timer){
    setState(() {
      _contador -=1;
    });
    if (_contador == 0){
      timer.cancel();
      _gerarNovaPalavra();
    }
  }); //alteração ;
}


  @override
  Widget build(BuildContext context) {
    double tamanhoFonte = 36;
    if (widget.modoPaisagem){
      tamanhoFonte = 58;
    }
    return Scaffold(
      backgroundColor: widget.corFundo,
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: widget.corBotaoVoltar,
        centerTitle: true,
      ),
      body: SafeArea(
        right: true,
        child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: widget.usarTemporizador && !_mostraPalavra ? Text( 
                '$_contador', 
                style: TextStyle(
                  fontSize: tamanhoFonte + 20,
                  fontWeight: FontWeight.bold,
                  color: widget.corTexto,
                ),
              )
              : Text(
                _palavraAtual.isEmpty ? 'Carregando...' : _palavraAtual,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: tamanhoFonte,
                  fontWeight: FontWeight.bold,
                  color: widget.corTexto,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.corBotaoVoltar,
                      foregroundColor: Colors.white,
                      fixedSize: Size(140, 60),
                      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Voltar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.corBotaoGerar,
                      foregroundColor: Colors.white,
                      fixedSize: Size(140, 60),
                      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (widget.usarTemporizador){
                        _startTemporizador();
                      } else { _gerarNovaPalavra();
                      }
                    },
                    child: Text('Próxima'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}