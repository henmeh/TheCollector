import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/widgets/useravatar.dart';
import '../../provider/contractinteraction.dart';
import '../../provider/loginprovider.dart';
import '../button.dart';

class Navbardesktop extends StatefulWidget {
  @override
  _NavbardesktopState createState() => _NavbardesktopState();
}

class _NavbardesktopState extends State<Navbardesktop> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginModel>(context).user;
    final image = Provider.of<LoginModel>(context).image;
    print(image.runtimeType);
    final tx = Provider.of<Contractinteraction>(context).tx;
    print(user);
    return Container(
      height: 75,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "The Collector",
            style: TextStyle(
                color: Theme.of(context).highlightColor, fontSize: 30),
          ),
          user != null
              ? Row(
                  children: [
                    Column(
                      children: [
                        Container(),
                        Container(
                          width: 200,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Your latest Transaction",
                            style: TextStyle(
                                color: Theme.of(context).highlightColor),
                          ),
                        ),
                        tx != null
                            ? Flexible(
                                child: Container(
                                    width: 200,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: tx == "true"
                                        ? Text("successful",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .highlightColor,
                                                fontSize: 10))
                                        : tx == "pending"
                                            ? Text("pending",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .highlightColor,
                                                    fontSize: 10))
                                            : Text("error",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .highlightColor,
                                                    fontSize: 10))),
                              )
                            : Container(
                                width: 200,
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Text("No Transaction",
                                    style: TextStyle(
                                        color: Theme.of(context).highlightColor,
                                        fontSize: 10))),
                      ],
                    ),
                    //Useravatar(image),
                    Container(
                      child: Text(
                        user.toString(),
                        style: TextStyle(
                            color: Theme.of(context).highlightColor,
                            fontSize: 15),
                      ),
                    ),
                    button(
                        Theme.of(context).buttonColor,
                        Theme.of(context).highlightColor,
                        "LogOut",
                        Provider.of<LoginModel>(context).logOut)
                  ],
                )
              : button(
                  Theme.of(context).buttonColor,
                  Theme.of(context).highlightColor,
                  "LogIn",
                  Provider.of<LoginModel>(context).logIn),
        ],
      ),
    );
  }
}
