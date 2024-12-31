import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fa'), // farsi
        ],
        theme: ThemeData(
            fontFamily: "Dana",
            textTheme: const TextTheme(
                headlineLarge: TextStyle(
                    fontFamily: "Dana",
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                bodyMedium: TextStyle(
                  fontFamily: "Dana",
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
                bodySmall: TextStyle(
                  fontFamily: "Dana",
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
                headlineMedium: TextStyle(
                  fontFamily: "Dana",
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w300,
                ),
                headlineSmall: TextStyle(
                  fontFamily: "Dana",
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w300,
                ),
                bodyLarge: TextStyle(
                  fontFamily: "Dana",
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ))),
        debugShowCheckedModeBanner: false,
        home: const Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Currency> currency = [];
  Future getRispons(BuildContext cntx) async {
    var url =
        "https://sasansafari.com/flutter/api.php?access_key=flutter123456";

    var value = await http.get(Uri.parse(url));

    if (currency.isEmpty) {
      if (value.statusCode == 200) {
        // ignore: use_build_context_synchronously
        _showsnakbar(context, "به روز رسانی اطلاعات با موفقیت انجام شد");
        List jsonList = convert.jsonDecode(value.body);

        if (jsonList.isNotEmpty) {
          for (var i = 0; i < jsonList.length; i++) {
            setState(() {
              currency.add(Currency(
                  id: jsonList[i]["id"],
                  title: jsonList[i]["title"],
                  price: jsonList[i]["price"],
                  change: jsonList[i]['changes'],
                  status: jsonList[i]["status"]));
            });
          }
        }
      }
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    getRispons(context);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double bodyMargin = size.width / 12;
    getRispons(context);
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [
            SizedBox(width: bodyMargin),
            Image.asset("assets/images/icon.png"),
            const SizedBox(width: 16),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  " قیمت به روز ارز",
                  style: Theme.of(context).textTheme.headlineLarge,
                )),
            Expanded(
                child: Align(
                    alignment: Alignment
                        .centerLeft, // تغییر به centerLeft برای راست‌چین
                    child: Image.asset("assets/images/menu.png"))),
            SizedBox(width: bodyMargin)
          ],
        ),
        body: Padding(
            padding: EdgeInsets.fromLTRB(
                bodyMargin, bodyMargin, bodyMargin, bodyMargin * 2),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset("assets/images/752675.png"),
                  const SizedBox(width: 8),
                  Text("نرخ آزاد ارز چیست ؟",
                      style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, bodyMargin, 0, 0)),
              Text(
                "نرخ ارزها در معاملات نقدی و رایج روزانه است معاملات نقدی معاملاتی هستند که خریدار و فروشنده به محض انجام معامله، ارز و ریال را با هم تبادل می نمایند.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              // textDirection: TextDirection.RTL),
              Padding(padding: EdgeInsets.fromLTRB(0, bodyMargin * 1.2, 0, 0)),
              Container(
                width: size.width,
                height: size.height / 25,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(1000)),
                    color: Color.fromARGB(255, 130, 130, 130)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("نام آزاد ارز",
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text("قیمت", style: Theme.of(context).textTheme.bodyMedium),
                    Text("تغییر",
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 2.3,

                // چرخش یه چیز گرد قبل از لود کردن مقادیر api
                child: listfutureBuilder(context),
              ),
              SizedBox(
                height: size.height / 17,
              ),

              //دکمه بروز رسانی
              DokmeBerozresani(
                onRefresh: refreshData,
              )
            ])));
  }

  FutureBuilder<void> listfutureBuilder(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double bodyMargin = size.width / 12;
    return FutureBuilder(
        builder: (context, snapshote) {
          return snapshote.hasData
              ? ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: currency.length,
                  itemBuilder: (BuildContext context, int postion) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(0, bodyMargin / 3.5, 0, 0),
                      child: StyleGHesmatArzha(postion, currency),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    // if (index % 9 == 0) {
                    //   return add();
                    // } else {
                    return const SizedBox(
                      height: 0,
                    );
                    // }
                  },
                )
              : const Center(child: CircularProgressIndicator());
        },
        future: getRispons(context));
  }

  void refreshData() async {
    setState(() {
      currency.clear(); // پاک کردن لیست
    });

    await getRispons(context); // فراخوانی تابع برای دریافت داده‌ها

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("اطلاعات با موفقیت به‌روز شد"),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class DokmeBerozresani extends StatelessWidget {
  final VoidCallback onRefresh;

  const DokmeBerozresani({
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: Container(
          width: double.infinity,
          height: size.height / 17,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 232, 232, 232),
              borderRadius: BorderRadius.circular(1000)),
          child: Row(
            children: [
              TextButton.icon(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 202, 195, 255))),
                onPressed: onRefresh, // فراخوانی متد
                label: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                  child: Text("بروز رسانی",
                      style: Theme.of(context).textTheme.headlineLarge),
                ),
                icon: const Icon(
                  CupertinoIcons.refresh_thin,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Text(
                  "آخرین بروز رسانی ${_gettime()}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            ],
          ),
          // ignore: dead_code
        ));
  }
}

String? _gettime() {
  DateTime now = DateTime.now();
  return DateFormat("kk:mm").format(now);
}

// ignore: must_be_immutable
class StyleGHesmatArzha extends StatelessWidget {
  int postion;
  List<Currency> currency;
  StyleGHesmatArzha(this.postion, this.currency, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 17,
      decoration: BoxDecoration(boxShadow: const <BoxShadow>[
        BoxShadow(blurRadius: 1.0, color: Colors.grey)
      ], color: Colors.white, borderRadius: BorderRadius.circular(1000)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            currency[postion].title!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            currency[postion].price!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            currency[postion].change!,
            style: currency[postion].status == "n"
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.headlineMedium,
          )
        ],
      ),
    );
  }
}

// ignore: non_constant_identifier_names
void _showsnakbar(BuildContext Context, String msg) {
  ScaffoldMessenger.of(Context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: Colors.green,
  ));
}

class Add extends StatelessWidget {
  const Add({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 33,
      decoration: BoxDecoration(
          boxShadow: const <BoxShadow>[
            BoxShadow(blurRadius: 1, color: Colors.grey),
          ],
          color: const Color.fromARGB(217, 255, 128, 0),
          borderRadius: BorderRadius.circular(1000)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "تبلیغات",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class Currency {
  String? id;
  String? title;
  String? price;
  String? change;
  String? status;

  Currency(
      {required this.id,
      required this.title,
      required this.price,
      required this.change,
      required this.status});
}
