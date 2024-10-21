import 'package:flutter/material.dart';
import 'package:projeto_avaliativo_2/model/avaliacao.dart';
import 'package:projeto_avaliativo_2/model/produto.dart';

class ProdutoFormScreen extends StatefulWidget {
  final Produto? produto;
  final Function(Produto) onSalvar;

  ProdutoFormScreen({this.produto, required this.onSalvar});

  @override
  _ProdutoFormScreenState createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late int id;
  late String nome;
  late String descricao;
  late double preco;
  late String categoria;
  late String urlImagem;
  late Avaliacao avaliacao;

  @override
  void initState() {
    super.initState();
    id = widget.produto?.id ?? 0;
    nome = widget.produto?.nome ?? '';
    descricao = widget.produto?.descricao ?? '';
    preco = widget.produto?.preco ?? 0.0;
    urlImagem = widget.produto?.urlImagem ?? '';
    categoria = widget.produto?.categoria ?? '';
    avaliacao = widget.produto?.avaliacao ?? Avaliacao(taxa: 0.0, contagem: 0);
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSalvar(Produto(
        id: id,
        nome: nome,
        descricao: descricao,
        preco: preco,
        urlImagem: urlImagem,
        categoria: categoria,
        avaliacao: Avaliacao(
          taxa: avaliacao.taxa,
          contagem: avaliacao.contagem,
        ),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id == 0 ? 'Novo Produto' : 'Editar Produto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: nome,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
                onSaved: (value) {
                  nome = value!;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: descricao,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSaved: (value) {
                  descricao = value!;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: preco.toString(),
                decoration: InputDecoration(
                  labelText: 'Preço',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Preço inválido';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Preço deve ser maior que zero';
                  }
                  return null;
                },
                onSaved: (value) {
                  preco = double.parse(value!);
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: urlImagem,
                decoration: InputDecoration(
                  labelText: 'Url de Imagem',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSaved: (value) {
                  urlImagem = value!;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: avaliacao.taxa.toString(),
                decoration: InputDecoration(
                  labelText: 'Avaliação (0 a 5)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Avaliação inválida';
                  }
                  final double rating = double.parse(value);
                  if (rating < 0 || rating > 5) {
                    return 'Avaliação deve estar entre 0 e 5';
                  }
                  return null;
                },
                onSaved: (value) {
                  avaliacao.taxa = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
