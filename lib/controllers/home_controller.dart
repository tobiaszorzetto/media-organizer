import 'package:flutter/material.dart';
import 'package:media_organizer/models/media_model.dart';

class HomeController {
  static HomeController instance = HomeController();

  List<MediaType> visibleMedias = [];
  int sortType = 0;
  double ratingObserved = 0;

  bool filterMenuvisible = false;
  RangeValues filterRatingsObservados = RangeValues(0, 10);
  RangeValues filterDateObservados = RangeValues(
      Catalogo.instance.oldestDateTime.millisecondsSinceEpoch.toDouble(),
      DateTime.now().millisecondsSinceEpoch.toDouble());

  pegarMediasJson() async {
    await Catalogo.instance.pegarMediasJson();
    HomeController.instance.filterMedia();
  }

  void updateVisibleMedias(List<MediaType> nemMedias) {
    visibleMedias = nemMedias;
  }

  void changeFilterMenuVisbility() {
    filterMenuvisible = !filterMenuvisible;
  }

  void filterMedia({String pesquisa = ''}) {
    final List<MediaType> confirmados = [];

    for (MediaType tipoMedia in Catalogo.instance.medias) {
      confirmados.add(MediaType(tipoMedia.name, tipoMedia.id));
      confirmados[tipoMedia.id].medias =
          Catalogo.instance.medias[tipoMedia.id].medias.where((media) {
        if (media.rating < filterRatingsObservados.start.round() ||
            media.rating > filterRatingsObservados.end.round()) {
          return false;
        }
        if (media.dateTime.millisecondsSinceEpoch <
                filterDateObservados.start ||
            media.dateTime.millisecondsSinceEpoch > filterDateObservados.end) {
          return false;
        }
        if (media.categorias.isEmpty) {
          return media.name.toLowerCase().contains(pesquisa.toLowerCase());
        }
        for (Categoria categoria in media.categorias) {
          if (Catalogo.instance.categoriasFiltradas[categoria.id]) {
            return media.name.toLowerCase().contains(pesquisa.toLowerCase());
          }
        }

        return false;
      }).toList();
    }
    visibleMedias = confirmados;
    sortMedias();
  }

  void sortMedias() {
    for (MediaType mediaType in visibleMedias) {
      mediaType.medias.sort((item1, item2) => _compare(item1, item2));
    }
  }

  int _compare(MediaModel item1, MediaModel item2) {
    if (sortType == 0) {
      return item1.name.compareTo(item2.name);
    } else if (sortType == 1) {
      return item2.name.compareTo(item1.name);
    } else if (sortType == 2) {
      return item1.dateTime.compareTo(item2.dateTime);
    } else if (sortType == 3) {
      return item2.dateTime.compareTo(item1.dateTime);
    }
    return -1;
  }

  void createCategory(
    String name,
    String description,
  ) {
    Catalogo.instance.addCategory(
        Categoria(name, description, Catalogo.instance.categorias.length));
    filterMedia();
  }
}
