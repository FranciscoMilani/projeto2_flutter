import 'package:projeto_avaliativo_2/model/avaliacao.dart';

class Produto {
  int id;
  String nome;
  double preco;
  Avaliacao avaliacao;
  String categoria;
  String? descricao;
  String? urlImagem;

  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.avaliacao,
    required this.categoria,
    this.descricao,
    this.urlImagem,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'avaliacao': avaliacao.toMap(),
      'categoria': categoria,
      'descricao': descricao,
      'urlImagem': urlImagem,
    };
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] ?? 0,
      nome: json['title'] ?? '',
      preco: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      avaliacao: Avaliacao(
        taxa: (json['rating']?['rate'] is num)
            ? (json['rating']?['rate'] as num).toDouble()
            : 0.0,
        contagem: json['rating']?['count'] ?? 0,
      ),
      categoria: json['category'] ?? '',
      descricao: json['description'] ?? '',
      urlImagem: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJsonWithAvaliacao() {
    return {
      ...toMap(),
      'avaliacao': avaliacao.toMap(), // Ensure this returns the correct fields for Avaliacao
    };
  }
}
