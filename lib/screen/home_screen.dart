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
  List<Produto> produtos = [];
  bool isLoading = true;
  bool primeiroUso = true;

  @override
  void initState() {
    super.initState();
    consultar();
  }

  // Sincroniza com os dados da API
  Future<void> sincronizarDados() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (response.statusCode == 200) {
        final List<dynamic> produtosApi = jsonDecode(response.body);

        List<Produto> produtosList = produtosApi.map((produtoJson) {
          return Produto.fromJson(produtoJson);
        }).toList();

        final dbHelper = BancoHelper();
        for (var produto in produtosList) {
          await dbHelper.upsertProduto(produto);
        }

        setState(() {
          produtos = produtosList;
          primeiroUso = false;
        });
      } else {
        throw Exception('Erro ao sincronizar dados');
      }
    } catch (e) {
      print('Erro de sincronização de dados da API: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> consultar() async {
    setState(() {
      isLoading = true;
    });

    final dbHelper = BancoHelper();
    await dbHelper.iniciarBD();
    final produtosLocal = await dbHelper.buscarProdutos();

    // Busca do banco se houver produto. Se não, busca da API
    if (produtosLocal.isNotEmpty) {
      setState(() {
        produtos = produtosLocal;
        isLoading = false;
      });
    } else if (primeiroUso) {
      await sincronizarDados();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deletarProduto(int id) async {
    final dbHelper = BancoHelper();
    await dbHelper.deletarProduto(id);
    await consultar();
  }

  Future<void> editarProduto(Produto produto) async {
    final dbHelper = BancoHelper();
    await dbHelper.upsertProduto(produto);
    await consultar();
  }

  void _abrirTelaEdicao(Produto? produto) {
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
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await deletarProduto(produto.id);
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
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
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(produto.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto.descricao ?? "",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${produto.preco.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
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
                            return const Icon(Icons.error,
                                size: 50, color: Colors.red);
                          },
                        ))
                        : const Icon(Icons.image, size: 50),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
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
        onPressed: isLoading ? null : sincronizarDados,
        backgroundColor: isLoading ? Colors.grey : Colors.blue,
        elevation: 5.0,
        child: const Icon(Icons.replay_outlined, color: Colors.white),
      ),
    );
  }
}
