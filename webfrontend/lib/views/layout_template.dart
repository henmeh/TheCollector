import 'package:flutter/material.dart';
import 'package:web_app_template/responsive.dart';
import 'package:web_app_template/widgets/mobileview.dart';
import '../widgets/navbar/navbardesktop.dart';

class LayoutTemplate extends StatefulWidget {
  final Widget child;
  const LayoutTemplate({Key key, this.child}) : super(key: key);
  @override
  _LayoutTemplateState createState() => _LayoutTemplateState();
}

class _LayoutTemplateState extends State<LayoutTemplate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: Mobileview(child: widget.child),
        tablet: Mobileview(child: widget.child),
        desktop: Column(
          children: [
            Navbardesktop(),
            Expanded(
              child: Row(
                children: [Expanded(child: widget.child)],
              ),
            )
          ],
        ),
      ),
    );
  }
}
