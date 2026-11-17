import 'dart:math';

import 'level.dart';

/// Placa exibida no jogo: letras e cidade são derivadas do número, então a
/// mesma placa sempre aparece igual (inclusive depois de reabrir o app).
class Plate {
  final String letters;
  final String uf;
  final String city;

  const Plate(this.letters, this.uf, this.city);

  factory Plate.forNumber(int number, Level level) {
    final rnd = Random(number * 7919 + level.index * 104729);
    const alphabet = 'ABCDEFGHJKLMNPRSTUVWXYZ';
    final letters = List.generate(3, (_) => alphabet[rnd.nextInt(alphabet.length)]).join();
    final (uf, city) = _cities[rnd.nextInt(_cities.length)];
    return Plate(letters, uf, city);
  }

  static const _cities = <(String, String)>[
    ('SP', 'São Carlos'),
    ('SP', 'Sorocaba'),
    ('SP', 'Araras'),
    ('SP', 'Campinas'),
    ('SP', 'Ribeirão Preto'),
    ('SP', 'Ibaté'),
    ('SP', 'Araraquara'),
    ('MG', 'Ouro Preto'),
    ('MG', 'Uberlândia'),
    ('RJ', 'Paraty'),
    ('RJ', 'Niterói'),
    ('PR', 'Curitiba'),
    ('SC', 'Florianópolis'),
    ('RS', 'Gramado'),
    ('BA', 'Salvador'),
    ('PE', 'Olinda'),
    ('CE', 'Fortaleza'),
    ('AM', 'Manaus'),
    ('PA', 'Belém'),
    ('GO', 'Pirenópolis'),
    ('MT', 'Cuiabá'),
    ('MS', 'Bonito'),
    ('DF', 'Brasília'),
    ('ES', 'Vitória'),
  ];
}
