class Produto {
  int id;
  String nome;
  double preco;
  double avaliacao;
  int contagemAvaliacao;
  String categoria;
  String? descricao;
  String? urlImagem;

  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.avaliacao,
    required this.contagemAvaliacao,
    required this.categoria,
    this.descricao,
    this.urlImagem,
  });

  // Mapeia o produto para inserir no banco
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'avaliacao': avaliacao,
      'contagemAvaliacao': contagemAvaliacao,
      'categoria': categoria,
      'descricao': descricao,
      'urlImagem': urlImagem,
    };
  }

  // Converte o JSON vindo da API para um objeto
  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] ?? 0,
      nome: json['title'] ?? '',
      preco: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      avaliacao: (json['rating']?['rate'] is num) ? (json['rating']?['rate'] as num).toDouble() : 0.0,
      contagemAvaliacao: json['rating']?['count'] ?? 0,
      categoria: json['category'] ?? '',
      descricao: json['description'] ?? '',
      urlImagem: json['image'] ?? '',
    );
  }
}
