import 'dart:convert';
import 'dart:js_util';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';
import 'package:web_app_template/provider/contractinteraction.dart';
import 'package:web_app_template/widgets/sidebar/sidebardesktop.dart';
import '/provider/loginprovider.dart';
import '/widgets/javascript_controller.dart';
import '../../widgets/sellingnft/sellingnftgridview.dart';

class AllOffersDesktopView extends StatefulWidget {
  @override
  _AllOffersDesktopViewState createState() => _AllOffersDesktopViewState();
}

class _AllOffersDesktopViewState extends State<AllOffersDesktopView> {
  ScrollController _scrollController = ScrollController();
  Future sellingNFTs;
  var txold;

  Future _getItemsForSale() async {
    var promise = getItemsForSale();
    var result = await promiseToFuture(promise);
    return (result);
  }

  Future _getPriceHistory(String _tokenId) async {
    var promise = getPriceHistory(_tokenId);
    var result = await promiseToFuture(promise);
    return (result);
  }

  Future _getNFTData() async {
    var items = await _getItemsForSale();
    var itemsdecoded = [];

    for (var i = 0; i < items.length; i++) {
      var forSaleItemsdecoded = json.decode(items[i]);
      var priceHistory = await _getPriceHistory(forSaleItemsdecoded["tokenId"]);
      forSaleItemsdecoded["priceHistory"] = priceHistory;
      itemsdecoded.add(forSaleItemsdecoded);
    }
    return (itemsdecoded);
  }

  @override
  void initState() {
    sellingNFTs = _getNFTData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginModel>(context).user;
    var tx = Provider.of<Contractinteraction>(context).tx;

    if (txold != tx) {
      setState(() {
        txold = tx;
        sellingNFTs = _getNFTData();
      });
    }
    return Row(
      children: [
        SidebarDesktop(2),
        Container(
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width - 150,
          child: user != null
              ? VsScrollbar(
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
                    future: sellingNFTs,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (snapshot.data.length == 0 ||
                            snapshot.data == null) {
                          return Center(
                            child: Text("No active Sellings",
                                style: TextStyle(
                                    color: Theme.of(context).highlightColor)),
                          );
                        } else {
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                    mainAxisExtent: 440,
                                    maxCrossAxisExtent: 405),
                            itemCount: snapshot.data.length,
                            itemBuilder: (ctx, idx) {
                              return SellingNFTGridView(
                                itemdata: snapshot.data[idx],
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
                )
              : Center(
                  child: Text("Please log in with Metamask",
                      style:
                          TextStyle(color: Theme.of(context).highlightColor))),
        ),
      ],
    );
  }
}
