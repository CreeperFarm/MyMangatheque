import 'package:flutter/material.dart';

class SeriesPages extends StatefulWidget {
  final String seriesName;

  const SeriesPages({required this.seriesName, super.key});

  @override
  State<SeriesPages> createState() => _SeriesPagesState();
}

class _SeriesPagesState extends State<SeriesPages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Series"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: /*FutureBuilder(
            future: FirebaseFirestore.instance.collection("manga").doc(widget.seriesName).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

              if (snapshot.hasError) {
                return const Text("Une erreur est survenue");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return const Text("Les données n'existent pas");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                print(data);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyPictureDisplay(pictureUrl: "https://cdn.statically.io/gh/CreeperFarm/AppManga/main/${data['img']}.jpg"),
                    Text(data['manga']),
                    MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                    Text(data['author']),
                    MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
                    Text(data['releaseDate']),
                  ],
                );
              }
              return const Text("loading");
            },
          ),*/
            Text("Soon"),
      ),
    );
  }
}
