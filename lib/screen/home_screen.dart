import 'package:flutter/material.dart';
import 'package:projeto_avaliativo_2/model/produto.dart';
import 'package:projeto_avaliativo_2/screen/produto_form_screen.dart';
import 'package:projeto_avaliativo_2/database/banco_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProdutoListScreen extends StatefulWidget {
  const ProdutoListScreen({super.key});

  @override
  _ProdutoListScreenState createState() => _ProdutoListScreenState();
}

class _ProdutoListScreenState extends State<ProdutoListScreen> {
  BancoHelper bdHelper = BancoHelper();
  List<Produto> produtos = List.empty();
  bool isLoading = true;

  @override
  void initState() {
    consultar();
    super.initState();
    bdHelper.iniciarBD();
  }

  void deletarProduto(int id) {
    setState(() {
      produtos.removeWhere((produto) => produto.id == id);
    });
  }

  void editarProduto(Produto produto) {
    setState(() {
      if (produto.id == 0) {
        produto.id = produtos.isEmpty ? 1 : produtos.last.id + 1;
        produtos.add(produto);
      } else {
        int index = produtos.indexWhere((p) => p.id == produto.id);
        produtos[index] = produto;
      }
    });
  }

  void _abrirTelaEdicao([Produto? produto]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdutoFormScreen(
          produto: produto,
          onSalvar: editarProduto,
        ),
      ),
    );
  }

  void _confirmarDelecao(Produto produto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              deletarProduto(produto.id);
              Navigator.pop(context);
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> consultar() async {
    try {
      final dadosArmazenados = await bdHelper.buscarTodosProdutos();

      if (dadosArmazenados.isNotEmpty){
        setState(() {
          produtos = dadosArmazenados;
          isLoading = false;
        });

        return;
      }

      return http
          .get(Uri.parse('https://fakestoreapi.com/products'))
          .then((data) async {
        if (data.statusCode == 200) {
          final produtosEntities = (jsonDecode(data.body) as List)
              .map((data) => Produto.fromJson(data))
              .toList();

          await bdHelper.inserirProdutos(produtosEntities);

          setState(() {
            this.produtos = produtosEntities;
            isLoading = false;
          });
        } else {
          throw Exception('Buscar produtos: Erro chamada HTTP');
        }
      });
    } catch (e) {
      print('Erro na consulta de produtos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text('Lista de Produtos',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final produto = produtos[index];
                      return Card(
                        elevation: 4,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(produto.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produto.descricao ?? "",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Preço: R\$${produto.preco.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          leading: (produto.urlImagem != null &&
                                  produto.urlImagem!.isNotEmpty)
                              ? ClipOval(
                                  child: Image.network(
                                  '${produto.urlImagem}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.scaleDown,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error,
                                        size: 50, color: Colors.red);
                                  },
                                ))
                              : Icon(Icons.image, size: 50),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _confirmarDelecao(produto),
                          ),
                          onTap: () => _abrirTelaEdicao(produto),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {} /*{ _sincronizarDados() }*/, // TODO
        child: Icon(Icons.replay_outlined),
      ),
    );
  }
}
