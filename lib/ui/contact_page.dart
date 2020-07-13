import 'dart:io';

import 'package:agendayago/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;


  //criando um construtor que recebe o contato
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editContact;
  bool _userEdit = false;

//criando os controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.contact == null){
      _editContact = Contact();
    }else{
      _editContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editContact.name;
      _emailController.text = _editContact.email;
      _phoneController.text = _editContact.phone;

    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editContact.name ?? "Novo Contato"),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editContact.name.isNotEmpty && _editContact.name != null){
              Navigator.pop(context, _editContact);
            }else{
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.teal,
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child:  Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        //verifica se a img existe senão seta uma padrao
                          image: _editContact.img != null ?
                          FileImage(File(_editContact.img)) :
                          AssetImage("images/luffy.jpg"),
                        fit: BoxFit.cover
                      )
                  ),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.camera).then((file){
                    if(file == null){
                      return;
                    }else{
                      setState(() {
                        _editContact.img = file.path;
                      });
                    }
                  });
                  
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){
                  _userEdit = true;
                  setState(() {
                    _editContact.name = text;
                  });
                },
              ),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text){
                  _userEdit = true;
                  _editContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),

              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Telefone"),
                onChanged: (text){
                  _userEdit = true;
                  _editContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //pergunta se ele quer salvar as alterações
  Future <bool> _requestPop(){
    if(_userEdit){
      showDialog(context: context,
        builder: (context){
        return AlertDialog(
            title: Text("Descartar Alterações?"),
          content: Text("Caso saia, as alterações serão descartadas"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: (){
                //vai voltar para o contatc page
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Sair"),
              onPressed: (){
                //vai voltar para o contatc page
                Navigator.pop(context);
                // vai voltar para o HomePage
                Navigator.pop(context);

              },
            ),
          ],
        );
        }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

}
