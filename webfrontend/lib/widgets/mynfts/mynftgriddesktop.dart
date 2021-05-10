import 'dart:typed_data';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/widgets/charts/linechart.dart';
import '../useravatar.dart';
import '/provider/contractinteraction.dart';
import '../buttons/button.dart';
import '../inputField.dart';

class MyNFTGridDesktopView extends StatefulWidget {
  final TextEditingController sellpriceamountController =
      TextEditingController();

  final myNFT;
  final String buttonStartOffer;
  final String buttonRemoveOffer;
  final String buttonStartAuction;
  final Function functionStartAuction;
  final String buttonRemoveAuction;
  final Function functionRemoveAuction;
  final Function functionRemoveOffer;

  MyNFTGridDesktopView({
    this.myNFT,
    this.buttonStartAuction,
    this.functionStartAuction,
    this.buttonRemoveAuction,
    this.functionRemoveAuction,
    this.buttonStartOffer,
    this.buttonRemoveOffer,
    this.functionRemoveOffer,
  });

  @override
  _MyNFTGridDesktopViewState createState() => _MyNFTGridDesktopViewState();
}

class _MyNFTGridDesktopViewState extends State<MyNFTGridDesktopView> {
  bool isOffer = false;
  var txold;

  @override
  Widget build(BuildContext context) {
    var tx = Provider.of<Contractinteraction>(context).tx;

    if (txold != tx) {
      setState(() {
        txold = tx;
      });
    }
    return FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: Card(
          //shadowColor: Colors.grey,
          color: Theme.of(context).primaryColor,
          //elevation: 10,
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
                      widget.myNFT["file"].cast<int>(),
                    ),
                    //fit: BoxFit.fill,
                  ),
                ),
                Row(
                  children: [
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "Token Id: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).highlightColor),
                        )),
                    SizedBox(width: 2),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        widget.myNFT["token_id"],
                        style:
                            TextStyle(color: Theme.of(context).highlightColor),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "Creator: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).highlightColor),
                        )),
                    SizedBox(width: 2),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            widget.myNFT["creator"]["username"],
                            style: TextStyle(
                                color: Theme.of(context).highlightColor),
                          ),
                        ),
                        SizedBox(width: 10),
                        Useravatar(
                            image: widget.myNFT["creator"]["avatar"],
                            width: 20,
                            height: 20),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "Name: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).highlightColor),
                      ),
                    ),
                    SizedBox(width: 2),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          widget.myNFT["name"],
                          style: TextStyle(
                              color: Theme.of(context).highlightColor),
                        )),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "Description: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).highlightColor),
                      ),
                    ),
                    SizedBox(width: 2),
                    Flexible(
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          //width: 275,
                          height: 64,
                          child: SingleChildScrollView(
                              child: Text(
                            widget.myNFT["description"],
                            style: TextStyle(
                                color: Theme.of(context).highlightColor),
                          ))),
                    ),
                  ],
                ),
                widget.myNFT["isAuction"]
                    ? Row(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              "NFT is in an Auction: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).highlightColor),
                            ),
                          ),
                          SizedBox(width: 2),
                          Container(
                              child: Text(
                            "Yes",
                            style: TextStyle(
                                color: Theme.of(context).highlightColor),
                          )),
                        ],
                      )
                    : //SizedBox(height: 25),
                    widget.myNFT["isOffer"]
                        ? Row(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Direct offer for NTF: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).highlightColor),
                                ),
                              ),
                              SizedBox(width: 2),
                              Container(
                                  child: Text(
                                "Yes",
                                style: TextStyle(
                                    color: Theme.of(context).highlightColor),
                              )),
                            ],
                          )
                        : SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.myNFT["isOffer"] || isOffer
                        ? button(
                            Theme.of(context).buttonColor,
                            Theme.of(context).highlightColor,
                            widget.buttonRemoveOffer,
                            widget.functionRemoveOffer,
                            [widget.myNFT["token_id"]])
                        : widget.myNFT["isAuction"]
                            ? button(
                                Theme.of(context).buttonColor,
                                Theme.of(context).highlightColor,
                                widget.buttonRemoveAuction,
                                widget.functionRemoveAuction,
                                [widget.myNFT["token_id"]])
                            : Column(
                                children: [
                                  Row(children: [
                                    Container(
                                        height: 75,
                                        width: 120,
                                        child: inputField(
                                            ctx: context,
                                            controller: widget
                                                .sellpriceamountController,
                                            labelText:
                                                "Selling Price e.g. 1ETH",
                                            leftMargin: 0,
                                            topMargin: 0,
                                            rightMargin: 0,
                                            bottomMargin: 0,
                                            onChanged: (_) {
                                              setState(() {});
                                            },
                                            onSubmitted: (_) {
                                              setState(() {});
                                            })),
                                    button(
                                        Theme.of(context).buttonColor,
                                        Theme.of(context).highlightColor,
                                        "Start Offer",
                                        Provider.of<Contractinteraction>(
                                                context)
                                            .startOffer,
                                        [
                                          widget.myNFT["token_id"],
                                          widget.sellpriceamountController.text
                                        ])
                                  ]),
                                  button(
                                      Theme.of(context).buttonColor,
                                      Theme.of(context).highlightColor,
                                      widget.buttonStartAuction,
                                      widget.functionStartAuction,
                                      [widget.myNFT["tokenId"], "3"]),
                                ],
                              ),
                  ],
                ),
              ],
            ),
          ),
        ),
        back: Card(
            //shadowColor: Colors.grey,
            color: Theme.of(context).primaryColor,
            //elevation: 10,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "Pricehistory: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).highlightColor),
                  ),
                ),
                SizedBox(height: 15),
                widget.myNFT["priceHistory"].length != 0
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        child: LineChartWidget(
                            prices: widget.myNFT["priceHistory"]))
                    : Container(
                        child: Text("No Pricehistory for this NFT yet",
                            style: TextStyle(
                                color: Theme.of(context).highlightColor))),
              ],
            )));
  }
}
