import 'package:covid19/Constants/api.dart';
import 'package:covid19/Widgets/app_bar.dart';
import 'package:covid19/Widgets/myCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'Constants/colors.dart';

import 'package:pie_chart/pie_chart.dart';

var totalCase, population, deaths, todayCases, todayDeath;

List _countries = [];

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String current = "No Country Cases";
  String flag = "";
  num worldDeaths = 0;
  num deathOfThatCountry = 0;
  num worldActive = 0;
  num totalCasesCountry = 0;
  num activeCountry = 0;
  num totalCasesWorld = 0;
  void fetchData() async {
    http.Response response = await http.get(Uri.parse(api));
    final countries = json.decode(response.body);
    setState(() {
      _countries = countries;
    });
    for (int i = 0; i < _countries.length; i++) {
      worldDeaths += _countries[i]['deaths'] / 1000;
      worldActive += (_countries[i]['active'] / 1000);
      totalCasesWorld += (_countries[i]['cases'] / 1000);
    }
    print(totalCasesCountry);
  }

  void getData(current) async {
    http.Response response = await http.get(Uri.parse(api + "/" + current));
    final data = json.decode(response.body);
    setState(() {
      totalCase = data['cases'];
      totalCasesCountry = data['cases'];
      population = data['population'];
      deaths = data['deaths'];
      deathOfThatCountry = data['deaths'];
      todayCases = data['todayCases'];
      todayDeath = data['todayDeaths'];
      flag = data['countryInfo']['flag'];
      activeCountry = data['active'];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: appBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            flag.length > 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(flag),
                          radius: 40,
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          current,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  )
                : SizedBox(
                    width: 1,
                  ),
            _countries.isNotEmpty
                ? DropdownButton(
                    hint: Text("Choose country"),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _countries.map((value) {
                      return DropdownMenuItem(
                          value: value['country'],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      value['countryInfo']['flag']),
                                  radius: 20,
                                  backgroundColor: Colors.transparent,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(value['country'])
                              ],
                            ),
                          ));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        current = value.toString();
                        getData(current);
                      });
                    },
                  )
                : CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyCard(
                      data: totalCase == null ? "-" : totalCase.toString(),
                      textColor: Colors.white,
                      belowText: "Total Cases",
                      bgColor: yellow,
                    ),
                  ),
                  Expanded(
                    child: MyCard(
                      data: deaths == null ? "-" : deaths.toString(),
                      textColor: Colors.white,
                      belowText: "Total Death",
                      bgColor: green,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyCard(
                      data: todayCases == null ? "-" : todayCases.toString(),
                      textColor: Colors.white,
                      belowText: "Today Cases",
                      bgColor: black,
                    ),
                  ),
                  Expanded(
                    child: MyCard(
                      data: todayDeath == null ? "-" : todayDeath.toString(),
                      textColor: Colors.white,
                      belowText: "Today Death",
                      bgColor: red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: MyCard(
                data: population.toString(),
                textColor: Colors.white,
                belowText: "Population",
                bgColor: blue,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Image.network(
                  'https://www.pngplay.com/wp-content/uploads/2/World-Map-PNG-Photos.png'),
            ),
            Divider(),
            Text(
              "Total Deaths",
              style: TextStyle(
                color: black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  // color: Colors.pink,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: PieChart(
                  chartValuesOptions:
                      ChartValuesOptions(showChartValuesInPercentage: true),
                  dataMap: {
                    "World": worldDeaths.toDouble(),
                    current: deathOfThatCountry / 1000.toDouble()
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Active",
                          style: TextStyle(
                              color: black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        PieChart(
                          chartValuesOptions: ChartValuesOptions(
                              showChartValuesInPercentage: true),
                          chartRadius: MediaQuery.of(context).size.width / 3.5,
                          legendOptions: LegendOptions(showLegends: false),
                          chartType: ChartType.ring,
                          dataMap: {
                            "World": worldActive.toDouble(),
                            current: activeCountry / 1000.toDouble()
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Total Cases",
                          style: TextStyle(
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        PieChart(
                          chartValuesOptions: ChartValuesOptions(
                              showChartValuesInPercentage: true),
                          legendOptions: LegendOptions(showLegends: false),
                          chartType: ChartType.ring,
                          chartRadius: MediaQuery.of(context).size.width / 3.5,
                          dataMap: {
                            "World": totalCasesWorld.toDouble(),
                            current: totalCasesCountry / 1000.toDouble()
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 28,
            ),
            Container(
              width: double.infinity,
              color: blue,
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Text(
                  "Made with ❤ by FlyDeck",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
