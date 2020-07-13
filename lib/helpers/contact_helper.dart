//classe de BD
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//colunas da tabela
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  //contem apenas um objeto, usando o singletown
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  //só pode ser chamado interno
  ContactHelper.internal();

  //declarando  o BD
  Database _db;

//inicializando o BD
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    //local onde vai armazenar o bd
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contactsnew.db");

    //abrindo o BD
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          //criando a tabela
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY,"
          "$nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  //salva o contato na tabela e seta um id
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

//obtem os dados do contato
  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    //retorna o contato através de um mapa
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //funcao para deletar o contato
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  //Atualizar o contato
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

//obter todos os contatos
  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

//fucao para obter o numero de contatos
  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

//funcao para fechar o BD
  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

//definindo o molde
class Contact {
  String name, email, phone, img;
  int id;

  //contrutor vazio
  Contact();

  //armazena os dados em um map e recupera ele apos tranformar
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

//tranforma os dados do contato em um Map
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    if (id == null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Contact (id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
