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
}
