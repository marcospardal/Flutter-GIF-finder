import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

import 'package:gif_finder/ui/gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  String _search;
  int _offset = 75;

  Future<Map> _handleSearch() async {
    http.Response response;

    if (_search == null || _search == '')
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=bba4d6u1RDPnJyLM0LNCmAFQV6Ij65wi&limit=24&rating=g");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=bba4d6u1RDPnJyLM0LNCmAFQV6Ij65wi&q=$_search&limit=25&offset=$_offset&rating=g&lang=en");

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _handleSearch().then((map) => null);
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemBuilder: (context, index) {
        if ((_search == null || _search == '') ||
            index < snapshot.data['data'].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data['data'][index])));
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    "Load more...",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += 24;
                });
              },
            ),
          );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getCount(snapshot.data['data']),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search == '') {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Search",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              style: TextStyle(color: Colors.white, fontSize: 18),
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Container(
                          height: 200,
                          width: 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 5,
                          ),
                        );
                      default:
                        if (snapshot.hasError)
                          return Container();
                        else
                          return _createGifTable(context, snapshot);
                    }
                  },
                  future: _handleSearch()))
        ],
      ),
    );
  }
}
