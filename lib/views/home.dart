import 'package:age_calculator/constant/color.dart';
import 'package:age_calculator/views/result.dart';
import 'package:age_calculator/widget/app_name.dart';
import 'package:age_calculator/widget/custom_bottom_paint.dart';
import 'package:age_calculator/widget/custom_large_button.dart';
import 'package:age_calculator/widget/custom_top_paint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nome = TextEditingController();
  final dataNascimento = TextEditingController();
  final email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    List<BottomNavigationBarItem> bottomNavBarItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Cadastro',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Lista',
      ),
    ];
    int currentIndex = 0;

    CollectionReference clientes =
        FirebaseFirestore.instance.collection('Clientes');

    Future<Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>>
        addClients() async {
      // Convertendo a data de nascimento para o formato brasileiro
      final formatter = DateFormat('dd/MM/yyyy');
      final dataNascimentoFormated = formatter.parse(dataNascimento.text);

      // Criando um mapa com os dados inseridos pelo usuário
      Map<String, dynamic> data = {
        'Nome': nome.text,
        'Data de Nascimento': dataNascimentoFormated,
        'Email': email.text,
      };
      nome.clear();
      dataNascimento.clear();
      email.clear();

      return clientes
          .add(data)
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Cliente adicionado com sucesso!"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro ao adicionar um cliente: $error"))));
    }

    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(width, (350 * 0.31473214285714285).toDouble()),
                      painter: CustomTopPaint(),
                    ),
                    Positioned(top: 30, child: AppName())
                  ],
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Cadastre os aniversáriantes abaixo!',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'roboto',
                    color: textColor,
                  ),
                ),
              ),
              Spacer(),
              Container(
                child: SvgPicture.asset("assets/gift.svg",
                    width: 120, height: 120, semanticsLabel: 'Acme Logo'),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: nome,
                  decoration: InputDecoration(
                      hintText: 'Nome', border: OutlineInputBorder()),
                ),
              ),
              SizedBox(
                height: 1,
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                      hintText: 'Email', border: OutlineInputBorder()),
                ),
              ),

              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: dataNascimento,
                  readOnly: true,
                  onTap: () async {
                    Intl.defaultLocale = 'pt_BR';
                    await initializeDateFormatting('pt_BR', null);
                    WidgetsFlutterBinding.ensureInitialized();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      initialEntryMode: DatePickerEntryMode.inputOnly,
                    );
                    if (date != null) {
                      // Formatando a data selecionada no padrão brasileiro
                      final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
                      dataNascimento.text = formatter.format(date);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Data de nascimento',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              // DatePickerField(
              //   level: 'Select today\'s date',
              //   onTap: () =>
              //       _selectDate(context, selectedCurrentDate, "CurrentDate"),
              //   hintText: "${getFormatedDate(selectedCurrentDate)}",
              // ),
              Container(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 80),
                      child: CustomPaint(
                        size:
                            Size(width, (399 * 0.31473214285714285).toDouble()),
                        painter: CustomBottomPaint(),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      child: CustomLargeButton(
                          buttonLevel: "Cadastrar", onPressed: addClients),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavBarItems,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          // Navegar para a tela correspondente
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultPage(),
              ),
            );
          }
        },
      ),
    );
  }
}
