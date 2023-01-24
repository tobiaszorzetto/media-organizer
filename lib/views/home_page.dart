// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_organizer/controllers/file_manager.dart';
import 'package:media_organizer/models/media_model.dart';

import '../controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    setState(() {
      HomeController.instance
          .updateVisibleMedias(List.of(Catalogo.instance.medias));
      HomeController.instance.filterMedia();
    });
    return ContextMenuOverlay(
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              ListTile(
                title: Text("Salvar"),
                leading: Icon(Icons.save),
                onTap: () => setState(() {
                  FileManager.instance.writeJsonFile();
                }),
              )
            ],
          ),
        ),
        appBar: AppBar(
          actions: [],
        ),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              searchingRow(),
              contentRow(),
            ],
          ),
        ),
      ),
    );
  }

  Container contentRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                    onPressed: () {
                      openAddCategoryDialog();
                    },
                    child: Text('Categorias')),
                Card(
                  color: Color.fromARGB(255, 232, 243, 251),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Catalogo.instance.category_count,
                    itemBuilder: ((context, index) {
                      return CheckboxListTile(
                        value: Catalogo.instance.categoriasFiltradas[index],
                        title: Text(Catalogo.instance.categorias[index].name),
                        subtitle: Text(
                            Catalogo.instance.categorias[index].description),
                        onChanged: (value) => setState(() {
                          Catalogo.instance.categoriasFiltradas[index] = value!;
                          HomeController.instance.filterMedia();
                        }),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(onPressed: () {}, child: Text('Mídias')),
                Card(
                  color: Color.fromARGB(255, 232, 243, 251),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: HomeController.instance.visibleMedias.length,
                    itemBuilder: ((context, index) {
                      return buildMediaTypeTile(
                          HomeController.instance.visibleMedias[index]);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMediaTypeTile(MediaType mediaType) {
    return ExpansionTile(
      title: Text(mediaType.name),
      children:
          mediaType.medias.map((e) => buildMediaTile(e, mediaType)).toList(),
    );
  }

  Widget buildMediaTile(MediaModel media, MediaType mediaType) {
    return ContextMenuRegion(
      contextMenu: GenericContextMenu(buttonConfigs: [
        ContextMenuButtonConfig("Excluir mídia",
            onPressed: () => setState(() {
                  Catalogo.instance.deleteMedia(media, mediaType.id);
                })),
      ]),
      child: ListTile(
        title: Text(media.name),
        subtitle: Text(media.description),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(media.rating.toString(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            Icon(Icons.star)
          ],
        ),
        leading: media.image,
      ),
    );
  }

  Container searchingRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              FloatingActionButton(
                onPressed: (() => setState(() {
                      HomeController.instance.ratingObserved = 0;
                      openAddMediaDialog();
                    })),
                child: Icon(Icons.add),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                flex: 6,
                child: TextField(
                  decoration: InputDecoration(
                    label: Text('Pesquise titulos'),
                  ),
                  onChanged: (value) => setState(() {
                    HomeController.instance.filterMedia(pesquisa: value);
                  }),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: (() => setState(() {
                        HomeController.instance.changeFilterMenuVisbility();
                      })),
                  child: Text('filtrar'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: (() {
                    setState(() {
                      HomeController.instance.pegarMediasJson();
                    });
                  }),
                  child: Text('Sort by'),
                ),
              ),
            ],
          ),
          filterMenu(),
        ],
      ),
    );
  }

  Widget filterMenu() {
    return Visibility(
      visible: HomeController.instance.filterMenuvisible,
      child: Card(
          child: Column(
        children: [
          RangeSlider(
              min: 0,
              max: 10,
              labels: RangeLabels(
                  HomeController.instance.filterRatingsObservados.start
                      .round()
                      .toString(),
                  HomeController.instance.filterRatingsObservados.end
                      .round()
                      .toString()),
              values: HomeController.instance.filterRatingsObservados,
              onChanged: ((value) => setState(() {
                    HomeController.instance.filterRatingsObservados = value;
                    HomeController.instance.filterMedia();
                  }))),
          Text(HomeController.instance.filterRatingsObservados.start
              .round()
              .toString()),
          Text(HomeController.instance.filterRatingsObservados.end
              .round()
              .toString()),
        ],
      )),
    );
  }

  openAddMediaDialog() {
    String name = '';
    String description = '';
    String imagem = '';
    MediaType tipoSelected = Catalogo.instance.medias[0];

    List<bool> categoriasEscolhidas =
        Catalogo.instance.categorias.map((e) => false).toList();

    return showDialog(
      context: context,
      builder: (context) => SizedBox(
        child: AlertDialog(
          insetPadding: EdgeInsets.all(100),
          title: Text("Adicionar midia"),
          content: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 4,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<MediaType>(
                      value: tipoSelected,
                      items: Catalogo.instance.medias
                          .map((e) => DropdownMenuItem<MediaType>(
                                value: e,
                                child: Text(e.name),
                              ))
                          .toList(),
                      onChanged: ((value) => setState(() {
                            tipoSelected = value!;
                          })),
                    ),
                    TextField(
                      onChanged: (value) => setState(() {
                        name = value;
                      }),
                      decoration: InputDecoration(
                        label: Text("nome da midia"),
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        description = value;
                      },
                      decoration: InputDecoration(
                        label: Text("descrição da midia"),
                      ),
                    ),
                    Text('Avaliação'),
                    SizedBox(
                      child: Slider(
                        value: HomeController.instance.ratingObserved,
                        max: 10,
                        divisions: 20,
                        label:
                            HomeController.instance.ratingObserved.toString(),
                        onChanged: ((value) => setState(() {
                              HomeController.instance.ratingObserved = value;
                            })),
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        imagem = value;
                      },
                      decoration: InputDecoration(
                        label: Text("link de imagem (opcional)"),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: Catalogo.instance.category_count,
                          itemBuilder: ((context, index) {
                            return CheckboxListTile(
                              value: categoriasEscolhidas[index],
                              title: Text(
                                  Catalogo.instance.categorias[index].name),
                              onChanged: (value) => setState(() {
                                categoriasEscolhidas[index] = value!;
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: (() => setState(() {
                      Catalogo.instance.createMedia(
                          name: name,
                          rating: HomeController.instance.ratingObserved,
                          description: description,
                          categoriasEscolhidas: categoriasEscolhidas,
                          imagem: imagem,
                          tipoSelected: tipoSelected);

                      HomeController.instance.filterMedia();
                      Navigator.of(context).pop();
                    })),
                child: Text("Pronto")),
          ],
        ),
      ),
    );
  }

  openAddCategoryDialog() {
    String name = '';
    String description = '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Adicionar Categoria"),
        content: SizedBox(
          height: MediaQuery.of(context).size.height / 8,
          width: MediaQuery.of(context).size.width / 4,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() {
                      name = value;
                    }),
                    decoration: InputDecoration(
                      label: Text("nome da midia"),
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      description = value;
                    },
                    decoration: InputDecoration(
                      label: Text("descrição da midia"),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: (() => setState(() {
                    HomeController.instance.createCategory(name, description);
                    Navigator.of(context).pop();
                  })),
              child: Text("Pronto")),
        ],
      ),
    );
  }
}
