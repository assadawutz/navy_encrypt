part of encryption_page;

class _EncryptionPageView
    extends WidgetView<EncryptionPage, _EncryptionPageController> {
  _EncryptionPageView(_EncryptionPageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingMessage>(
      builder: (context, loadingMessage, child) {
        return HeaderScaffold(
          showBackButton: true,
          showProgress: state.isLoading,
          progressMessage: loadingMessage.message,
          onResume: state._handleResume /* when resume from settings page */,
          header: EncryptDecryptHeader(
            imagePath: 'assets/images/ic_encrypt.png',
            title: Constants.encryptionPageTitle,
          ),
          body: SingleChildScrollView(
            child: MyContainer(
              //padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 32.0),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (Platform.isWindows)
                    EncryptDecryptHeader(
                      imagePath: 'assets/images/win/ic_encrypt_grey.png',
                      title: Constants.encryptionPageTitle,
                    ),
                  if (state._registerStatus == WatermarkRegisterStatus.initial)
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: MyButton(
                        label:
                            'ไปหน้าตั้งค่าเพื่อขอคีย์สำหรับการ\nใช้งานลายน้ำ และการเข้ารหัส',
                        width: 250.0,
                        onClick: state._handleClicktoSettingButton,
                      ),
                    ),
                  if (state._registerStatus ==
                      WatermarkRegisterStatus.waitForSecret)
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: MyButton(
                        label:
                            'ไปหน้าตั้งค่าเพื่อกรอกคีย์ที่ได้รับทางอีเมล\nสำหรับการใช้งานลายน้ำ และการเข้ารหัส',
                        width: 300.0,
                        onClick: state._handleClicktoSettingButton,
                      ),
                    ),
                  if (state._registerStatus ==
                      WatermarkRegisterStatus.registered)
                    Column(
                      children: [
                        FileDetails(filePath: state._toBeEncryptedFilePath),
                        const SizedBox(height: 20.0),
                        _buildWatermarkField(),
                        const SizedBox(height: 20.0),
                        _buildEncryptionFields(),
                        const SizedBox(height: 40.0),
                        MyButton(
                          label: 'ดำเนินการ',
                          rightIcon: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.black,
                              size: 18.0,
                            ),
                          ),
                          width: 180.0,
                          onClick: state._handleClickGoButton,
                        )
                      ],
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWatermarkField() {
    // print("state._toBeEncryptedFilePath  ${state._toBeEncryptedFilePath}");
    // print(p.basename(state._toBeEncryptedFilePath));
    // String name = p.basename(state._toBeEncryptedFilePath);
    // var values = p.basename(state._toBeEncryptedFilePath).split('.');
    // print("values = ${values.last}");
    return FutureBuilder(
      future: state._hasRegisteredWatermark(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // print("sssss ${snapshot.data}");
        // print("sssss ${state._canWatermarkThisFileType()}");
        return snapshot.hasData
            ? Column(
                children: [
                  MyFormField(
                    label: 'ลายน้ำ',
                    hint: 'ข้อความที่ต้องการใส่เป็นลายน้ำ',
                    multiline: true,
                    maxLength: 12,
                    controller: state._watermarkEditingController,
                    enabled: snapshot.data && state._canWatermarkThisFileType(),
                  ),
                  if (!(snapshot.data && state._canWatermarkThisFileType()))
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          if (!state._canWatermarkThisFileType())
                            Text(
                              'ไม่สามารถใส่ลายน้ำให้กับไฟล์ประเภทนี้ (${state._fileExtension.toUpperCase()})',
                              style: TextStyle(
                                  fontSize: 19.0, color: Color(0xFFB40C0C)),
                            ),
                          if (!snapshot.data &&
                              state._canWatermarkThisFileType())
                            Text(
                              'ลงทะเบียนเพื่อเปิดใช้งานระบบลายน้ำในหน้า \'ตั้งค่า\'',
                              style: TextStyle(
                                  fontSize: 19.0, color: Color(0xFFB40C0C)),
                            ),
                          if (!snapshot.data &&
                              state._canWatermarkThisFileType())
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(Icons.settings_outlined, size: 20.0),
                            ),
                        ],
                      ),
                    ),
                ],
              )
            : SizedBox.shrink();
      },
    );
  }

  Widget _buildEncryptionFields() {
    return Column(
      children: [
        MyFormField(
          label: 'การเข้ารหัส',
          /*rightIcon:
                      Icon(Icons.keyboard_arrow_down, color: Color(0xFFA7A7A7)),*/
          child: DropdownButton<BaseAlgorithm>(
            isExpanded: true,
            //iconSize: 24.0,
            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFA7A7A7)),
            focusColor: Colors.white,
            value: state._algorithm,
            //elevation: 5,
            style: TextStyle(color: Colors.white),
            iconEnabledColor: Colors.black,
            underline: SizedBox.shrink(),
            items:
                Navec.algorithms.map<DropdownMenuItem<BaseAlgorithm>>((algo) {
              return DropdownMenuItem(
                value: algo,
                child: Text(
                  algo.text,
                  style: TextStyle(
                    fontFamily: 'DBHeavent',
                    color: Color(0xFF222222),
                    fontSize: 20.0,
                  ),
                ),
              );
            }).toList(),
            hint: Text(
              'กำหนดรหัสผ่านที่ต้องการ',
              style: TextStyle(
                color: Color(0xFFC0C0C0),
                fontSize: 20.0,
                fontFamily: 'DBHeavent',
              ),
            ),
            onChanged: state._handleChangeAlgorithm,
          ),
        ),
        MyFormField(
          enabled: state._algorithm.code != Navec.notEncryptCode,
          maxLength: state._algorithm.keyLengthInBytes,
          hint: 'กำหนดรหัสผ่านที่ต้องการ',
          //rightIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFA7A7A7)),
          controller: state._passwordEditingController,
          inputFormatters: [
            LengthLimitingTextInputFormatter(16),
          ],
          obscureText: !state._passwordVisible,
          rightIcon: Icon(
            state._passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Color(0xFFA7A7A7),
            size: 20.0,
          ),
          onClickRightIcon: state._handleClickPasswordEye,
        ),
        MyFormField(
          enabled: state._algorithm.code != Navec.notEncryptCode,
          maxLength: state._algorithm.keyLengthInBytes,
          hint: 'ยืนยันรหัสผ่านที่ต้องการ',
          //rightIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFA7A7A7)),
          controller: state._confirmPasswordEditingController,
          inputFormatters: [
            LengthLimitingTextInputFormatter(16),
          ],
          obscureText: !state._confirmPasswordVisible,
          rightIcon: Icon(
            state._passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Color(0xFFA7A7A7),
            size: 20.0,
          ),
          onClickRightIcon: state._handleClickConfirmPasswordEye,
        ),
      ],
    );
  }
}
