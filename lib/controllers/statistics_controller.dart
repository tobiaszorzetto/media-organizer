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
  DateTime showedCreationDate = DateTime.now();
  int showedTypeId = 0;
  List<ChartData> chartData = [];

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
    var newGoal = Goal(selectedName, categorias, quantMediasGoal, selected,
        selectedDate, DateTime.now(), typeId);

    Catalogo.instance.goals.add(newGoal);
  }

  void showGoal(Goal goal) {
    showedGoalName = goal.name;
    showedCategorias = goal.categorias;
    showedMedias = goal.selectedMedias;
    showedQuant = goal.quantMedias;
    showedDeadline = goal.deadline;
    showedCreationDate = goal.creationDate;
    showedTypeId = goal.typeId;
  }

  void showGraph() {
    chartData = [];
    List<MediaModel> showedMediasSorted;
    if (showedMedias.isEmpty) {
      showedMediasSorted = showGraphQuant();
    } else {
      showedMediasSorted = showGraphSelectedMedias();
    }
    showedMediasSorted.sort((item1, item2) => _compare(item1, item2));
    quant = 0;
    bool addedGoalCreation = false;
    for (MediaModel media in showedMediasSorted) {
      quant++;
      if (media.dateTimeConsumed.millisecond < showedCreationDate.millisecond &&
          !addedGoalCreation) {
        addedGoalCreation = true;
        chartData.add(
            ChartData(showedGoalName, showedCreationDate, quant.toDouble()));
      }
      chartData
          .add(ChartData(media.name, media.dateTimeConsumed, quant.toDouble()));
    }

    if (!addedGoalCreation) {
      chartData.add(ChartData(showedGoalName, showedCreationDate, 0));
    }

    chartData.add(ChartData("agora", DateTime.now(), quant.toDouble()));
    chartData.sort((item1, item2) => _compare2(item1, item2));
  }

  List<MediaModel> showGraphQuant() {
    var medias = Catalogo.instance.medias[showedTypeId].medias;
    return medias
        .where((element) =>
            (element.categorias
                    .toSet()
                    .intersection(showedCategorias.toSet())
                    .isNotEmpty ||
                showedCategorias.isEmpty) &&
            element.dateTimeConsumed.millisecond >
                showedCreationDate.millisecond)
        .toList();
  }

  List<MediaModel> showGraphSelectedMedias() {
    return showedMedias
        .where((element) => element.dateTimeConsumed.millisecondsSinceEpoch > 0)
        .toList();
  }

  _compare2(ChartData item1, ChartData item2) {
    if (item1.xAxis.millisecondsSinceEpoch >
        item2.xAxis.millisecondsSinceEpoch) {
      return 1;
    }
    return 0;
  }
}

_compare(MediaModel item1, MediaModel item2) {
  if (item1.dateTimeConsumed.millisecondsSinceEpoch >
      item2.dateTimeConsumed.millisecondsSinceEpoch) {
    return 1;
  }
  return 0;
}

class ChartData {
  final String name;
  final DateTime xAxis;
  final double yAxis;

  ChartData(this.name, this.xAxis, this.yAxis);
}
