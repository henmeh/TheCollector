import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_app_template/providers/blockchain_interaction.dart';
import 'package:mobile_app_template/widgets/errorwindow.dart';
import 'package:mobile_app_template/widgets/mynftgridview.dart';
import 'package:mobile_app_template/widgets/showupwindow.dart';
import 'package:provider/provider.dart';
import '../providers/blockchain_wallet_interaction.dart';
import 'package:http/http.dart' as http;

class MyPortfolioScreen extends StatefulWidget {
  static const routeName = '/myportfolio';
  @override
  _MyPortfolioScreenState createState() => _MyPortfolioScreenState();
}

class _MyPortfolioScreenState extends State<MyPortfolioScreen> {
  String status = "";

  Future<void> refreshWallet() async {
    setState(() {});
    await Provider.of<BlockchainWalletInteraction>(context, listen: false)
        .getMyBalance();
  }

  Future _getMyNFTs() async {
    List<dynamic> nftData = [];
    List<dynamic> isAuction = [];
    List<dynamic> isOffer = [];

    Map myNFTData =
        await Provider.of<BlockchainInteraction>(context, listen: false)
            .getMyTokens();
    for (var i = 0; i < myNFTData[1].length; i++) {
      var data = await http.get(Uri.parse(myNFTData[2][i]));
      var jsonData = json.decode(data.body);
      nftData.add(jsonData);

      var auctiondata =
          await Provider.of<BlockchainInteraction>(context, listen: false)
              .getAuctionData(myNFTData[1][i].toString());
      isAuction.add(auctiondata[0]);

      var offerdata =
          await Provider.of<BlockchainInteraction>(context, listen: false)
              .getOfferData(myNFTData[1][i].toString());
      isOffer.add(offerdata[0]);
    }

    Map<String, dynamic> nftvalues = {
      "tokenId": myNFTData[1],
      "isAuction": isAuction,
      "isOffer": isOffer,
      "tokenData": nftData,
    };
    return nftvalues;
  }

  Future _startAuction(List _arguments) async {
    //setState(() {
    //  status = "pending";
    //  print(status);
    //});
    String _tokenId = _arguments[0];
    String _duration = _arguments[1];
    //await Provider.of<BlockchainInteraction>(context, listen: false)
    //    .startAuction(_tokenId, _duration);
    await showUpWindow(
        context,
        BlockchainInteraction().startAuction(_tokenId, _duration),
        "Starting NFT Auction",
        "Your transaction is pending. You can look at it on Etherscan");
    setState(() {
      //status = "";
      //print(status);
    });
  }

  Future _removeAuction(List _arguments) async {
    String _tokenId = _arguments[0];
    //await Provider.of<BlockchainInteraction>(context, listen: false)
    //    .removeAuction(_tokenId);
    await showUpWindow(
        context,
        BlockchainInteraction().removeAuction(_tokenId),
        "Removeing NFT from Auction",
        "Your transaction is pending. You can look at it on Etherscan");
    setState(() {});
  }

  Future _removeOffer(List _arguments) async {
    String _tokenId = _arguments[0];
    //await Provider.of<BlockchainInteraction>(context, listen: false)
    //    .removeOffer(_tokenId);
    //setState(() {});
    await showUpWindow(
        context,
        BlockchainInteraction().removeOffer(_tokenId),
        "Removeing Offer for NFT",
        "Your transaction is pending. You can look at it on Etherscan");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: () => refreshWallet(),
          child: Column(
            children: [
              FutureBuilder(
                future: Provider.of<BlockchainWalletInteraction>(context,
                        listen: false)
                    .getMyOwnAddress()
                    .catchError(
                      (error) => errorWindow(
                          ctx: context,
                          title: "An error occured",
                          content: error.message),
                    ),
                builder: (ctx, datasnapshot) => Column(
                  children: [
                    Center(
                      child: Container(
                        child: Text("My Account",
                            style: Theme.of(context).textTheme.headline4),
                      ),
                    ),
                    Center(
                      child: Container(
                        child: Text(
                          datasnapshot.data.toString(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder(
                future: Provider.of<BlockchainWalletInteraction>(context,
                        listen: false)
                    .getMyBalance()
                    .catchError(
                      (error) => errorWindow(
                          ctx: context,
                          title: "An error occured",
                          content: error.message),
                    ),
                builder: (ctx, response) {
                  if (response.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Column(
                      children: [
                        Center(
                          child: Text("My Ether Balance",
                              style: Theme.of(context).textTheme.headline4),
                        ),
                        Center(
                          child:
                              Text(response.data.toStringAsFixed(4) + " Eth"),
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width / 1.3,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Container(
                  child: Text("My TheCollector Tokens",
                      style: Theme.of(context).textTheme.headline4),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 262,
                child: FutureBuilder(
                  future: _getMyNFTs(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      {
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                  mainAxisExtent: 400,
                                  maxCrossAxisExtent: double.maxFinite),
                          itemCount: snapshot.data["tokenId"].length,
                          itemBuilder: (ctx, idx) {
                            return MyNFTGridView(
                                id: snapshot.data["tokenId"][idx].toString(),
                                name: snapshot.data["tokenData"][idx]["name"],
                                description: snapshot.data["tokenData"][idx]
                                    ["description"],
                                isAuction: snapshot.data["isAuction"][idx],
                                isOffer: snapshot.data["isOffer"][idx],
                                image: snapshot.data["tokenData"][idx]["file"],
                                buttonStartAuction: "Start Auction",
                                functionStartAuction: _startAuction,
                                buttonRemoveAuction: "Delete Auction",
                                functionRemoveAuction: _removeAuction,
                                buttonStartOffer: "Sell NFT",
                                buttonRemoveOffer: "Remove Offer",
                                functionRemoveOffer: _removeOffer);
                          },
                        );
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
