import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:js/js_util.dart';
import 'package:provider/provider.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';
import 'package:web_app_template/widgets/sidebar/sidebardesktop.dart';
import '/widgets/myBids/myBids.dart';
import '/provider/contractinteraction.dart';
import '/provider/loginprovider.dart';
import '../../widgets/mynfts/mynftgriddesktop.dart';
import '../../widgets/javascript_controller.dart';
import 'package:http/http.dart' as http;

class MyPortfolioDesktopView extends StatefulWidget {
  const MyPortfolioDesktopView({Key key}) : super(key: key);

  @override
  _MyPortfolioDesktopViewState createState() => _MyPortfolioDesktopViewState();
}

class _MyPortfolioDesktopViewState extends State<MyPortfolioDesktopView> {
  ScrollController _scrollController = ScrollController();
  Future myNFTs;
  Future myBids;
  Future balance;

  Future _getMyTokenBalance() async {
    var promise = getBalance();
    var result = await promiseToFuture(promise);
    return (result);
  }

  Future _getMyItems() async {
    var promise = getUserItems();
    var result = await promiseToFuture(promise);
    return (result);
  }

  Future _getMyBids() async {
    var promise = getMyBids();
    var mybids = await promiseToFuture(promise);
    var mybidsdecoded = [];
    for (var i = 0; i < mybids.length; i++) {
      var mybiddecoded = json.decode(mybids[i]);
      mybidsdecoded.add(mybiddecoded);
    }
    return mybidsdecoded;
  }

  Future _getNFTData() async {
    List<dynamic> _myNFTs = [];
    var myItems = await _getMyItems();

    for (var i = 0; i < myItems.length; i++) {
      var myItemdecoded = json.decode(myItems[i]);

      var promise0 = getPriceHistory(myItemdecoded["token_id"]);
      var prices = await promiseToFuture(promise0);

      myItemdecoded["priceHistory"] = prices;

      var promise1 = getAuctionItem(myItemdecoded["token_id"]);
      var auction = await promiseToFuture(promise1);

      auction == null
          ? myItemdecoded["isAuction"] = false
          : myItemdecoded["isAuction"] = true;

      var promise2 = getOfferItem(myItemdecoded["token_id"]);
      var offer = await promiseToFuture(promise2);

      offer == null
          ? myItemdecoded["isOffer"] = false
          : myItemdecoded["isOffer"] = true;

      var data = await http.get(Uri.parse(myItemdecoded["token_uri"]));
      var jsonData = json.decode(data.body);

      myItemdecoded["name"] = jsonData["name"];
      myItemdecoded["description"] = jsonData["description"];
      myItemdecoded["file"] = jsonData["file"];

      _myNFTs.add(myItemdecoded);
    }
    return (_myNFTs);
  }

  @override
  void initState() {
    myNFTs = _getNFTData();
    myBids = _getMyBids();
    balance = _getMyTokenBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginModel>(context).user;
    Provider.of<Contractinteraction>(context);
    return Row(
      children: [
        SidebarDesktop(3),
        user != null
            ? Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      //height: double.infinity,
                      width:
                          (MediaQuery.of(context).size.width - 150) * (2 / 3),
                      child: VsScrollbar(
                        controller: _scrollController,
                        showTrackOnHover: true,
                        isAlwaysShown: false,
                        scrollbarFadeDuration: Duration(milliseconds: 500),
                        scrollbarTimeToFade: Duration(milliseconds: 800),
                        style: VsScrollbarStyle(
                          hoverThickness: 10.0,
                          radius: Radius.circular(10),
                          thickness: 10.0,
                          color: Theme.of(context).highlightColor,
                        ),
                        child: FutureBuilder(
                            future: balance,
                            builder: (ctx, balancesnapshot) {
                              if (balancesnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return FutureBuilder(
                                  future: myNFTs,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container();
                                    } else {
                                      if (snapshot.data == null ||
                                          snapshot.data.length == 0) {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                "CollectorToken Balance: " +
                                                    balancesnapshot.data,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .highlightColor)),
                                            Text("No NFTs in your Portfolio",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .highlightColor)),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                "CollectorToken Balance: " +
                                                    balancesnapshot.data,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .highlightColor)),
                                            GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                                      crossAxisSpacing: 0,
                                                      mainAxisSpacing: 0,
                                                      mainAxisExtent: 560,
                                                      maxCrossAxisExtent: 500),
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (ctx, idx) {
                                                return MyNFTGridDesktopView(
                                                  myNFT: snapshot.data[idx],
                                                  buttonStartAuction:
                                                      "Start Auction",
                                                  functionStartAuction: Provider
                                                          .of<Contractinteraction>(
                                                              context)
                                                      .startAuction,
                                                  buttonRemoveAuction:
                                                      "Delete Auction",
                                                  functionRemoveAuction: Provider
                                                          .of<Contractinteraction>(
                                                              context)
                                                      .removeAuction1,
                                                  buttonStartOffer: "Sell NFT",
                                                  buttonRemoveOffer:
                                                      "Remove Offer",
                                                  functionRemoveOffer: Provider
                                                          .of<Contractinteraction>(
                                                              context)
                                                      .removeOffer1,
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                    }
                                  },
                                );
                              }
                            }),
                      )
                      //: Center(child: Text("No NFT Token in you Portfolio"))
                      ),
                  Container(
                    //height: double.infinity,
                    padding: EdgeInsets.all(10),
                    width: (MediaQuery.of(context).size.width - 150) * (1 / 3),
                    child: VsScrollbar(
                      controller: _scrollController,
                      showTrackOnHover: true,
                      isAlwaysShown: false,
                      scrollbarFadeDuration: Duration(milliseconds: 500),
                      scrollbarTimeToFade: Duration(milliseconds: 800),
                      style: VsScrollbarStyle(
                        hoverThickness: 10.0,
                        radius: Radius.circular(10),
                        thickness: 10.0,
                        color: Theme.of(context).highlightColor,
                      ),
                      child: FutureBuilder(
                        future: myBids,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            if (snapshot.data.length == 0 ||
                                snapshot.data == null) {
                              return Center(
                                  child: Text(
                                      "You have no Bids for NFT Auctions",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .highlightColor)));
                            } else {
                              return ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (ctx, idx) {
                                    return MyBidsList(
                                        mybid: snapshot.data[idx]);
                                  });
                            }
                          }
                        },
                      ),
                    ),
                  )
                ],
              )
            : Container(
                width: (MediaQuery.of(context).size.width - 150),
                child: Center(
                    child: Text("Please log in with Metamask",
                        style: TextStyle(
                            color: Theme.of(context).highlightColor)))),
      ],
    );
  }
}
