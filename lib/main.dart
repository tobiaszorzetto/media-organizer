import 'package:flutter/material.dart';
import 'package:media_organizer/models/media_model.dart';
import 'package:media_organizer/views/home_page.dart';

void main() {
  syncCatalogo();
}

syncCatalogo() async {
  await Catalogo.instance.pegarMediasJson();
  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.fallback(),
      routes: {
        '/': ((context) => HomePage()),
      },
    );
  }
}
