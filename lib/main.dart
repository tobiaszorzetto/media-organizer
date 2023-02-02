import 'package:flutter/material.dart';
import 'package:media_organizer/models/media_model.dart';
import 'package:media_organizer/views/home_page.dart';
import 'package:media_organizer/views/statistics_page.dart';

void main() {
  syncCatalogo();
}

syncCatalogo() async {
  await Catalogo.instance.pegarMediasJson();
  await Catalogo.instance.pegarCategoriasJson();
  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      routes: {
        '/': ((context) => HomePage()),
        '/statistics': ((context) => StatisticsPage()),
      },
    );
  }
}
