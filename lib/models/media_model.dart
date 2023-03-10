import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_organizer/controllers/file_manager.dart';
import 'package:media_organizer/controllers/home_controller.dart';

class MediaModel {
  String name;
  double rating;
  String description;
  List<Categoria> categorias;
  final Widget image;
  String imageString;
  final DateTime dateTime;
  DateTime dateTimeConsumed;
  int typeId;

  MediaModel(
      this.name,
      this.rating,
      this.description,
      this.categorias,
      this.image,
      this.imageString,
      this.dateTime,
      this.dateTimeConsumed,
      this.typeId);

  Map toJson() => {
        'name': name,
        'rating': rating,
        'description': description,
        'categorias': categorias.map((e) => e.toJson()).toList(),
        'datetime': dateTime.millisecondsSinceEpoch,
        'datetimeconsumed': dateTimeConsumed.millisecondsSinceEpoch,
        'image': imageString,
        'typeId': typeId,
      };

  static Icon getIcon(int id) {
    if (id == 0) {
      return Icon(Icons.movie);
    } else if (id == 1) {
      return Icon(Icons.tv);
    }
    return Icon(Icons.book);
  }

  factory MediaModel.fromJson(dynamic json) {
    var icone = MediaModel.getIcon(json['typeId']);
    var categoriasObjsJson = json['categorias'] as List;
    List<Categoria> _categorias =
        categoriasObjsJson.map((e) => Categoria.fromJson(e)).toList();
    return MediaModel(
      json['name'],
      json['rating'] as double,
      json['description'],
      _categorias,
      json['image'].toString().isEmpty ? icone : Image.network(json['image']),
      json['image'],
      DateTime.fromMillisecondsSinceEpoch(json['datetime']),
      DateTime.fromMillisecondsSinceEpoch(json['datetimeconsumed']),
      json['typeId'],
    );
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
  DateTime oldestDateTime = DateTime.now();
  DateTime newestDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  static Catalogo instance = Catalogo();
  List<Goal> goals = [];

  List<MediaType> medias = [
    MediaType("Filmes", 0),
    MediaType("Series", 1),
    MediaType("Livros", 2)
  ];

  List<Categoria> categorias = [];
  List<bool> categoriasFiltradas = [];

  createMedia(
      {required String name,
      required double rating,
      description = '',
      required String imagem,
      required List<bool> categoriasEscolhidas,
      required MediaType tipoSelected,
      required dateTimeConsumed}) {
    List<Categoria> categorias = [];
    Widget? image = MediaModel.getIcon(tipoSelected.id);
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

    if (HomeController.instance.filterDateObservados.start >
        newestDateTime.millisecondsSinceEpoch) {
      newestDateTime = DateTime.now();
      HomeController.instance.filterDateObservados = RangeValues(
          HomeController.instance.filterDateObservados.start,
          DateTime.now().millisecondsSinceEpoch.toDouble());
    } else {
      newestDateTime = DateTime.now();
    }

    var media = MediaModel(name, rating, description, categorias, image, imagem,
        newestDateTime, dateTimeConsumed, tipoSelected.id);
    Catalogo.instance.addMedia(media, tipoSelected);
  }

  pegarMediasJson() async {
    var medias_collected = await FileManager.instance.readJsonFile();
    if (medias_collected.isNotEmpty){
      medias = medias_collected;
    }
  }

  pegarGoalsJson() async {
    goals = await FileManager.instance.readJsonGoalsFile();
  }

  pegarCategoriasJson() async {
    categorias = await FileManager.instance.readJsonCategoryFile();
    category_count = categorias.length;
    categoriasFiltradas = categorias.map((e) => true).toList();
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

class Goal {
  final String name;
  final List<Categoria> categorias;
  final int quantMedias;
  final List<MediaModel> selectedMedias;
  final DateTime deadline;
  final int typeId;
  final DateTime creationDate;

  Goal(this.name, this.categorias, this.quantMedias, this.selectedMedias,
      this.deadline, this.creationDate, this.typeId);

  Map toJson() => {
        'name': name,
        'categorias': categorias.map((e) => e.toJson()).toList(),
        'quantMedias': quantMedias,
        'selectedMedias': selectedMedias.map((e) => e.toJson()).toList(),
        'deadline': deadline.millisecondsSinceEpoch,
        'creationDate': creationDate.millisecondsSinceEpoch,
        'typeId': typeId,
      };

  factory Goal.fromJson(dynamic json) {
    var categoriasObjsJson = json['categorias'] as List;
    List<Categoria> categorias =
        categoriasObjsJson.map((e) => Categoria.fromJson(e)).toList();
    var selectedMediasObjsJson = json['selectedMedias'] as List;
    List<MediaModel> selectedMedias =
        selectedMediasObjsJson.map((e) => MediaModel.fromJson(e)).toList();
    DateTime criacao =
        DateTime.fromMillisecondsSinceEpoch(json['creationDate']);
    var goal = Goal(
      json['name'],
      categorias,
      json['quantMedias'],
      selectedMedias,
      DateTime.fromMillisecondsSinceEpoch(json['deadline']),
      criacao,
      json["typeId"],
    );
    print(goal);
    return goal;
  }
}
