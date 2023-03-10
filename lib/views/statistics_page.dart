import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:media_organizer/controllers/home_controller.dart';
import 'package:media_organizer/controllers/statistics_controller.dart';
import 'package:media_organizer/models/media_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  @override
  State<StatisticsPage> createState() => _StatisticsPage();
}

class _StatisticsPage extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Goals & Statistics"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 4, child: Text("Goals")),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  openAddGoalDialog();
                                },
                                child: Icon(Icons.add)))
                      ],
                    ),
                    SizedBox(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: Catalogo.instance.goals.length,
                          itemBuilder: ((context, index) {
                            return ListTile(
                              title: Text(Catalogo.instance.goals[index].name),
                              onTap: () => setState(() {
                                StatisticsController.instance
                                    .showGoal(Catalogo.instance.goals[index]);
                              }),
                            );
                          })),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Card(
                child: Column(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: showGraph())),
                    Expanded(child: showGoalInfo())
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showGoalInfo() {
    return SingleChildScrollView(
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 50,
        shadowColor: Colors.black,
        color: Color.fromARGB(255, 35, 35, 35),
        child: Column(
          children: [
            SizedBox(
              child: Text(StatisticsController.instance.showedGoalName,
                  style: TextStyle(
                    fontSize: 20,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2.5
                      ..color = Colors.blue[700]!,
                  )),
            ),
            Text(
              "Quantity of medias to complete: ${StatisticsController.instance.mediasInGoal.length}/${StatisticsController.instance.quantMediasGoal - 1}",
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Medias included in this goal:"),
                    Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0.2),
                          child: showListGoal(),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showListGoal() {
    if (StatisticsController.instance.showedMedias.isEmpty) {
      return SizedBox(
        width: 200,
        height: 200,
        child: SingleChildScrollView(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: StatisticsController.instance.mediasInGoal.length,
            itemBuilder: ((context, index) {
              return ListTile(
                title: Text(
                    StatisticsController.instance.mediasInGoal[index].name),
              );
            }),
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 2,
              );
            },
          ),
        ),
      );
    }
    return SizedBox(
      child: SingleChildScrollView(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: StatisticsController.instance.showedMedias.length,
          separatorBuilder: (context, index) {
            return Divider(
              thickness: 2,
            );
          },
          itemBuilder: ((context, index) {
            if (StatisticsController.instance.mediasInGoal
                .contains(StatisticsController.instance.showedMedias[index])) {
              return Padding(
                padding: const EdgeInsets.all(7.0),
                child: ListTile(
                    trailing: const Icon(Icons.check),
                    title: Text(StatisticsController
                        .instance.showedMedias[index].name)),
              );
            }
            return ListTile(
                trailing: const Icon(Icons.cancel),
                title: Text(
                    StatisticsController.instance.showedMedias[index].name));
          }),
        ),
      ),
    );
  }

  SfCartesianChart showGraph() {
    setState(() {
      StatisticsController.instance.showGraph();
    });
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(),
      series: [
        LineSeries(
          dataSource: StatisticsController.instance.chartData,
          xValueMapper: (ChartData ch, _) => ch.xAxis,
          yValueMapper: (ChartData ch, _) => ch.yAxis,
        )
      ],
    );
  }

  openAddGoalDialog() {
    DateTime selectedDate = DateTime.now();
    MediaType tipoSelected = Catalogo.instance.medias[0];
    StatisticsController.instance.mediasViewed = Catalogo.instance.medias;

    StatisticsController.instance.categoriasEscolhidas =
        Catalogo.instance.categorias.map((e) => false).toList();

    StatisticsController.instance.mediasEscolhidas = StatisticsController
        .instance.mediasViewed[0].medias
        .map((e) => false)
        .toList();

    return showDialog(
      context: context,
      builder: (context) => SizedBox(
        child: AlertDialog(
          insetPadding: EdgeInsets.all(100),
          title: Text("Add Goal"),
          content: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 4,
            child: StatefulBuilder(
              builder: (context, setState) {
                return ListView(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            decoration:
                                const InputDecoration(labelText: 'Goal name'),
                            onChanged: (value) => setState(() {
                              StatisticsController.instance.selectedName =
                                  value;
                            }),
                          ),
                        ),
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
                                StatisticsController.instance
                                    .filterMediasGoal();
                                StatisticsController.instance.mediasEscolhidas =
                                    StatisticsController.instance
                                        .mediasViewed[tipoSelected.id].medias
                                        .map((e) => false)
                                        .toList();
                              })),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: Catalogo.instance.category_count,
                              itemBuilder: ((context, index) {
                                return CheckboxListTile(
                                  value: StatisticsController
                                      .instance.categoriasEscolhidas[index],
                                  title: Text(
                                      Catalogo.instance.categorias[index].name),
                                  onChanged: (value) => setState(() {
                                    StatisticsController.instance
                                        .categoriasEscolhidas[index] = value!;
                                    StatisticsController.instance
                                        .filterMediasGoal();
                                    StatisticsController
                                            .instance.mediasEscolhidas =
                                        StatisticsController
                                            .instance.mediasViewed[0].medias
                                            .map((e) => false)
                                            .toList();
                                  }),
                                );
                              }),
                            ),
                          ),
                        ),
                        Card(
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: CheckboxListTile(
                                title: const Text(
                                    "Select medias related to your goal"),
                                value:
                                    StatisticsController.instance.selectMedias,
                                onChanged: (value) => setState(() {
                                  StatisticsController.instance.selectMedias =
                                      value!;
                                }),
                              ),
                            ),
                            Visibility(
                              visible:
                                  !StatisticsController.instance.selectMedias,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: SpinBox(
                                  value: StatisticsController
                                      .instance.quantMediasGoal
                                      .toDouble(),
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Goal number'),
                                  onChanged: (value) => setState(() {
                                    StatisticsController.instance
                                        .updateQuantMediasGoal(value.toInt());
                                  }),
                                ),
                              ),
                            ),
                            Visibility(
                              visible:
                                  StatisticsController.instance.selectMedias,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: StatisticsController
                                        .instance
                                        .mediasViewed[tipoSelected.id]
                                        .medias
                                        .length,
                                    itemBuilder: ((context, index) {
                                      return CheckboxListTile(
                                        value: StatisticsController
                                            .instance.mediasEscolhidas[index],
                                        title: Text(StatisticsController
                                            .instance
                                            .mediasViewed[tipoSelected.id]
                                            .medias[index]
                                            .name),
                                        onChanged: (value) => setState(() {
                                          StatisticsController.instance
                                              .mediasEscolhidas[index] = value!;
                                          StatisticsController.instance
                                              .updateQuantMediasGoal(
                                                  StatisticsController.instance
                                                      .quantMediasGoal);
                                        }),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        Card(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: CheckboxListTile(
                                  title: const Text(
                                      "Include deadline for your goal"),
                                  value:
                                      StatisticsController.instance.hasDeadline,
                                  onChanged: (value) => setState(() {
                                    StatisticsController.instance.hasDeadline =
                                        value!;
                                  }),
                                ),
                              ),
                              Visibility(
                                visible:
                                    StatisticsController.instance.hasDeadline,
                                child: SfDateRangePicker(
                                  onSelectionChanged: (args) => setState(() {
                                    StatisticsController.instance.selectedDate =
                                        args.value;
                                  }),
                                  selectionMode:
                                      DateRangePickerSelectionMode.single,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: (() => setState(() {
                      StatisticsController.instance.createGoal(tipoSelected.id);
                    })),
                child: Text("Ok")),
          ],
        ),
      ),
    );
  }
}
