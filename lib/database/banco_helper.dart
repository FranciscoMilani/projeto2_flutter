import 'dart:async';
import 'package:projeto_avaliativo_2/model/produto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BancoHelper {
  static const arquivoDoBancoDeDados = 'ta_2_6.db';
  static const arquivoDoBancoDeDadosVersao = 10;
  static Database? _bancoDeDados;

  Future<Database> get bancoDeDados async {
    if (_bancoDeDados != null) return _bancoDeDados!;
    await iniciarBD();
    return _bancoDeDados!;
  }

  // Inicializa/Cria o banco de dados
  Future<void> iniciarBD() async {
    if (_bancoDeDados != null) return;

    String dbPath = await getDatabasesPath();
    String fullPath = join(dbPath, arquivoDoBancoDeDados);

    _bancoDeDados = await openDatabase(
      fullPath,
      version: arquivoDoBancoDeDadosVersao,
      onCreate: _funcaoCriacaoBD,
      onUpgrade: _funcaoAtualizarBD,
    );
  }

  // Cria as tabelas
  Future<void> _funcaoCriacaoBD(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produto (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        preco REAL NOT NULL,
        avaliacao REAL NOT NULL,
        contagemAvaliacao INTEGER NOT NULL,
        categoria TEXT NOT NULL,
        descricao TEXT,
        urlImagem TEXT
      )
    ''');
  }

  // Atualiza banco quando necessário
  Future<void> _funcaoAtualizarBD(Database db, int oldVersion, int newVersion) async {
    return null;
    await db.execute('DROP TABLE IF EXISTS avaliacao');
    await db.execute('''
      ALTER TABLE produto ADD COLUMN contagemAvaliacao INTEGER NOT NULL DEFAULT 0
    ''');
    await db.execute('''
      ALTER TABLE produto ADD COLUMN categoria TEXT NOT NULL DEFAULT ''
    ''');
  }

  // Insere/atualiza um produto no banco
  Future<int> upsertProduto(Produto produto) async {
    final db = await bancoDeDados;
    return await db.insert(
      'produto',
      produto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Deleta um produto por ID
  Future<int> deletar(int id) async {
    final db = await bancoDeDados;
    return await db.delete('produto', where: 'id = ?', whereArgs: [id]);
  }

  // Busca todos os produtos registrados no banco
  Future<List<Produto>> buscarProdutos() async {
    final db = await bancoDeDados;
    final List<Map<String, Object?>> dbProducts = await db.query('produto');

    return dbProducts.map((produtoMap) => Produto(
      id: produtoMap['id'] as int,
      nome: produtoMap['nome'] as String,
      preco: produtoMap['preco'] as double,
      avaliacao: produtoMap['avaliacao'] as double,
      contagemAvaliacao: produtoMap['contagemAvaliacao'] as int,
      categoria: produtoMap['categoria'] as String,
      descricao: produtoMap['descricao'] as String?,
      urlImagem: produtoMap['urlImagem'] as String?,
    )).toList();
  }
}
