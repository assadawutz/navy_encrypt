part of home_page;

class _HomePageView extends WidgetView<HomePage, HomePageController> {
  _HomePageView(HomePageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    var width = screenWidth(context);
    var height = screenHeight(context);

    return HeaderScaffold(
      showBackButton: false,
      showProgress: state.isLoading,
      header: Column(
        // mainAxisSize: MainAxisSize.min,
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
                    shadows: [
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
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (var i = 0; i < state._menuData.length; i += 2)
                    Expanded(
                      child: Row(
                        children: [
                          for (var j = i; j < i + 2; j++)
                            MenuItem(
                              text: state._menuData[j]['text'],
                              image: state._menuData[j]['image'],
                              onClick: () {
                                state._menuData[j]['onClick'](context);
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: state._getPackageInfo(),
            builder:
                (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
              if (snapshot.hasData) {
                var packageInfo = snapshot.data;
                return Text(
                  'เวอร์ชัน 3.0.1+1',
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
  final Function onClick;
  final double size;
  final double borderWidth;

  MenuItem({this.image, this.text, this.onClick, this.size, this.borderWidth});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onClick,
        highlightColor: Colors.lightBlueAccent.withOpacity(0.05),
        splashColor: Colors.lightBlueAccent.withOpacity(0.1),
        child: Container(
          //color: Colors.yellow,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size ??
                    (screenHeight(context) > 800 || Platform.isWindows
                        ? 90.0
                        : 80.0),
                height: size ??
                    (screenHeight(context) > 800 || Platform.isWindows
                        ? 90.0
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
                            : (screenHeight(context) > 800 || Platform.isWindows
                                ? 42.5
                                : 40.0))),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: Platform.isWindows ? 22.0 : 22.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
