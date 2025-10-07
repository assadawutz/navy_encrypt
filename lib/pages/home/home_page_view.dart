part of home_page;

class _HomePageView extends WidgetView<HomePage, HomePageController> {
  _HomePageView(HomePageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    var width = screenWidth(context);
    var height = screenHeight(context);
    final menuActions = state.menuActions;

    return HeaderScaffold(
      showBackButton: false,
      showProgress: state.isLoading,
      header: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/ic_launcher.png', height: 70.0),
          //SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Column(
              children: [
                Text(
                  'ระบบรับส่งไฟล์',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DimensionUtil.isTallScreen(context) ? 34.0 : 28.0,
                    shadows: const [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(255, 60, 60, 60),
                      ),
                    ],
                  ),
                ),
                Text(
                  'SEND AND RECEIVE FILES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DimensionUtil.isTallScreen(context) ? 22.0 : 20.0,
                    height: 0.9,
                    fontWeight: FontWeight.w400,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(255, 60, 60, 60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      headerAssetPath: _getHeaderImageAsset(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (var i = 0; i < menuActions.length; i += 2)
            Row(
              children: [
                for (var j = i; j < i + 2 && j < menuActions.length; j++)
                  MenuItem(
                    text: menuActions[j].label,
                    image: menuActions[j].assetPath,
                    onClick: () => menuActions[j].onTap(context),
                  ),
              ],
            ),
          SizedBox(height: 20), // เผื่อ space ด้านล่าง
          FutureBuilder(
            future: state._getPackageInfo(),
            builder:
                (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
              if (snapshot.hasData) {
                final versionLabel = state.buildVersionLabel(snapshot.data);
                if (versionLabel.isEmpty) {
                  return SizedBox.shrink();
                }
                return Text(
                  versionLabel,
                  style: TextStyle(fontSize: 18.0),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  String _getHeaderImageAsset(BuildContext context) {
    double ratio = screenRatio(context);
    if (ratio >= 2.0) {
      return 'assets/images/bg_header_home_2.png';
    } else if (ratio >= 1.8) {
      return 'assets/images/bg_header_home_3.png';
    } else {
      return 'assets/images/bg_header_home_4.png';
    }
  }
}

class MenuItem extends StatelessWidget {
  final String image;
  final String text;
  final VoidCallback onClick;
  final double size;
  final double borderWidth;

  const MenuItem({
    Key key,
    @required this.image,
    @required this.text,
    @required this.onClick,
    this.size,
    this.borderWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onClick,
        highlightColor: Colors.lightBlueAccent.withOpacity(0.05),
        splashColor: Colors.lightBlueAccent.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size ??
                  (screenHeight(context) > 800 ||
                          Platform.isWindows ||
                          Platform.isMacOS
                      ? 100.0
                      : 80.0),
              height: size ??
                  (screenHeight(context) > 800 ||
                          Platform.isWindows ||
                          Platform.isMacOS
                      ? 100.0
                      : 80.0),
              decoration: BoxDecoration(
                color: Color(0xFFEFEFEF),
                shape: BoxShape.circle,
                border: Border.all(
                    width: borderWidth ?? 4.0, color: Color(0xFF3EC2FF)),
              ),
              child: Center(
                  child: Image.asset(image,
                      width: size != null
                          ? size / 2
                          : (screenHeight(context) > 800 ||
                                  Platform.isWindows ||
                                  Platform.isMacOS
                              ? 42.5
                              : 40.0))),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize:
                      Platform.isWindows || Platform.isMacOS ? 24.0 : 22.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
