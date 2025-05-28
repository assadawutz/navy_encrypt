part of settings_page;

class _SettingsPageView
    extends WidgetView<SettingsPage, _SettingsPageController> {
  _SettingsPageView(_SettingsPageController state) : super(state);

  @override
  Widget build(BuildContext context) {


    return HeaderScaffold(
      showBackButton: true,
      showSettingsButton: false,
      showProgress: state.isLoading,
      header: EncryptDecryptHeader(
        imagePath: 'assets/images/ic_setting_white.png',
        title: Constants.watermarkSettingsPageTitle,
      ),
      body: SingleChildScrollView(
        child: MyContainer(
          padding: const EdgeInsets.fromLTRB(32.0, 24.0, 32.0, 32.0),
          child: Column(
            children: [
              if (Platform.isWindows)
                EncryptDecryptHeader(
                  imagePath: 'assets/images/ic_setting.png',
                  title: Constants.watermarkSettingsPageTitle,
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/${state._registerStatus == WatermarkRegisterStatus.registered ? "ic_success.png" : "ic_key.png"}',
                  width: !Platform.isWindows ? 120.0 : 40.0,
                ),
              ),
              if (state._registerStatus == null) CircularProgressIndicator(),
              if (state._registerStatus == WatermarkRegisterStatus.registered)
                FutureBuilder(
                  future: MyPrefs.getEmail(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    var email = snapshot.hasData ? snapshot.data : '';

                    return Column(
                      children: [
                        Text(
                          'เปิดใช้งานระบบลายน้ำบนอุปกรณ์นี้แล้ว\n(อีเมล $email)',
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: !Platform.isWindows ? 24.0 : 12.0),
                        Container(
                          margin:
                              EdgeInsets.all(Platform.isWindows ? 16.0 : 0.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1.0, color: Colors.green),
                          ),
                          child: Text(
                            'เลขรหัสลายเซ็นดิจิตอล (Digital Signature) ของอีเมล $email จะถูกบันทึกลงในลายน้ำ ทุกครั้งที่มีการใส่ลายน้ำลงในรูปภาพ/เอกสารบนอุปกรณ์นี้',
                            style: TextStyle(
                                fontSize: 20.0, color: Color(0xFF319700)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: !Platform.isWindows ? 48.0 : 24.0),
                        MyButton(
                          label: 'ขอคีย์ใหม่',
                          width: 230.0,
                          backgroundColor: Colors.deepOrange,
                          onClick: state._handleClickLogoutButton,
                        )
                      ],
                    );
                  },
                ),
              if (state._registerStatus == WatermarkRegisterStatus.initial)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: MyButton(
                    label: 'ขอคีย์ สำหรับการใช้งานระบบลายน้ำ',
                    width: 250.0,
                    onClick: state._handleClickRequestKeyButton,
                  ),
                ),
              if (state._registerStatus ==
                  WatermarkRegisterStatus.waitForSecret)
                Column(
                  children: [
                    FutureBuilder(
                      future: MyPrefs.getEmail(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        var email = snapshot.hasData ? snapshot.data : '';

                        return MyFormField(
                          subLabel:
                              'กรอกคีย์ที่ได้รับทางอีเมล $email เพื่อเปิดใช้งานระบบลายน้ำบนอุปกรณ์นี้',
                          hint: 'คีย์ (Private Key)',
                          multiline: false,
                          controller: state._privateKeyEditingController,
                        );
                      },
                    ),
                    if (!Platform.isWindows)
                      Column(
                        children: [
                          SizedBox(height: 24.0),
                          MyButton(
                            label: 'ตกลง',
                            width: 150.0,
                            onClick: state._handleClickSaveButton,
                          ),
                          SizedBox(height: 12.0),
                          MyButton(
                            label: 'ยกเลิก',
                            width: 150.0,
                            isOutlinedButton: true,
                            onClick: state._handleClickCancelButton,
                          ),
                        ],
                      ),
                    if (Platform.isWindows)
                      Column(
                        children: [
                          SizedBox(height: 32.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyButton(
                                label: 'ตกลง',
                                width: 150.0,
                                onClick: state._handleClickSaveButton,
                              ),
                              SizedBox(width: 24.0),
                              MyButton(
                                label: 'ยกเลิก',
                                width: 150.0,
                                isOutlinedButton: true,
                                onClick: state._handleClickCancelButton,
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              SizedBox(height: !Platform.isWindows ? 32.0 : 16.0),
              InkWell(
                  child: new Text(
                    'คู่มือการใช้งาน',
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: state._handleLaunchManual),
            ],
          ),
        ),
      ),
    );
  }
}
