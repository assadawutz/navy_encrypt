part of splash_page;

class _SplashPageView extends WidgetView<SplashPage, SplashPageController> {
  _SplashPageView(SplashPageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    print('>>> _SplashPageState build()');
    //print('>>>>>> sharedFileList: ${this.widget.sharedFileList}');

    return BackgroundScaffold(
      backgroundAssetPath: Platform.isWindows || Platform.isMacOS
          ? 'assets/images/win/bg_splash_land.jpg'
          : 'assets/images/bg_splash.jpg',
      child: GestureDetector(
        onTap: () {
          /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );*/
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Image(
                  image: AssetImage('assets/images/logo_navy_2.png'),
                  width: 140.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: Column(
                children: [
                  Text('กองทัพเรือ', style: TextStyle(fontSize: 46.0)),
                  Text(
                    'ROYAL THAI NAVY',
                    style: TextStyle(
                      fontSize: 34.0,
                      height: 0.8,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (Platform.isWindows || Platform.isMacOS)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: MyButton(
                            onClick: () {
                              state._goHome();
                            },
                            width: 150.0,
                            label: 'เข้าสู่ระบบรับส่งไฟล์',
                            backgroundColor: Color(0xFFE3D207),
                            textColor: Color(0xFF0A0A0A),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
