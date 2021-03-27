import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_app_template/widgets/button.dart';

class MyNFTGridView extends StatelessWidget {
  final String name;
  final String description;
  final List<dynamic> image;
  final String button1;
  final String button2;
  final String button3;

  MyNFTGridView(
      {this.name,
      this.description,
      this.image,
      this.button1,
      this.button2,
      this.button3});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 150,
          child: Column(
            children: [
              button(Theme.of(context).buttonColor,
                  Theme.of(context).backgroundColor, button1),
              button(Theme.of(context).buttonColor,
                  Theme.of(context).backgroundColor, button2),
              button(Theme.of(context).buttonColor,
                  Theme.of(context).backgroundColor, button2),
            ],
          ),
        ),
        Container(
          width: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.memory(
                  Uint8List.fromList(
                    image.cast<int>(),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                      child: Flexible(
                    child: Text(
                      "Name: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                  SizedBox(width: 2),
                  Container(child: Flexible(child: Text(name))),
                ],
              ),
              Row(
                children: [
                  Container(
                      child: Flexible(
                    child: Text(
                      "Description: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                  SizedBox(width: 2),
                  Container(child: Flexible(child: Text(description))),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
