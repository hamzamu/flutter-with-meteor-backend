/**
 * 
 * 
 * Working Finally 
 * 
 * just change "Posts" to "posts"
 */

import 'package:flutter/material.dart';
import 'package:enhanced_meteorify/enhanced_meteorify.dart';

void main() async {
  try {
    var status = await Meteor.connect('ws://localhost:3000/websocket');
    // Do something after connection is successful
  } catch (error) {
    print(error);
    //Handle error
  }

  var subscriptionId = await Meteor.subscribe('posts');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final myController = TextEditingController();

  List<dynamic> posts = [];

  List<dynamic> results = [];

  String callResult = "";

//
  void getData() async {
    SubscribedCollection collection = await Meteor.collection('posts');

    // collection.addUpdateListener((collection, operation, id, doc) {
    //   print('updated: $doc');
    //   if (!posts.contains(doc)) {
    //     setState(() {
    //       posts.add(doc);
    //     });
    //   }
    // });

    collection.findAll()
      ..forEach((key, value) {
        value["_id"] = key;
        // print(value);
        if (!posts.contains(value)) {
          setState(() {
            posts.add(value);
          });
        }
      });

    // posts = collection.findAll() as List;
    // print(posts);
    print('Posts Done');
  }

  Future<SubscribedCollection> fetchPosts() async {
    SubscribedCollection collection = await Meteor.collection('posts');

    setState(() {
      collection.addUpdateListener((collection, operation, id, doc) {
        print('Updates: $doc');
        setState(() {
          posts.add(doc);
        });
      });
    });

    return collection;
  }

  @override
  void initState() {
    super.initState();
    getData();
    fetchPosts();
  }

  void addNew() async {
    print('add new');

    try {
      var result = await Meteor.call('addNew', [
        {'task': myController.text, 'status': null}
      ]);
      myController.clear();

      callResult = result.toString();
      print(result);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(callResult),
            TextField(
              controller: myController,
            ),
            Divider(),
            ElevatedButton(onPressed: addNew, child: Text('Add new')),
            Divider(),
            for (var i = 0; i < posts.length; i++)
              Text(posts[i]['task'].toString()),
            ElevatedButton(onPressed: () {}, child: Text("getPosts"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
