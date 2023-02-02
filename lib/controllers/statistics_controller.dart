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

  bool hasDeadline = false;
  bool selectMedias = false;
  int quantMediasGoal = 10;

  String showedGoalName = '';
  List<Categoria> showedCategorias = [];
  List<MediaModel> showedMedias = [];
  int showedQuant = 0;
  DateTime showedDeadline = DateTime.now();

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

  void updateQuantMediasGoal(int value) {
    if (selectMedias) {
      quantMediasGoal =
          mediasEscolhidas.where((element) => element = true).length;
    } else {
      quantMediasGoal = value;
    }
  }

  void createGoal(int typeId) {
    List<Categoria> categorias = Catalogo.instance.categorias
        .where((element) => categoriasEscolhidas[element.id])
        .toList();
    List<MediaModel> selected = [];
    for (int i = 0; i < mediasEscolhidas.length; i++) {
      if (mediasEscolhidas[i]) {
        selected.add(mediasViewed[typeId].medias[i]);
      }
    }
    var newGoal =
        Goal(selectedName, categorias, quantMediasGoal, selected, selectedDate);

    Catalogo.instance.goals.add(newGoal);
  }

  void showGoal(Goal goal) {
    showedGoalName = goal.name;
    showedCategorias = goal.categorias;
    showedMedias = goal.selectedMedias;
    showedQuant = goal.quantMedias;
    showedDeadline = goal.deadline;
  }
}
