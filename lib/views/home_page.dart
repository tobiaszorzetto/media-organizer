// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:media_organizer/controllers/app_controller.dart';
import 'package:media_organizer/controllers/file_manager.dart';
import 'package:media_organizer/models/media_model.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/home_controller.dart';

import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
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
                  FileManager.instance.writeJsonCategoryFile();
                  FileManager.instance.writeJsonFile();
                  FileManager.instance.writeJsonGoalsFile();
                }),
              ),
              ListTile(
                title: Text("Statistics"),
                leading: Icon(Icons.graphic_eq),
                onTap: () => setState(() {
                  Navigator.of(context).popAndPushNamed("/statistics");
                }),
              ),
              ListTile(
                title: Text("Dark Mode"),
                leading: Icon(Icons.dark_mode),
                trailing: Switch(
                  value: AppController.instance.darkMode,
                  onChanged: (value) => setState(() {
                    AppController.instance.changeTheme();
                  }),
                ),
                onTap: () => setState(() {
                  AppController.instance.changeTheme();
                }),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text("Media Organizer"),
          actions: [],
        ),
        body: WillPopScope(
          onWillPop: _willPopCallback,
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: ListView(
              children: [
                searchingRow(),
                contentRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _willPopCallback() async {
    openExitDialog();
    return HomeController.instance.exit;
  }

  openExitDialog() {
    String name = '';
    String description = '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Adicionar Categoria"),
        content: Text("Deseja salvar suas altera????es?"),
        actions: [
          TextButton(
              onPressed: (() => setState(() {
                    HomeController.instance.exit = true;
                    FileManager.instance.writeJsonCategoryFile();
                    FileManager.instance.writeJsonFile();
                    Navigator.of(context).pop();
                  })),
              child: Text("Salvar")),
          TextButton(
              onPressed: (() => setState(() {
                    HomeController.instance.exit = true;
                    Navigator.of(context).pop();
                  })),
              child: Text("Discartar mudancas e sair")),
          TextButton(
              onPressed: (() => setState(() {
                    HomeController.instance.exit = false;
                    Navigator.of(context).pop();
                  })),
              child: Text("Cancelar")),
        ],
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () {
                        openAddCategoryDialog();
                      },
                      child: Text('Categorias')),
                  Card(
                    //color: Color.fromARGB(255, 232, 243, 251),
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
                            Catalogo.instance.categoriasFiltradas[index] =
                                value!;
                            HomeController.instance.filterMedia();
                          }),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(onPressed: () {}, child: Text('M??dias')),
                Card(
                  //color: Color.fromARGB(255, 232, 243, 251),
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
        ContextMenuButtonConfig("Excluir m??dia",
            onPressed: () => setState(() {
                  Catalogo.instance.deleteMedia(media, mediaType.id);
                })),
        ContextMenuButtonConfig("Editar m??dia",
            onPressed: () => setState(() {
                  openEditMediaDialog(media);
                })),
      ]),
      child: ListTile(
        title: Text(media.name),
        subtitle: Text("${media.description} inserido: ${media.dateTime} "),
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
                      HomeController.instance.ratingApi.value = 0;
                      HomeController.instance.descriptionController.text = '';
                      HomeController.instance.imageLinkController.text = '';
                      openAddMediaDialog();
                    })),
                child: Icon(Icons.add),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                flex: 5,
                child: TextField(
                  controller: HomeController.instance.searchController,
                  decoration: InputDecoration(
                    label: Text('Pesquise titulos'),
                  ),
                  onChanged: (value) => setState(() {
                    HomeController.instance.filterMedia();
                  }),
                ),
              ),
              Expanded(
                child: ExpansionTile(
                  trailing: Icon(Icons.filter_alt),
                  onExpansionChanged: ((value) => setState(() {
                        //HomeController.instance.changeFilterMenuVisbility();
                      })),
                  title: Text('filtrar'),
                  children: [filterMenu()],
                ),
              ),
              Expanded(child: sortBy()),
            ],
          ),
        ],
      ),
    );
  }

  ExpansionTile sortBy() {
    return ExpansionTile(
      title: Text("Sort by"),
      trailing: Icon(Icons.sort),
      children: [
        RadioListTile(
          secondary: Wrap(children: [
            Icon(Icons.sort_by_alpha_outlined),
            Icon(Icons.arrow_downward)
          ]),
          value: 0,
          title: Wrap(children: [
            Text("Alphabetical"),
          ]),
          groupValue: HomeController.instance.sortType,
          onChanged: (value) => setState(() {
            HomeController.instance.sortType = value!;
          }),
        ),
        RadioListTile(
          secondary: Wrap(children: [
            Icon(Icons.sort_by_alpha_outlined),
            Icon(Icons.arrow_upward)
          ]),
          value: 1,
          title: Text("Alphabetical"),
          groupValue: HomeController.instance.sortType,
          onChanged: (value) => setState(() {
            HomeController.instance.sortType = value!;
          }),
        ),
        RadioListTile(
          secondary: Wrap(
              children: [Icon(Icons.date_range), Icon(Icons.arrow_downward)]),
          value: 2,
          title: Wrap(children: [
            Text("Date & Time"),
          ]),
          groupValue: HomeController.instance.sortType,
          onChanged: (value) => setState(() {
            HomeController.instance.sortType = value!;
          }),
        ),
        RadioListTile(
          secondary: Wrap(
              children: [Icon(Icons.date_range), Icon(Icons.arrow_upward)]),
          value: 3,
          title: Text("Date & Time"),
          groupValue: HomeController.instance.sortType,
          onChanged: (value) => setState(() {
            HomeController.instance.sortType = value!;
          }),
        )
      ],
    );
  }

  Widget filterMenu() {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.star),
                title: Text("Rating"),
              ),
              RangeSlider(
                  min: 0,
                  max: 10,
                  divisions: 20,
                  labels: RangeLabels(
                      "${HomeController.instance.filterRatingsObservados.start}",
                      "${HomeController.instance.filterRatingsObservados.end}"),
                  values: HomeController.instance.filterRatingsObservados,
                  onChanged: ((value) => setState(() {
                        HomeController.instance.filterRatingsObservados = value;
                        HomeController.instance.filterMedia();
                      }))),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text("Date and Time"),
              ),
              RangeSlider(
                min: Catalogo.instance.oldestDateTime.millisecondsSinceEpoch
                    .toDouble(),
                max: DateTime.now().millisecondsSinceEpoch.toDouble(),
                divisions: 100,
                values: HomeController.instance.filterDateObservados,
                labels: RangeLabels(
                    DateTime.fromMillisecondsSinceEpoch(HomeController
                            .instance.filterDateObservados.start
                            .toInt())
                        .toString(),
                    DateTime.fromMillisecondsSinceEpoch(HomeController
                            .instance.filterDateObservados.end
                            .toInt())
                        .toString()),
                onChanged: ((value) => setState(() {
                      HomeController.instance.filterDateObservados = value;
                      HomeController.instance.filterMedia();
                    })),
              ),
            ],
          ),
        ),
        Card(
          child: CheckboxListTile(
            value: HomeController.instance.filterShowOnlyConsumed,
            title: Text("Filter only consumed medias"),
            onChanged: (value) => setState(() {
              HomeController.instance.filterShowOnlyConsumed = value!;
            }),
          ),
        ),
      ],
    );
  }

  openAddMediaDialog() {
    String name = '';
    String description = HomeController.instance.overview;
    String imagem = '';
    MediaType tipoSelected = Catalogo.instance.medias[0];
    double rating = HomeController.instance.ratingApi.value;
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
                return Row(
                  children: [
                    Expanded(
                      child: ListView(
                        //crossAxisAlignment: CrossAxisAlignment.start,
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
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: TextField(
                                  onChanged: (value) => setState(() {
                                    name = value;
                                  }),
                                  decoration: InputDecoration(
                                    label: Text("nome da midia"),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                    onPressed: (() => setState(() {
                                          HomeController.instance.autoComplete(
                                              name, tipoSelected.id);
                                        })),
                                    child: Text("Auto-complete")),
                              ),
                            ],
                          ),
                          TextField(
                            controller:
                                HomeController.instance.descriptionController,
                            onChanged: (value) {
                              setState(
                                () {
                                  HomeController.instance.overview = value;
                                },
                              );
                            },
                            decoration: InputDecoration(
                              label: Text("descri????o da midia"),
                            ),
                          ),
                          CheckboxListTile(
                            title: Text("J?? consumido"),
                            value: HomeController.instance.consumed,
                            onChanged: (value) => setState(() {
                              HomeController.instance.consumed = value!;
                            }),
                          ),
                          Text('Avalia????o'),
                          SizedBox(
                            child: ValueListenableBuilder<double>(
                                valueListenable:
                                    HomeController.instance.ratingApi,
                                builder: (context, ratingValue, _) {
                                  return Slider(
                                    value:
                                        HomeController.instance.ratingApi.value,
                                    max: 10,
                                    divisions: 20,
                                    label: HomeController
                                        .instance.ratingApi.value
                                        .toString(),
                                    onChanged: ((value) => setState(() {
                                          HomeController
                                              .instance.ratingApi.value = value;
                                        })),
                                  );
                                }),
                          ),
                          TextField(
                            controller:
                                HomeController.instance.imageLinkController,
                            onChanged: (value) {
                              HomeController.instance.imagem = value;
                            },
                            decoration: InputDecoration(
                              label: Text("link de imagem (opcional)"),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Text("categorias"),
                          Card(
                            child: SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: Catalogo.instance.category_count,
                                itemBuilder: ((context, index) {
                                  return CheckboxListTile(
                                    value: categoriasEscolhidas[index],
                                    title: Text(Catalogo
                                        .instance.categorias[index].name),
                                    onChanged: (value) => setState(() {
                                      categoriasEscolhidas[index] = value!;
                                    }),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
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
                      HomeController.instance.createMedia(
                          name: name,
                          categoriasEscolhidas: categoriasEscolhidas,
                          tipoSelected: tipoSelected);
                      Navigator.of(context).pop();
                    })),
                child: Text("Pronto")),
          ],
        ),
      ),
    );
  }

  openEditMediaDialog(MediaModel media) {
    String name = media.name;
    String description = media.description;
    double rating = media.rating;

    bool consumed;
    if (media.dateTimeConsumed.millisecondsSinceEpoch == 0) {
      consumed = false;
    } else {
      consumed = true;
    }
    bool wasConsumed = consumed;

    List<bool> categoriasEscolhidas =
        Catalogo.instance.categorias.map((e) => false).toList();
    for (Categoria cat in media.categorias) {
      categoriasEscolhidas[cat.id] = true;
    }

    return showDialog(
      context: context,
      builder: (context) => SizedBox(
        child: AlertDialog(
          insetPadding: EdgeInsets.all(100),
          title: Text("Editar midia"),
          content: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 2,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  children: [
                    Expanded(child: media.image),
                    Expanded(
                      child: ListView(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: name,
                            onChanged: (value) => setState(() {
                              name = value;
                            }),
                            decoration: InputDecoration(
                              label: Text("nome da midia"),
                            ),
                          ),
                          TextFormField(
                            initialValue: description,
                            onChanged: (value) {
                              setState(
                                () {
                                  description = value;
                                },
                              );
                            },
                            decoration: InputDecoration(
                              label: Text("descri????o da midia"),
                            ),
                          ),
                          CheckboxListTile(
                            title: Text("J?? consumido"),
                            value: consumed,
                            onChanged: (value) => setState(() {
                              consumed = value!;
                            }),
                          ),
                          Text('Avalia????o'),
                          SizedBox(
                            child: Slider(
                              value: rating,
                              max: 10,
                              divisions: 20,
                              label: rating.toString(),
                              onChanged: ((value) => setState(() {
                                    rating = value;
                                  })),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Text("categorias"),
                          Card(
                            child: SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: Catalogo.instance.category_count,
                                itemBuilder: ((context, index) {
                                  return CheckboxListTile(
                                    value: categoriasEscolhidas[index],
                                    title: Text(Catalogo
                                        .instance.categorias[index].name),
                                    onChanged: (value) => setState(() {
                                      categoriasEscolhidas[index] = value!;
                                    }),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
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
                      HomeController.instance.editMedia(
                          media,
                          name,
                          description,
                          rating,
                          categoriasEscolhidas,
                          consumed,
                          wasConsumed);

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
                      label: Text("descri????o da midia"),
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
