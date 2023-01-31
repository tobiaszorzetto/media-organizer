import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:media_organizer/models/media_model.dart';

class StatisticsController extends ChangeNotifier {
  static StatisticsController instance = StatisticsController();

  DateTime selectedDate = DateTime.now();
  String selectedName = '';
  int quant = 0;
  List<MediaType> mediasViewed = Catalogo.instance.medias;
  List<bool> categoriasEscolhidas =
      Catalogo.instance.categorias.map((e) => false).toList();
  List<bool> mediasEscolhidas =
      Catalogo.instance.medias[0].medias.map((e) => false).toList();

  void filterMediasGoal() {
    final List<MediaType> confirmados = [];

    for (MediaType tipoMedia in Catalogo.instance.medias) {
      confirmados.add(MediaType(tipoMedia.name, tipoMedia.id));
      confirmados[tipoMedia.id].medias =
          Catalogo.instance.medias[tipoMedia.id].medias.where((media) {
        if (!_anyCategorySelected(media)) {
          return false;
        }
        return true;
      }).toList();
    }

    mediasViewed = confirmados;
  }

  bool _anyCategorySelected(MediaModel media) {
    if (media.categorias.isEmpty) {
      return true;
    }
    for (Categoria cat in media.categorias) {
      if (categoriasEscolhidas[cat.id]) {
        return true;
      }
    }
    return false;
  }
}
