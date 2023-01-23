import 'package:flutter_test/flutter_test.dart';
import 'package:media_organizer/models/media_model.dart';

void main() {
  

  test("catalogo consegue pegar categorias", (() {
    Categoria categoria_teste = Categoria("terror", "da medo", 1);
    
    Catalogo.instance.addCategory(categoria_teste);
    print(Catalogo.instance.categorias[0].description);

  }));
}