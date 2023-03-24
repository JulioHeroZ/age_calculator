import 'package:age_calculator/views/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:time/time.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  CollectionReference clientes =
      FirebaseFirestore.instance.collection('Clientes');
  Stream<QuerySnapshot> _getList() {
    return clientes.orderBy('Data de Nascimento').snapshots();
  }

  late TextEditingController _searchController;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> sendBirthdayEmail(
      List<Map<String, dynamic>> todayBirthdays) async {
    // Configurações do servidor SMTP do Gmail
    final smtpServer =
        gmail('juliohero64@gmail.com', 'Julio1065671133!@36414078');

    // Cria a mensagem de email
    final message = Message()
      ..from = Address('juliohero64@gmail.com', 'Júlio')
      ..recipients.addAll([
        'juliohero64@gmail.com'
      ]) // Adicione aqui os emails dos destinatários
      ..subject = 'Aniversariantes de hoje'
      ..html = '''
      <h1>Aniversariantes de hoje:</h1>
      ${todayBirthdays.map((b) => '<p>${b['Nome']} - ${DateFormat('dd/MM/yyyy').format((b['Data de Nascimento'] as Timestamp).toDate())}</p>').join('\n')}
    ''';

    // Tenta enviar o email
    try {
      final sendReport = await send(message, smtpServer);
      print('Email enviado: ${sendReport.toString()}');
    } on MailerException catch (e) {
      print('Erro ao enviar email: $e');
    }
  }

  Future<void> main() async {
    // Define a hora em que o email será enviado (às 8h da manhã)
    final scheduledTime = DateTime(8, 0, 0);

    // Aguarda até que seja o horário agendado
    while (true) {
      final now = DateTime.now();
      if (now.hour >= scheduledTime.hour &&
          now.minute >= scheduledTime.minute) {
        break;
      }
      await Future.delayed(Duration(minutes: 1));
    }

    // Envia o email
    await checkAndSendEmail();

    // Aguarda um dia e executa novamente
    await Future.delayed(Duration(days: 1));
    main(); // chama a função main novamente para agendar o envio do próximo email
  }

// Define a função checkAndSendEmail que verifica se há novas mensagens e envia um email
  Future<void> checkAndSendEmail() async {
    final newMessages = await fetchNewMessages();
    if (newMessages.isNotEmpty) {
      await sendEmail(newMessages);
    }
  }

// Define a função fetchNewMessages que busca novas mensagens
  Future<List<Message>> fetchNewMessages() async {
// Simula uma busca por novas mensagens em um servidor de email
    await Future.delayed(Duration(seconds: 5));

// Retorna uma lista vazia como não há novas mensagens
    return [];
  }

// Define a função sendEmail que envia um email
  Future<void> sendEmail(List<Message> messages) async {
// Simula o envio de um email
    await Future.delayed(Duration(seconds: 2));
    print('Email enviado com sucesso!');
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
      ),
    );
  }

  Widget build(BuildContext context) {
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
    int currentIndex = 1;

    DateTime today = DateTime.now();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchBar(),
              ),
              Expanded(
                child: Container(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getList(),
                    builder: (_, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text('Não possui dados'),
                            );
                          }
                          final filteredDocs = snapshot.data!.docs.where((doc) {
                            DateTime dateOfBirth =
                                (doc['Data de Nascimento'] as Timestamp)
                                    .toDate();
                            return dateOfBirth.month == today.month &&
                                dateOfBirth.day == today.day &&
                                (doc['Nome'] as String)
                                    .toLowerCase()
                                    .contains(_searchText.toLowerCase());
                          }).toList();
                          if (filteredDocs.isEmpty) {
                            return Center(
                              child: Text('Não há aniversariantes hoje'),
                            );
                          }

                          // Ordenar a lista por data de nascimento
                          filteredDocs.sort((a, b) {
                            DateTime dateOfBirthA =
                                (a['Data de Nascimento'] as Timestamp).toDate();
                            DateTime dateOfBirthB =
                                (b['Data de Nascimento'] as Timestamp).toDate();
                            return dateOfBirthA.compareTo(dateOfBirthB);
                          });
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: filteredDocs.length,
                            itemBuilder: (_, index) {
                              final DocumentSnapshot doc = filteredDocs[index];
                              return ListTile(
                                title: Text(doc['Nome']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(doc['Email']),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(
                                        (doc['Data de Nascimento'] as Timestamp)
                                            .toDate(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                      }
                    },
                  ),
                ),
              ),
            ],
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
        ));
  }
}
