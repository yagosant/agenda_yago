import 'dart:io';

import 'package:agendayago/helpers/contact_helper.dart';
import 'package:agendayago/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions{orderaz, orderza}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

List<Contact> contats = List();

@override
  void initState() {
    // TODO: implement initState
    super.initState();
  _getAllContacts();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agenda Yago"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de A-Z"),
              value: OrderOptions.orderaz,),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,)
            ] ,
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _trocaTela();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),

      //conf do body
      body: ListView.builder(
        itemCount: contats.length,
          itemBuilder: (context, index){
            return _contactCard(context, index);
          },
      padding: EdgeInsets.all(10.0),
      ),
    );
  }

  //o card de cada contato
  Widget _contactCard (BuildContext context,int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          //conteudo do card
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    //verifica se a img existe senão seta uma padrao
                    image: contats[index].img != null ?
                        FileImage(File(contats[index].img)) :
                        AssetImage("images/luffy.jpg"),
                      fit: BoxFit.cover
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contats[index].name ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0
                    ),),

                    Text(contats[index].email ?? "",
                      style: TextStyle(
                          fontSize: 18.0
                      ),),

                    Text(contats[index].phone ?? "",
                      style: TextStyle(
                          fontSize: 18.0
                      ),),


                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
       // _trocaTela(contact: contats[index]);
      },
    );
  }
  
  //funcao troca tela
void _trocaTela({Contact contact}) async{
 final recContact = await Navigator.push(context,
  MaterialPageRoute(builder: (context)=>ContactPage(contact: contact,))
  );

 if(recContact != null){
   if(contact != null){
     //edicao contato
     await helper.updateContact(recContact);
   }else{
     //salva um novo contato
     await helper.saveContact(recContact);
   }
   _getAllContacts();
 }
}

//lista todos contatos
void _getAllContacts(){
  helper.getAllContacts().then((list){
    setState(() {
      contats = list;
    });
  });
}

void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contats.sort((a,b){
         return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contats.sort((a,b){
         return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
        setState(() {

        });
    }
  }

//exibe as opções do contato
void _showOptions(BuildContext context, int index){
  showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Ligar",
                      style: TextStyle(color: Colors.teal,fontSize: 20.0),),
                      onPressed: (){
                        //para ligar para alguem
                        launch("tel:${contats[index].phone}");
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Editar",
                        style: TextStyle(color: Colors.teal,fontSize: 20.0),),
                      onPressed: (){
                        Navigator.pop(context);
                        _trocaTela(contact: contats[index]);
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Excluir",
                        style: TextStyle(color: Colors.teal,fontSize: 20.0),),
                      onPressed: (){
                        helper.deleteContact(contats[index].id);
                        setState(() {
                          contats.removeAt(index);
                          Navigator.pop(context);
                        });

                      },
                    ),
                  ),

                ],
              ),
            );
          },
        );
      }
  );
}
}
