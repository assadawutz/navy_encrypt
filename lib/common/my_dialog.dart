import 'package:flutter/material.dart';
import 'package:navy_encrypt/etc/utils.dart';

class MyDialog extends StatelessWidget {
  final Widget headerImage;
  final Widget body;
  final EdgeInsets padding;

  const MyDialog({Key key, this.headerImage, this.body, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = screenWidth(context);
    //final height = screenHeight(context);

    return Center(
        child: SingleChildScrollView(
            child: Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      elevation: 0,
      insetPadding:
          EdgeInsets.symmetric(horizontal: _getHorizontalMargin(width)),
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    )));
  }

  double _getHorizontalMargin(double width) {
    double margin;
    if (width < 300) {
      margin = 10.0;
    } else if (width > 1000) {
      margin = 0.3 * width;
    } else {
      margin = 0.1 * width;
    }
    return margin;
  }

  _buildDialogContent(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: padding ??
              EdgeInsets.only(
                left: 16.0,
                top: headerImage == null ? 16.0 : 40.0,
                right: 16.0,
                bottom: 16.0,
              ),
          margin: EdgeInsets.only(top: 40.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, 8),
                blurRadius: 8,
              ),
            ],
          ),
          child: body,
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          child: Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(width: 4.0, color: Color(0xFF3EC2FF)),
            ),
            child: Center(
              child: headerImage,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildPickerDialog({
    Widget headerImage,
    Widget title,
    List<DialogTileData> items,
  }) {
    return MyDialog(
      headerImage: headerImage,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        /*child: Row(
          children: [imageChoice, videoChoice]
              .map(
                (e) => Expanded(
                  child: _buildDialogTile(
                    label: e.label,
                    image: e.image,
                    onClick: e.onClick,
                  ),
                ),
              )
              .toList(),
        ),*/
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            title,
            ...items
                .map(
                  (e) => _buildDialogTile(
                    label: e.label,
                    image: e.image,
                    onClick: e.onClick,
                  ),
                )
                .toList()
          ],
        ),
      ),
    );
  }

  static Widget _buildDialogTile(
      {String label, Widget image, Function onClick}) {
    return Material(
      color: Colors.transparent,
      /*child: InkWell(
        onTap: onClick,
        highlightColor: Colors.lightBlueAccent.withOpacity(0.05),
        splashColor: Colors.lightBlueAccent.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              image,
              SizedBox(width: 8.0),
              Text(label, style: TextStyle(fontSize: 20.0))
            ],
          ),
        ),
      ),*/
      child: InkWell(
        onTap: onClick,
        highlightColor: Colors.lightBlueAccent.withOpacity(0.05),
        splashColor: Colors.lightBlueAccent.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              image,
              SizedBox(width: 16.0),
              Text(label, style: TextStyle(fontSize: 20.0))
            ],
          ),
        ),
      ),
    );
  }
}

class DialogTileData {
  final String label;
  final Widget image;
  final Function onClick;

  DialogTileData({
    @required this.label,
    @required this.image,
    @required this.onClick,
  });
}
