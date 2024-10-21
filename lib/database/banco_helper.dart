import 'dart:async';
import 'package:projeto_avaliativo_2/model/produto.dart';
import 'package:path/path.dart';
import 'package:projeto_avaliativo_2/model/tabela_produto.dart';
import 'package:projeto_avaliativo_2/model/avaliacao.dart';
import 'package:projeto_avaliativo_2/model/tabela_produto_avaliacao.dart';
import 'package:sqflite/sqflite.dart';

class BancoHelper {
  static const arquivoDoBancoDeDados = 'pa2.db';
  static const arquivoDoBancoDeDadosVersao = 1;
  static late Database _bancoDeDados;

  iniciarBD() async {
    String dbPath = await getDatabasesPath();
    String fullPath = join(dbPath, arquivoDoBancoDeDados);

    _bancoDeDados = await openDatabase(fullPath,
        version: arquivoDoBancoDeDadosVersao,
        onCreate: funcaoCriacaoBD,
        onUpgrade: funcaoAtualizarBD,
        onDowngrade: funcaoDowngradeBD);
  }

  Future funcaoCriacaoBD(Database db, int version) async {
    await db.execute('''
            CREATE TABLE ${TabelaAvaliacao.tabela} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ${TabelaAvaliacao.colunaTaxa} REAL NOT NULL,
            ${TabelaAvaliacao.colunaContagem} INTEGER NOT NULL
            )
        ''');

    await db.execute('''
        CREATE TABLE ${TabelaProduto.tabela} (
          ${TabelaProduto.colunaId} INTEGER PRIMARY KEY,
          ${TabelaProduto.colunaNome} TEXT NOT NULL,
          ${TabelaProduto.colunaPreco} INTEGER NOT NULL,
          ${TabelaProduto.colunaDescricao} TEXT NOT NULL,
          ${TabelaProduto.colunaCategoria} TEXT NOT NULL,
          ${TabelaProduto.colunaUrlImagem} INTEGER NOT NULL,
          ${TabelaAvaliacao.colunaId} INTEGER,
          FOREIGN KEY (rating_id) REFERENCES ${TabelaAvaliacao.tabela}(id)
        )
      ''');
  }

  Future funcaoAtualizarBD(Database db, int oldVersion, int newVersion) async {
    //controle dos comandos sql para novas versões

    if (oldVersion < 2) {
      //Executa comandos
    }
  }

  Future funcaoDowngradeBD(Database db, int oldVersion, int newVersion) async {
    //controle dos comandos sql para voltar versões.
    //Estava-se na 2 e optou-se por regredir para a 1
  }

  Future<int> inserir(Map<String, dynamic> row) async {
    await iniciarBD();
    return await _bancoDeDados.insert(TabelaProduto.tabela, row);
  }

  Future<int> deletar(int idPessoa) async {
    await iniciarBD();
    return _bancoDeDados.delete(TabelaProduto.tabela,
        where: '${TabelaProduto.colunaId} = ?', whereArgs: [idPessoa]);
  }

  Future<List<Produto>> buscarProdutos() async {
    await iniciarBD();

    final List<Map<String, Object?>> dbProducts =
        await _bancoDeDados.rawQuery('''
    SELECT 
      p.${TabelaProduto.colunaId} AS pId,
      p.${TabelaProduto.colunaNome} AS pNome,
      p.${TabelaProduto.colunaPreco} AS pPreco,
      p.${TabelaProduto.colunaDescricao} AS pDes,
      p.${TabelaProduto.colunaCategoria} AS pCat,
      p.${TabelaProduto.colunaUrlImagem} AS pImgUrl,
      r.${TabelaAvaliacao.colunaTaxa} AS rTaxa,
      r.${TabelaAvaliacao.colunaContagem} AS rContagem
    FROM ${TabelaProduto.tabela} p
    LEFT JOIN ${TabelaAvaliacao.tabela} r
    ON p.rating_id = r.id
  ''');

    return [
      for (final {
            TabelaProduto.colunaId: pId as int,
            TabelaProduto.colunaNome: pNome as String,
            TabelaProduto.colunaPreco: pPreco as double,
            TabelaProduto.colunaDescricao: pDes as String,
            TabelaProduto.colunaCategoria: pCat as String,
            TabelaProduto.colunaUrlImagem: pImgUrl as String,
            'rTaxa': rTaxa as double?,
            'rContagem': rContagem as int?,
          } in dbProducts)
        Produto(
          id: pId,
          nome: pNome,
          preco: pPreco,
          descricao: pDes,
          categoria: pCat,
          urlImagem: pImgUrl,
          avaliacao: Avaliacao(
            taxa: rTaxa ?? 0.0,
            contagem: rContagem ?? 0,
          ),
        ),
    ];
  }
}
