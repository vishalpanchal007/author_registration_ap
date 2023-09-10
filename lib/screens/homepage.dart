import 'dart:convert';
import 'dart:io';
import 'package:author_registration_app/helper/firestore_db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextStyle mystyle = TextStyle(color: Colors.white);
  final GlobalKey<FormState> insertkey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateKey = GlobalKey<FormState>();

  TextEditingController authorController = TextEditingController();
  TextEditingController bookController = TextEditingController();

  String? author;
  String? book;
  Uint8List? image;
  Uint8List? decodedImage;
  String encodedImage = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Author Kepper"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: validatorandinsert,
        label: Text("Add Author data"),
        icon: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: CloudFirestoreHelper.cloudFirestoreHelper.selectrecord(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: Text("ERROR : ${snapShot.error}"),
            );
          } else if (snapShot.hasData) {
            QuerySnapshot? data = snapShot.data;
            List<QueryDocumentSnapshot> documents = data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, i) {
                if (documents[i]['image'] != null) {
                  decodedImage = base64Decode(documents[i]['image']);
                } else {
                  decodedImage == null;
                }

                return Card(
                  elevation: 5,
                  shadowColor: Colors.orange,
                  child: ListTile(
                      isThreeLine: true,
                      leading: (decodedImage == null)
                          ? const Text(
                        "NO IMAGE",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      )
                          : Container(
                        height: 65,
                        width: 65,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            decodedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text("${documents[i]['author']}"),
                      subtitle: Text("${documents[i]['book']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Update Records"),
                                  content: Form(
                                    key: updateKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          validator: (val) {
                                            (val!.isEmpty)
                                                ? "Enter author First..."
                                                : null;
                                          },
                                          onSaved: (val) {
                                            author = val;
                                          },
                                          controller: authorController,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Enter author Here....",
                                              labelText: "author"),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          maxLines: 5,
                                          validator: (val) {
                                            (val!.isEmpty)
                                                ? "Enter book First..."
                                                : null;
                                          },
                                          onSaved: (val) {
                                            book = val;
                                          },
                                          controller: bookController,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Enter book Here....",
                                              labelText: "book"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      child: const Text("Update"),
                                      onPressed: () {
                                        if (updateKey.currentState!
                                            .validate()) {
                                          updateKey.currentState!.save();

                                          Map<String, dynamic> data = {
                                            'author': author,
                                            'book': book,
                                          };
                                          CloudFirestoreHelper
                                              .cloudFirestoreHelper
                                              .updateRecords(
                                              id: documents[i].id,
                                              data: data);
                                        }
                                        authorController.clear();
                                        bookController.clear();

                                        author = "";
                                        book = "";
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    OutlinedButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        authorController.clear();
                                        bookController.clear();

                                        author = null;
                                        book = null;

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await CloudFirestoreHelper.cloudFirestoreHelper
                                  .deleterecord(id: "${documents[i].id}");
                            },
                          ),
                        ],
                      )),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  validatorandinsert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text("Enter book details here"),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: insertkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    final ImagePicker _picker = ImagePicker();
                    XFile? img =
                    await _picker.pickImage(source: ImageSource.gallery);
                    if (img != null) {
                      File compressedImage =
                      await FlutterNativeImage.compressImage(img.path);
                      image = await compressedImage.readAsBytes();
                      encodedImage = base64Encode(image!);
                    }
                    setState(() async {});
                  },
                  child: CircleAvatar(
                    radius: 50,
                    child: Center(
                      child: image == null
                          ? const Text(
                        "ADD IMAGE",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      )
                          : Container(
                        height: 20,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.memory(
                            image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  validator: (val) {
                    (val!.isEmpty) ? "Enter author" : null;
                  },
                  controller: authorController,
                  onSaved: (val) {
                    author = val;
                  },
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "author",
                    hintText: "Enter author Here...",
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  validator: (val) {
                    (val!.isEmpty) ? "Enter book" : null;
                  },
                  controller: bookController,
                  onSaved: (val) {
                    book = val;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "book",
                    hintText: "Enter book Here...",
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text("Submit"),
            onPressed: () async {
              if (insertkey.currentState!.validate()) {
                insertkey.currentState!.save();

                Map<String, dynamic> data = {
                  'author': author,
                  'book': book,
                  'image': encodedImage,
                };

                await CloudFirestoreHelper.cloudFirestoreHelper
                    .insertrecord(data: data);

                Navigator.of(context).pop();
                authorController.clear();
                bookController.clear();
                setState(() {
                  author = null;
                  book = null;
                  decodedImage = null;
                });
              }
            },
          ),
          ElevatedButton(
              onPressed: () {
                authorController.clear();
                bookController.clear();
                setState(() {
                  author = null;
                  book = null;
                  decodedImage = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Cancel")),
        ],
      ),
    );
  }
}