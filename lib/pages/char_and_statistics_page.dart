import 'package:flutter/material.dart';

class ChartAndStatisticsPage extends StatefulWidget {
  const ChartAndStatisticsPage({super.key});

  @override
  State<ChartAndStatisticsPage> createState() => _ChartAndStatisticsPageState();
}

class _ChartAndStatisticsPageState extends State<ChartAndStatisticsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '圖表與統計',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Statistics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
