import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:media_organizer/models/media_model.dart';

class HomeController extends ChangeNotifier {
  static HomeController instance = HomeController();

  TextEditingController descriptionController = TextEditingController();

  String overview = '';
  ValueNotifier<double> ratingApi = ValueNotifier(0);
  bool exit = true;
  bool consumed = true;

  List<MediaType> visibleMedias = [];
  int sortType = 0;

  bool filterMenuvisible = false;
  bool filterShowOnlyConsumed = true;
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
        if (filterShowOnlyConsumed &&
            media.dateTimeConsumed.millisecondsSinceEpoch == 0) {
          return false;
        }
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

  pegarApi(String media, int typeId) async {
    var dio = Dio();
    var response;
    if (typeId == 0) {
      response = await dio.get(
          "https://api.themoviedb.org/3/search/movie?api_key=0e74149306746790179d66dcb245cdfe&query==$media");
    } else {
      response = await dio.get(
          "https://api.themoviedb.org/3/search/tv?api_key=0e74149306746790179d66dcb245cdfe&query=$media");
    }
    if (response.statusCode == 200) {
      try {
        HomeController.instance.overview =
            (response.data["results"][0]["overview"]).toString();
        ratingApi.value =
            response.data["results"][0]["vote_average"].toDouble();
      } catch (e) {}
    } else {}
  }

  createMedia(
      {required String name,
      String description = '',
      required String imagem,
      required dynamic categoriasEscolhidas,
      required MediaType tipoSelected}) async {
    DateTime dateTimeConsumed = DateTime.fromMillisecondsSinceEpoch(0);
    if (consumed) {
      dateTimeConsumed = DateTime.now();
    }

    Catalogo.instance.createMedia(
        name: name,
        rating: ratingApi.value,
        description: HomeController.instance.overview,
        categoriasEscolhidas: categoriasEscolhidas,
        imagem: imagem,
        tipoSelected: tipoSelected,
        dateTimeConsumed: dateTimeConsumed);

    HomeController.instance.filterMedia();
  }

  autoComplete(String name, int typeId) async {
    await pegarApi(name, typeId);
    descriptionController.text = overview;
    notifyListeners();
  }

  double getRating() {
    return ratingApi.value;
  }

  void editMedia(
      MediaModel media,
      String name,
      String description,
      double rating,
      List<bool> categoriasEscolhidas,
      bool consumed,
      bool wasConsumed) {
    media.name = name;
    media.description = description;
    media.rating = rating;
    media.categorias = [];
    for (int i = 0; i < categoriasEscolhidas.length; i++) {
      if (categoriasEscolhidas[i]) {
        media.categorias.add(Catalogo.instance.categorias[i]);
      }
    }
    if (consumed && !wasConsumed) {
      media.dateTimeConsumed = DateTime.now();
    } else if (!consumed && wasConsumed) {
      media.dateTimeConsumed = DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}
