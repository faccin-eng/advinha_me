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
          corFundo: Color.fromRGBO(55, 45, 85, 1),
          corBotaoVoltar: Color.fromRGBO(126, 78, 78, 0),
          corBarraSuperior: Color.fromRGBO(45, 85, 65, 0.76),
          corBotaoGerar: Color.fromRGBO(80, 140, 100, 1),
          corTexto: const Color.fromARGB(255, 255, 255, 255),
          modoPaisagem: false,
          usarTemporizador: false,
        ),
        '/advinha': (context) => JogoScreen(
          titulo: 'Advinha Quem',
          assetPath: 'assets/advinha.json',
          corFundo: Color.fromRGBO(45, 85, 65, 1),
          corBotaoVoltar: Color.fromRGBO(126, 78, 78, 0), // transparente
          corBarraSuperior: Color.fromARGB(122, 119, 0, 113),
          corBotaoGerar: Color.fromRGBO(120, 80, 160, 1),
          corTexto: const Color.fromARGB(255, 255, 255, 255),
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
        backgroundColor: Color.fromRGBO(60, 80, 100, 1),
        titleTextStyle: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: const Color.fromARGB(255, 0, 0, 0), // ou a cor que você preferir
  ),
      ),
      body: Container(
  color: const Color.fromRGBO(25, 25, 35, 1),
  width: double.infinity,
  height: double.infinity,
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 300, // Tamanho fixo menor
          height: 80,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(120, 80, 160, 1),
              foregroundColor: Colors.black,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onPressed: (){
              Navigator.pushNamed(context, '/mimica');
            },
            child: Text('Jogo da Mimica'),
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: 300, // Tamanho fixo menor
          height: 80,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(80, 140, 100, 1),
              foregroundColor: Colors.black,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
),
    );
  }
}
class JogoScreen extends StatefulWidget {
  final String titulo;
  final String assetPath;
  final Color corFundo;
  final Color corBotaoVoltar;
  final Color corBarraSuperior;
  final Color corBotaoGerar;
  final Color corTexto;
  final bool modoPaisagem;
  final bool usarTemporizador;

  JogoScreen({
    required this.titulo,
    required this.assetPath,
    required this.corFundo,
    required this.corBotaoVoltar,
    required this.corBarraSuperior,
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
  List<String> _palavrasUsadas = [];
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
    if (_palavrasUsadas.length >= _palavras.length){
      _palavrasUsadas.clear();
    }
    List<String> palavrasDisponiveis = _palavras.where((palavra) => !_palavrasUsadas.contains(palavra)).toList();
    
    final rnd = Random();
    final idx = rnd.nextInt(palavrasDisponiveis.length);
    setState(() {
      _palavraAtual = palavrasDisponiveis[idx];
      _palavrasUsadas.add(_palavraAtual);
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
        backgroundColor: widget.corBarraSuperior,
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