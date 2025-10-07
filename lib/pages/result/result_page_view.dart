part of result_page;

class _ResultPageView extends WidgetView<ResultPage, _ResultPageController> {
  _ResultPageView(_ResultPageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    print("state._isEncFile ${state._isEncFile}");
    List<Map<String, dynamic>> buttonDataList = [
      {
        'label': 'บันทึก',
        'icon': Icon(Icons.save, size: 18.0),
        'onClick': state._handleClickSaveButton,
      },
      if (state._isEncFile == true && Platform.isWindows == false)
        {
          'label': 'เปิด',
          'icon': Icon(Icons.article_outlined, size: 18.0),
          'onClick': state._handleClickOpenButton,
        }
      else
        {
          'label': 'อนุญาต',
          'icon': Icon(Icons.contacts, size: 18.0),
          'onClick': state._pickEmailShare
        },
      if (state._isEncFile == true && Platform.isWindows == true)
        {
          'label': 'เปิด',
          'icon': Icon(Icons.article_outlined, size: 18.0),
          'onClick': state._handleClickOpenButton,
        }
      else
        {
          'label': 'แชร์',
          'icon': Icon(Icons.share, size: 18.0),
          'onClick': state._handleClickShareButton,
        },
      if (state._isEncFile == true)
        {
          'label': 'เข้ารหัส',
          'icon': Icon(Icons.enhanced_encryption_outlined, size: 18.0),
          'onClick': state._goEncryption,
        },
      {
        'label': 'พิมพ์',
        'icon': Icon(Icons.print, size: 18.0),
        'onClick': state._handlePrintingButton,
      },

      //   {
      //     'label': 'เปิด',
      //     'icon': Icon(Icons.article_outlined, size: 18.0),
      //     'onClick': state._handleClickOpenButton,
      //   },
      // // if (state._isEncFile)
      // {
      //   'label': 'บันทึก',
      //   'icon': Icon(Icons.save, size: 18.0),
      //   'onClick': state._handleClickSaveButton,
      // },
      // if (state._type == 'encryption')
      //   {
      //     'label': 'อนุญาต',
      //     'icon': Icon(Icons.contacts, size: 18.0),
      //     'onClick': state._pickEmailShare
      //   },
      // if (Platform.isWindows == true)
      //   {
      //     'label': 'เปิด',
      //     'icon': Icon(Icons.article_outlined, size: 18.0),
      //     'onClick': state._handleClickOpenButton,
      //   },
      //
    ];

    return HeaderScaffold(
        showBackButton: true,
        showProgress: state.isLoading,
        header: EncryptDecryptHeader(
          imagePath: 'assets/images/ic_encrypt.png',
          title: state._isEncFile
              ? Constants.encryptionPageTitle
              : Constants.decryptionPageTitle,
        ),
        body: SingleChildScrollView(
          child: MyContainer(
            //padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 32.0),
            child: Column(
              children: [
                if (false /*Platform.isWindows*/)
                  EncryptDecryptHeader(
                    imagePath: 'assets/images/win/ic_encrypt_grey.png',
                    title: state._isEncFile
                        ? Constants.encryptionPageTitle
                        : Constants.decryptionPageTitle,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset('assets/images/ic_success.png',
                      width: !Platform.isWindows ? 120.0 : 60.0),
                ),
                Text(
                  state._message,
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: !Platform.isWindows ? 16.0 : 8.0),
                FileDetails(filePath: state._processedFilePath),
                SizedBox(height: !Platform.isWindows ? 32.0 : 16.0),
                Column(
                  children: buttonDataList
                      .map((item) => Column(
                            children: [
                              MyButton(
                                label: item['label'],
                                rightIcon: item['icon'],
                                width: 180.0,
                                onClick: item['onClick'],
                              ),
                              SizedBox(height: 16.0),
                            ],
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ));
  }
}
