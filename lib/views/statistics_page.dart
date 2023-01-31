import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:media_organizer/controllers/home_controller.dart';
import 'package:media_organizer/controllers/statistics_controller.dart';
import 'package:media_organizer/models/media_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class StatisticsPage extends StatefulWidget {
  @override
  State<StatisticsPage> createState() => _StatisticsPage();
}

class _StatisticsPage extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Card(
                child: SfCartesianChart(
                  title: ChartTitle(text: "Goal"),
                ),
              ),
            ),
          ],
        ),
      ),
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration:
                            const InputDecoration(labelText: 'Goal name'),
                        onChanged: (value) => setState(() {
                          StatisticsController.instance.selectedName = value;
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
                            StatisticsController.instance.filterMediasGoal();
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
                                StatisticsController.instance.mediasEscolhidas =
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: StatisticsController.instance
                              .mediasViewed[tipoSelected.id].medias.length,
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
                                StatisticsController
                                    .instance.mediasEscolhidas[index] = value!;
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SpinBox(
                        value: 10,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: 'Goal number'),
                      ),
                    ),
                    SfDateRangePicker(
                      onSelectionChanged: (args) => setState(() {
                        StatisticsController.instance.selectedDate = args.value;
                      }),
                      selectionMode: DateRangePickerSelectionMode.single,
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: (() => setState(() {})), child: Text("Ok")),
          ],
        ),
      ),
    );
  }
}