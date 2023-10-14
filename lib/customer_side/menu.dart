import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  Future<QuerySnapshot> fetchMilkTeaMenu() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('/milktea_menu/inventory/milktea/')
        .get();

    return querySnapshot;
  }

  Future<String> _getImage(String gsUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(gsUrl);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print('Error: $error');
      return ''; // Return an empty string or placeholder image URL in case of an error
    }
  }

  void _openModal(BuildContext context, String name, String desc, String imageUrl) async {
    final imageUrlHttp = await _getImage(imageUrl);

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 1000, // Adjust the height of the modal as needed
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(imageUrlHttp), // Load image from Firebase Storage
                  radius: 100, // Adjust the size of the circle avatar
                ),
                Text('Name: $name'),
                Text('Description: $desc'),
                SizedBox(height: 16.0), // Add some spacing
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: Text('Milk Tea Menu'),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: fetchMilkTeaMenu(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No data available.'));
            } else {
              List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> milkTeaData =
                  documents[index].data() as Map<String, dynamic>;

                  List<Map<String, dynamic>> allMaps = [];
                  milkTeaData.forEach((key, value) {
                    if (value is Map<String, dynamic>) {
                      allMaps.add(value);
                    }
                  });

                  // Create a separate Card for each mapData
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: allMaps.map((mapData) {
                      return InkWell(
                        splashColor: Colors.greenAccent,
                        onTap: () async {
                          print("tap ${mapData['name']}");
                          final imageUrl = mapData['image'];
                          _openModal(context, mapData['name'], mapData['desc'], imageUrl);
                        },
                        child: Card(
                          color: Colors.orangeAccent,
                          child: Column(
                            children: [
                              FutureBuilder<String>(
                                future: _getImage(mapData['image']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    final imageUrlHttp = snapshot.data ?? '';
                                    return CircleAvatar(
                                      backgroundImage: NetworkImage(imageUrlHttp),
                                      radius: 75,
                                    );
                                  }
                                },
                              ),
                              Text('Name: ${mapData['name'] ?? ''}'),
                              Text('Description: ${mapData['desc'] ?? ''}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
