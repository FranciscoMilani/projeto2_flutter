class Avaliacao {
  double taxa;
  int contagem;

  Avaliacao({
    required this.taxa,
    required this.contagem,
  });

  Map<String, Object?> toMap() {
    return {
      'taxa': taxa,
      'contagem': contagem,
    };
  }

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      taxa: (json['rate'] != null) ? json['rate'].toDouble() : 0.0,
      contagem: json['count'] ?? 0,
    );
  }
}
