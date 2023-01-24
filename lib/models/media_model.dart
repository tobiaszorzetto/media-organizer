import 'package:flutter/material.dart';
import 'package:media_organizer/controllers/file_manager.dart';

class MediaModel {
  final String name;
  final double rating;
  final String description;
  final List<Categoria> categorias;
  final Widget? image;

  MediaModel(
      this.name, this.rating, this.description, this.categorias, this.image);

  Map toJson() => {
        'name': name,
        'rating': rating,
        'description': description,
        'categorias': categorias.map((e) => e.toJson()).toList()
      };

  factory MediaModel.fromJson(dynamic json) {
    var categoriasObjsJson = json['categorias'] as List;
    List<Categoria> _categorias =
        categoriasObjsJson.map((e) => Categoria.fromJson(e)).toList();
    return MediaModel(json['name'], json['rating'] as double,
        json['description'], _categorias, Icon(Icons.movie));
  }
}

class Categoria {
  final String name;
  final String description;
  final int id;

  Categoria(this.name, this.description, this.id);

  Map toJson() => {'name': name, 'description': description, 'id': id};

  factory Categoria.fromJson(dynamic json) {
    return Categoria(json['name'], json['description'], json['id']);
  }
}

class MediaType {
  final String name;
  final int id;
  List<MediaModel> medias = [];

  MediaType(this.name, this.id);

  Map toJson() => {
        'name': name,
        'id': id,
        'medias': medias.map((e) => e.toJson()).toList()
      };

  factory MediaType.fromJson(dynamic json) {
    var mediaType = MediaType(json['name'], json['id'] as int);
    if (json['medias'] != null) {
      var _medias = json['medias'] as List;
      mediaType.medias = _medias.map((e) => MediaModel.fromJson(e)).toList();
    }
    return mediaType;
  }
}

class Catalogo {
  int media_count = 0;
  int category_count = 0;
  static Catalogo instance = Catalogo();

  List<MediaType> medias = [
    MediaType("Filmes", 0),
    MediaType("Series", 1),
    MediaType("Livros", 2)
  ];

  List<Categoria> categorias = [];
  List<bool> categoriasFiltradas = [];

  MediaModel createMedia(
      {required String name,
      required double rating,
      description = '',
      required String imagem,
      required List<bool> categoriasEscolhidas,
      required MediaType tipoSelected}) {
    List<Categoria> categorias = [];
    Widget? image = Icon(Icons.movie_rounded);
    for (int i = 0; i < categoriasEscolhidas.length; i++) {
      if (categoriasEscolhidas[i]) {
        categorias.add(Catalogo.instance.categorias[i]);
      }
    }
    if (imagem != '') {
      try {
        image = Image.network(imagem);
      } finally {}
    }

    var media = MediaModel(name, rating, description, categorias, image);
    Catalogo.instance.addMedia(media, tipoSelected);
  }

  pegarMediasJson() async {
    medias = await FileManager.instance.readJsonFile();
  }

  deleteMedia(MediaModel media, int mediaTypeId) {
    medias[mediaTypeId].medias.remove(media);
  }

  addCategory(Categoria categoria) {
    categorias.add(categoria);
    categoriasFiltradas.add(true);
    category_count += 1;
  }

  addMedia(MediaModel media, MediaType tipo) {
    if (!mediaTypeExists(tipo)) medias.add(tipo);

    for (Categoria category in media.categorias) {
      if (!categoryExists(category)) {
        addCategory(category);
      }
    }
    media_count += 1;
    medias[tipo.id].medias.add(media);
  }

  bool categoryExists(Categoria new_category) {
    for (Categoria category in categorias) {
      if (category.id == new_category.id) {
        return true;
      }
    }
    return false;
  }

  bool mediaTypeExists(MediaType newType) {
    for (MediaType type in medias) {
      if (newType.id == type.id) {
        return true;
      }
    }
    return false;
  }
}
