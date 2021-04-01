import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_app_template/widgets/button.dart';

class MyNFTGridView extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final bool isAuction;
  final List<dynamic> image;
  final String button1;
  final String buttonStartAuction;
  final String button3;
  final Function functionStartAuction;
  final String buttonRemoveAuction;
  final Function functionRemoveAuction;

  MyNFTGridView(
      {this.id,
      this.name,
      this.description,
      this.isAuction,
      this.image,
      this.button1,
      this.buttonStartAuction,
      this.button3,
      this.functionStartAuction,
      this.buttonRemoveAuction,
      this.functionRemoveAuction});

  @override
  _MyNFTGridViewState createState() => _MyNFTGridViewState();
}

class _MyNFTGridViewState extends State<MyNFTGridView> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.grey,
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              child: Image.memory(
                Uint8List.fromList(
                  widget.image.cast<int>(),
                ),
                fit: BoxFit.fill,
              ),
            ),
            Row(
              children: [
                Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Token Id: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                SizedBox(width: 2),
                Container(child: Flexible(child: Text(widget.id))),
              ],
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "Name: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 2),
                Container(child: Flexible(child: Text(widget.name))),
              ],
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "Description: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 2),
                Container(child: Flexible(child: Text(widget.description))),
              ],
            ),
            widget.isAuction
                ? Row(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "NFT is in an Auction: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 2),
                      Container(child: Flexible(child: Text("Yes"))),
                      SizedBox(width: 10),
                      button(
                          Theme.of(context).buttonColor,
                          Theme.of(context).backgroundColor,
                          widget.buttonRemoveAuction,
                          widget.functionRemoveAuction,
                          [widget.id]),
                    ],
                  )
                : SizedBox(height: 25),
            Row(
              children: [
                button(Theme.of(context).buttonColor,
                    Theme.of(context).backgroundColor, widget.button1),
                button(
                    Theme.of(context).buttonColor,
                    Theme.of(context).backgroundColor,
                    widget.buttonStartAuction,
                    widget.functionStartAuction,
                    [widget.id, "3"]),
                //button(Theme.of(context).buttonColor,
                //    Theme.of(context).backgroundColor, widget.button3),
              ],
            )
          ],
        ),
      ),
    );
  }
}
