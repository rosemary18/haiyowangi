import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:haiyowangi/src/index.dart';
import 'widgets/index.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {

  final repository = InsightRepository();

  InsightModel? insight;
  DateTime date = DateTime.now();
  bool isLoading = true;

  Timer? timeId;
  String? taskID;

  @override
  void initState() {
    super.initState();
    handlerGetData();
  }

  void handlerGetData() async {
    
    isLoading = true;
    setState(() {});

    final state = context.read<AuthBloc>().state;
    Response res = await repository.getData("${state.store!.id}", queryParams: {"date": formatDateFromString(date.toString(), format: "yyyy-MM-dd")});

    if (res.statusCode == 200) {
      insight = InsightModel.fromJson(res.data["data"]);
    }

    isLoading = false;
    setState(() {});
  }

  Future<bool> checkDownloadStatus(String? taskId) async {

    if (taskId == null) return false;

    final tasks = await FlutterDownloader.loadTasks();
    final task = tasks?.firstWhere((t) => t.taskId == taskId);

    if (task != null) {
      if (task.status == DownloadTaskStatus.running) {
        debugPrint('Download with task ID $taskId is running.');
        return true;
      } else if (task.status == DownloadTaskStatus.complete) {
        debugPrint('Download with task ID $taskId is complete.');
        return false;
      } else if (task.status == DownloadTaskStatus.failed) {
        debugPrint('Download with task ID $taskId has failed.');
        return false;
      } else {
        debugPrint('Download with task ID $taskId is in status: ${task.status}');
        return false;
      }
    } else {
      debugPrint('No download found with task ID $taskId.');
      return false;
    }
  }

  void handlerExport() async {

    if (!(await checkDownloadStatus(taskID))) {      
      final state = context.read<AuthBloc>().state;
      taskID = await repository.exportInsight("${state.store!.id}", formatDateFromString(date.toString(), format: "yyyy-MM-dd"));
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("File sedang di di download!"),
          backgroundColor: Colors.red
        )
      );
    }
  }

  void handlerChangeMonth(DateTime x) async {
    
    date = x;
    isLoading = true;
    setState(() {});

    if (timeId?.isActive ?? false) timeId!.cancel();
    timeId = null;
    timeId = Timer(const Duration(milliseconds: 500), handlerGetData);
  }

  Widget buildSourceCard(dynamic data) {
    
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(data["name"], style: const TextStyle(fontSize: 10))
          ),
          Text(parseRupiahCurrency(data["value"].toString()), style: const TextStyle(fontSize: 10)),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (c, s) {

      },
      builder: (c, s) {
        return Scaffold(
          body: Container(
            color: greenLightColor,
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Hai, ${s.user?.name} 😊", style: const TextStyle(fontSize: 18, fontFamily: FontBold)),
                                  Text("Selamat datang di ${s.store?.name}!", style: const TextStyle(fontSize: 18, fontFamily: FontBold)),
                                ],
                              )
                            ),
                            const SizedBox(width: 12)
                          ],
                        ),
                        const SizedBox(height: 12),
                        PickerMonth(
                          value: date,
                          onChange: handlerChangeMonth,
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * .8
                    ),
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)
                      )
                    ),
                    child: isLoading ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${s.store?.name}: Insight ${formatDateFromString(date.toString(), format: "MMMM")} ✨", style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        const SkletonView(height: 100, radius: 4),
                        const SizedBox(height: 12),
                        const SkletonView(height: 100, radius: 4),
                        const SizedBox(height: 12),
                        const SkletonView(height: 100, radius: 4),
                       ]
                      ) : insight == null ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${s.store?.name}: Insight ${formatDateFromString(date.toString(), format: "MMMM")} ✨", style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        const Text("Tidak ada data yang dapat di tampilkan!", style: TextStyle(color: greyTextColor, fontSize: 10)),
                       ]
                      ) :  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("${s.store?.name}: Insight ${formatDateFromString(date.toString(), format: "MMMM")} ✨", style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                            TouchableOpacity(
                              onPress: handlerExport,
                              child: const Icon(
                                Icons.downloading_rounded,
                                color: primaryColor,
                                size: 18,
                              ), 
                            )
                          ]
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text("Penjualan", style: TextStyle(fontSize: 10))
                                  ),
                                  Text(parseRupiahCurrency(insight!.sales["nominal"].toString()), style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text("Pemasukan", style: TextStyle(fontSize: 10))
                                  ),
                                  Text(parseRupiahCurrency(insight!.incomes.total.toString()), style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text("Pengeluaran", style: TextStyle(fontSize: 10))
                                  ),
                                  Text(parseRupiahCurrency(insight!.expenses.total.toString()), style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                              const Divider(height: 18, thickness: 1, color: greySoftColor),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text("Laba Bersih", style: TextStyle(fontSize: 10))
                                  ),
                                  Text(parseRupiahCurrency(insight!.laba.toString()), style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Penjualan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: white1Color,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text("Total", style: TextStyle(fontSize: 10))
                                        ),
                                        Text("x${insight!.sales["total"]} Penjualan", style: const TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                    const Divider(height: 12, thickness: 1, color: greySoftColor),
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text("Nominal", style: TextStyle(fontSize: 10))
                                        ),
                                        Text(parseRupiahCurrency(insight!.sales["nominal"].toString()), style: const TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Pemasukan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: white1Color,
                                ),
                                child: Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Expanded(
                                              child: Text("Sumber", style: TextStyle(fontSize: 10))
                                            ),
                                            Text("${insight!.incomes.sources.length+1} Sumber", style: const TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
                                          margin: const EdgeInsets.only(left: 12, top: 6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: greyLightColor,
                                          ),
                                          child: Column(
                                            children: [
                                              buildSourceCard({"name": "Penjualan", "value": insight!.sales["nominal"].toString()}),
                                              ...insight!.incomes.sources.map(buildSourceCard)
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const Divider(height: 12, thickness: 1, color: greySoftColor),
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text("Total", style: TextStyle(fontSize: 10))
                                        ),
                                        Text(parseRupiahCurrency(insight!.incomes.total.toString()), style: const TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Pengeluaran", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: white1Color,
                                ),
                                child: Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Expanded(
                                              child: Text("Sumber", style: TextStyle(fontSize: 10))
                                            ),
                                            Text("${insight!.expenses.sources.length} Sumber", style: const TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                        if (insight!.expenses.sources.isNotEmpty) Container(
                                          padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
                                          margin: const EdgeInsets.only(left: 12, top: 6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: greyLightColor,
                                          ),
                                          child: Column(
                                            children: [
                                              ...insight!.expenses.sources.map(buildSourceCard),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const Divider(height: 12, thickness: 1, color: greySoftColor),
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text("Total", style: TextStyle(fontSize: 10))
                                        ),
                                        Text(parseRupiahCurrency(insight!.expenses.total.toString()), style: const TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ),
        );
      }, 
    );
  }
}