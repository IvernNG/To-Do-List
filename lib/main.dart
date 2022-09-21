import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:todolist/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'To Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _itemNameController = TextEditingController();
  TextEditingController _editController = TextEditingController();
  var fetchData = FirebaseFirestore.instance
      .collection("todolist")
      .orderBy("createdTime")
      .snapshots();
  var isEdit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isEdit
          ? null
          : FloatingActionButton(
              elevation: 20,
              onPressed: () {
                addTask();
              },
              tooltip: 'Increment',
              child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple,
                        Colors.purple,
                      ],
                    ),
                  ),
                  child: const Icon(Icons.add)),
            ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              Color(0xFFAB47BC),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 15, 15, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "To Do List",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    isEdit //edit icon shifting
                        ? IconButton(
                            onPressed: () {
                              isEdit = false;
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              isEdit = true;
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.create_sharp,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: fetchData,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    List items = snapshot.data!.docs;

                    return Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: items.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Add New Task Now!",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : isEdit //display normal view or edit view
                                  ? editListView(items)
                                  : RefreshIndicator(
                                      child: SizedBox(
                                        child: listView(items),
                                        height:
                                            MediaQuery.of(context).size.height,
                                      ),
                                      onRefresh: _refresh,
                                      color: Colors.purple,
                                    ),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() {
    return Future.delayed(
      Duration(seconds: 1),
    );
  }

  //Pop up for add new task
  addTask() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.only(
          left: 30,
          right: 30,
        ),
        title: const Text("Add New Task"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
                width: 300,
              ),
              TextField(
                controller: _itemNameController,
                autofocus: true,
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  hintText: "Enter New Task Name",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.black,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              createListing(_itemNameController.text);
            },
            child: const Text(
              "Create",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          TextButton(
            onPressed: () {
              _itemNameController.clear();
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  //Edit task
  editTask(String taskId, TextEditingController itemDescription) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.only(
          left: 30,
          right: 30,
        ),
        title: const Text("Rename Task"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
                width: 300,
              ),
              TextField(
                controller: itemDescription,
                autofocus: true,
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  hintText: "Enter New Listing Name",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.black,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              renameListing(taskId, itemDescription.text);
            },
            child: const Text(
              "Rename",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          TextButton(
            onPressed: () {
              _itemNameController.clear();
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  //save edit task description to backend
  renameListing(String taskId, String taskEditName) {
    FirebaseFirestore.instance.collection("todolist").doc(taskId).update(
      {
        "description": taskEditName,
      },
    );
    Navigator.pop(context);
    setState(() {});
  }

  //Normal List View
  listView(List items) {
    return ListView(
      shrinkWrap: true,
      children: [
        const Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
        for (var item in items) ...[
          FocusedMenuHolder(
            child: item["completed"]
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                    child: InkWell(
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection("todolist")
                            .doc(item["id"])
                            .update({"completed": false});

                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(13.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              offset: const Offset(0, 2),
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item["description"],
                                style: const TextStyle(
                                  fontSize: 21,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                    child: InkWell(
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection("todolist")
                            .doc(item["id"])
                            .update({"completed": true});

                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(13.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 8.0),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item["description"],
                                style: const TextStyle(
                                  fontSize: 21,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            onPressed: () {},
            menuItems: <FocusedMenuItem>[
              FocusedMenuItem(
                title: const Text(
                  "Delete",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                onPressed: () {
                  handleLongPress(item["id"]);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Edit List View
  editListView(List items) {
    return ListView(
      shrinkWrap: true,
      children: [
        const Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
        for (var item in items) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
            child: InkWell(
              onTap: () {
                _editController =
                    TextEditingController(text: item["description"]);
                editTask(item["id"], _editController);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(13.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 8.0),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item["description"],
                        style: const TextStyle(fontSize: 21),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0.0),
                      height: 30,
                      width: 30,
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: () => {
                          handleLongPress(item["id"]),
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        padding: const EdgeInsets.all(3.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  //Save listing into Firestore
  Future<void> createListing(String taskName) async {
    //get documentID of Task before create
    final docTask = FirebaseFirestore.instance.collection("todolist").doc();

    final jsonTask = {
      'id': docTask.id,
      'description': taskName,
      'completed': false,
      'createdTime': DateTime.now(),
    };

    await docTask.set(jsonTask);

    Navigator.of(context).pop();
    setState(
      () {
        _itemNameController.clear();
      },
    );
  }

  // Delete task
  handleLongPress(String todoId) {
    var docItem = FirebaseFirestore.instance.collection("todolist").doc(todoId);

    docItem.delete();
  }
}
