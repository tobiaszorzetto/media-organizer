import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/media_model.dart';

class FileManager {
  static FileManager instance = FileManager();

  FileManager._internal() {
    instance = this;
  }

  factory FileManager() => FileManager._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _jsonFile async {
    final path = await _localPath;
    return File('$path/info.json');
  }

  Future<File> get _jsonCategoryFile async {
    final path = await _localPath;
    return File('$path/infoCategory.json');
  }

  Future<File> get _jsonGoalsFile async {
    final path = await _localPath;
    return File('$path/infoGoals.json');
  }

  readTextFile() async {
    String fileContent = 'Arquivos';
    File file = await _jsonFile;

    if (await file.exists()) {
      try {
        fileContent = await file.readAsString();
      } catch (e) {
        print(e);
      }
    }

    return fileContent;
  }

  Future<List<MediaType>> readJsonFile() async {
    String fileContent = 'Arquivos';
    File file = await _jsonFile;
    List<MediaType> mediasIniciais = [];
    if (await file.exists()) {
      try {
        fileContent = await file.readAsString();
        var mediaTypeMap = jsonDecode(fileContent);
        for (dynamic jsonMediaType in mediaTypeMap) {
          MediaType mediaType = MediaType.fromJson(jsonMediaType);
          mediasIniciais.add(mediaType);
          for (MediaModel media in mediaType.medias) {
            if (media.dateTime.millisecondsSinceEpoch <
                Catalogo.instance.oldestDateTime.millisecondsSinceEpoch) {
              Catalogo.instance.oldestDateTime = media.dateTime;
            }
            if (media.dateTime.millisecondsSinceEpoch >
                Catalogo.instance.newestDateTime.millisecondsSinceEpoch) {
              Catalogo.instance.newestDateTime = media.dateTime;
            }
          }
        }
      } catch (e) {
        print(e);
      }
    }

    return mediasIniciais;
  }

  Future writeJsonFile() async {
    File file = await _jsonFile;
    var jsonMedias =
        jsonEncode(Catalogo.instance.medias.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonMedias);
  }

  Future<List<Categoria>> readJsonCategoryFile() async {
    String fileContent = 'Arquivos Categorias';
    File file = await _jsonCategoryFile;
    List<Categoria> categoriasIniciais = [];
    if (await file.exists()) {
      try {
        fileContent = await file.readAsString();
        var categoryMap = jsonDecode(fileContent);
        for (dynamic jsonCategory in categoryMap) {
          categoriasIniciais.add(Categoria.fromJson(jsonCategory));
        }
      } catch (e) {
        print(e);
      }
    }

    return categoriasIniciais;
  }

  Future writeJsonCategoryFile() async {
    File file = await _jsonCategoryFile;
    var jsonCategories = jsonEncode(
        Catalogo.instance.categorias.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonCategories);
  }

  Future<List<Goal>> readJsonGoalsFile() async {
    String fileContent = 'Arquivos Goals';
    File file = await _jsonGoalsFile;
    List<Goal> initialGoals = [];
    if (await file.exists()) {
      try {
        fileContent = await file.readAsString();
        var goalsMap = jsonDecode(fileContent);
        for (dynamic jsonGoal in goalsMap) {
          Goal goal = Goal.fromJson(jsonGoal);
          print(goal);
          initialGoals.add(goal);
        }
      } catch (e) {
        print(e);
      }
    }

    return initialGoals;
  }

  Future writeJsonGoalsFile() async {
    File file = await _jsonGoalsFile;
    var jsonGoals =
        jsonEncode(Catalogo.instance.goals.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonGoals);
  }
}
