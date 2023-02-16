import 'package:flutter/material.dart';
import 'package:media_organizer/controllers/app_controller.dart';
import 'package:media_organizer/models/media_model.dart';
import 'package:media_organizer/views/home_page.dart';
import 'package:media_organizer/views/statistics_page.dart';

void main() {
  syncCatalogo();
}

syncCatalogo() async {
  await Catalogo.instance.pegarMediasJson();
  await Catalogo.instance.pegarCategoriasJson();
  await Catalogo.instance.pegarGoalsJson();
  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: AppController.instance,
        builder: (context, child) {
          return MaterialApp(
            theme: AppController.instance.theme,
            routes: {
              '/': ((context) => HomePage()),
              '/statistics': ((context) => StatisticsPage()),
            },
          );
        });
  }
}
