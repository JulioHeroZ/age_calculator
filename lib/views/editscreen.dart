import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditScreen extends StatefulWidget {
  final DocumentSnapshot document;

  EditScreen({required this.document});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late Timestamp _birth;

  @override
  void initState() {
    super.initState();
    _name = widget.document['Nome'];
    _email = widget.document['Email'];
    _birth = widget.document['Data de Nascimento'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _birth.toDate().toString(),
                decoration: InputDecoration(labelText: 'Data de Nascimento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an birth';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _birth = Timestamp.fromDate(DateTime.parse(value));
                  });
                },
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      FirebaseFirestore.instance
                          .collection('Clientes')
                          .doc(widget.document.id)
                          .update({
                        'Nome': _name,
                        'Email': _email,
                      }).then((_) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
