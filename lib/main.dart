import 'package:feature_discovery/feature_discovery.dart';
import 'package:feature_discovery/layout.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final feature1 = "FEATURE_1";
final feature2 = "FEATURE_2";
final feature3 = "FEATURE_3";
final feature4 = "FEATURE_4";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feature Discovery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return FeatureDiscovery(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: DescribedFeatureOverlay(
            featureId: feature1,
            icon: Icons.menu,
            color: Colors.green,
            title: "The title",
            description: "The description",
            child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {},
            ),
          ),
          title: Text(""),
          actions: <Widget>[
            DescribedFeatureOverlay(
              featureId: feature2,
              icon: Icons.search,
              color: Colors.green,
              title: "The title",
              description: "The description",
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: Content(),
        floatingActionButton: DescribedFeatureOverlay(
          featureId: feature3,
          icon: Icons.add,
          color: Colors.blue,
          title: "The title",
          description: "The description",
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

class Content extends StatefulWidget {
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Image.network(
              "https://www.visitnewportbeach.com/wp-content/uploads/2018/04/star700x400-700x400.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200.0,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Starbucks Coffe",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    "Coffe Shop",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: RaisedButton(
                onPressed: () {
                  FeatureDiscovery.discoverFeatures(
                      context, [feature1, feature2, feature3, feature4]);
                },
                child: Text("Do Feature Discovery"),
              ),
            )
          ],
        ),
        Positioned(
          top: 200,
          right: 0,
          child: FractionalTranslation(
            translation: Offset(-0.5, -0.5),
            child: DescribedFeatureOverlay(
              featureId: feature4,
              icon: Icons.drive_eta,
              color: Colors.blue,
              title: "The title",
              description: "The description",
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                child: Icon(Icons.drive_eta),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
