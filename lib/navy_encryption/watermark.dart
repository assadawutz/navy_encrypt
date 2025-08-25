import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:archive/archive_io.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/models/loading_message.dart';
import 'package:navy_encrypt/pages/settings/settings_page.dart';
import 'package:navy_encrypt/storage/prefs.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../etc/file_util.dart';

class Watermark {
  final String message;
  final String email;
  final String signatureCode;

  Watermark({
    @required this.message,
    @required this.email,
    @required this.signatureCode,
  });

  static Future<WatermarkRegisterStatus> getRegisterStatus() async {
    var email = await MyPrefs.getEmail();
    var secret = await MyPrefs.getSecret();

    if (email == null && secret == null) {
      return WatermarkRegisterStatus.initial;
    } else
      return WatermarkRegisterStatus.registered;
  }

  static Future<void> logout() async {
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    await MyPrefs.setEmail(null);
    await MyPrefs.setSecret(null);
    await googleSignIn.signOut();
  }

  Future<File> convertDocumentToImage(
      BuildContext context, String docFilePath) async {
    Provider.of<LoadingMessage>(context, listen: false)
        .setMessage('กำลังแปลงเอกสารเป็นรูปภาพ');

    final oldFileBaseName = p.basenameWithoutExtension(docFilePath);
    print("oldFileBaseName ${oldFileBaseName}");
    var docFile = File(docFilePath);
    print("docFile ${docFile}");

    var stream =
        new http.ByteStream(DelegatingStream.typed(docFile.openRead()));
    var length = await docFile.length(); // file length

    var mimeType = lookupMimeType(docFile.path); // mime type

    // string to uri
    var uri = Uri.parse(Constants.API_CONVERT_DOC_TO_IMAGE_URL);
    print(
        "API_CONVERT_DOC_TO_IMAGE_URL ${Constants.API_CONVERT_DOC_TO_IMAGE_URL}");
    // create multipart request
    var request = http.MultipartRequest('POST', uri);

    // multipart that takes file
    var multipartFileSign = http.MultipartFile(
      'file',
      stream,
      length,
      filename: basename(docFile.path),
      contentType: MediaType.parse(mimeType),
    );

    // add file to multipart
    request.files.add(multipartFileSign);

    //add headers
    //request.headers.addAll(headers);

    //adding params
    /*request.fields['loginId'] = '12';
  request.fields['firstName'] = 'abc';
  request.fields['lastName'] = 'efg';*/

    // send
    var response = await request.send();
    print("resp ${multipartFileSign.length}");
    print("resp ${multipartFileSign.contentType}");
    print("resp ${multipartFileSign.field}");
    print("resp ${multipartFileSign.filename}");
    print("resp ${request.files[0]}");
    // _handleResponse(response);

    Map<String, dynamic> logMap = {
      'URL': uri.toString(),
      'Uploaded file\'s mime type': mimeType,
      'Status code': response.statusCode,
      'Content length': response.contentLength,
    };
    logWithBorder(logMap, 1);

    var bytes = await response.stream.toBytes();
    var uniqueTempDirPath = (await FileUtil.createUniqueTempDir()).path;
    File file = new File('$uniqueTempDirPath/images.zip');
    file.writeAsBytesSync(bytes);

    FileUtil.unzip(dirPath: uniqueTempDirPath, filename: 'images.zip');
    return await _addWatermarkDir(
      context,
      uniqueTempDirPath,
      oldFileBaseName,
    ); // output zip file
  }

  dynamic _handleResponse(http.StreamedResponse response) {
    switch (response.statusCode) {
      case 200:
        break;
      default:
        throw Exception(
            'เกิดข้อผิดพลาดในการแปลงเอกสารเป็นรูปภาพ (status code: ${response.statusCode})');
    }
  }

  Future<File> _addWatermarkDir(
    BuildContext context,
    String dirPath,
    String oldFileBaseName,
  ) async {
    Provider.of<LoadingMessage>(context, listen: false)
        .setMessage('กำลังวาดลายน้ำลงในรูปภาพ');

    var fileList = Directory('$dirPath/images/').listSync();

    Map<String, dynamic> logMap = {};
    var count = 0;
    finishCount = 0;

    List<Future<File>> futureFileList = [];

    fileList.forEach((file) {
      logMap['${++count}'] = file.path;
      futureFileList.add(
        addWatermark(
          context,
          file.path,
          total: fileList.length,
        ),
      );
    });
    logWithBorder(logMap, 1);

    // รอใส่ลายน้ำให้เสร็จทุกไฟล์ก่อน แล้วค่อย zip
    List<File> watermarkedFileList = await Future.wait(futureFileList);

    if (watermarkedFileList.length > 1) {
      var encoder = ZipFileEncoder();
      encoder.zipDirectory(
        Directory('$dirPath/images/'),
        filename: '$dirPath/$oldFileBaseName.zip',
      );

      return File('$dirPath/$oldFileBaseName.zip');
    } else {
      final filePath = watermarkedFileList[0].path;
      final newFilePath = p.join(
        p.dirname(filePath),
        '$oldFileBaseName${p.extension(filePath)}',
      );
      return watermarkedFileList[0].renameSync(newFilePath);
    }
  }

  int finishCount;

  Future<Image> convertFileToImage(File picture) async {
    List<int> imageBase64 = picture.readAsBytesSync();
    String imageAsString = base64Encode(imageBase64);
    Uint8List uint8list = base64.decode(imageAsString);
    Image image = Image.memory(uint8list);
    print("convertFileToImage ${image}");
    return image;
  }

  Future<File> addWatermark(
    BuildContext context,
    String filePath, {
    int total,
  }) async {
    // convert img.Image to ui.Image
    final image = await _createImageFromBytes(
      Uint8List.fromList(await compute(resizeAndEncodeJpg, filePath)),
    );
    final waveImage = await _loadImageFromAsset('assets/images/bg_wave_4.jpg');

    // แปลง ByteData เป็น base64
    /*final waveImageByteData = await waveImage.toByteData();
    Uint8List waveImageUint8List = waveImageByteData.buffer.asUint8List(
        waveImageByteData.offsetInBytes, waveImageByteData.lengthInBytes);
    List<int> waveImageIntList = waveImageUint8List.cast<int>();
    final waveImageBase64 = base64Encode(waveImageIntList);*/

    /*final picture = await compute(drawWatermark, {
      'message': message,
      'email': email,
      'signatureCode': signatureCode,
    });*/
    final picture = drawWatermark({
      'message': message,
      'email': email,
      'signatureCode': signatureCode,
      'image': image,
      'waveImage': waveImage,
    });

    ByteData data = await (await picture.toImage(image.width, image.height))
        .toByteData(format: ui.ImageByteFormat.png);

    Provider.of<LoadingMessage>(context, listen: false)
        .setMessage('กำลังวาดลายน้ำลงในรูปภาพ ${++finishCount}/$total');

    return _convertToJpgAndWriteToFile(data, filePath);
  }

  Future<ui.Image> _createImageFromBytes(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<ui.Image> _loadImageFromAsset(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<ui.Image> _loadImageFromFile(String filePath) async {
    final file = File(filePath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(file.readAsBytesSync(), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  /*Future<ui.Image> _loadImageFromAsset(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }*/

  File _convertToJpgAndWriteToFile(ByteData data, String path) {
    /*// Read a jpeg image from file.
    img.Image image = img.decodeJpg(File('test.jpg').readAsBytesSync());

    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    img.Image thumbnail = img.copyResize(image, width: 120);

    // Save the thumbnail as a PNG.
    File('out/thumbnail-test.png').writeAsBytesSync(img.encodePng(thumbnail));*/

    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    img.Image image = img.decodePng(bytes);

    final outFile =
        File('${p.dirname(path)}/${p.basenameWithoutExtension(path)}.jpg');
    outFile.writeAsBytesSync(img.encodeJpg(image, quality: 75));

    return outFile;
  }

/*void drawImageOntoCanvas(String filePath) {
    img.Image srcImage = img.decodeJpg(File(filePath).readAsBytesSync());
    img.Image waterMarkImage = img.Image(srcImage.width, srcImage.height);

    // Create an srcImage
    //img.Image srcImage = img.Image(320, 240);

    // Fill it with a solid color (blue)
    //img.fill(srcImage, img.getColor(0, 0, 255));

    // Draw some text using 24pt arial font
    img.drawString(
      waterMarkImage,
      img.arial_48,
      0,
      0,
      'Hello World สวัสดีโลก',
      color: img.getColor(0, 0, 0, 80),
    );

    img.drawImage(srcImage, waterMarkImage);

    // Draw a line
    img.drawLine(
      srcImage,
      0,
      0,
      srcImage.width,
      srcImage.height,
      img.getColor(255, 0, 0),
      thickness: 10,
    );

    // Blur the srcImage
    //img.gaussianBlur(srcImage, 10);

    // Save the srcImage to disk as a PNG
    File('$filePath').writeAsBytesSync(img.encodeJpg(srcImage, quality: 80));
  }*/
}

/*img.Image copyResizeImage(Map<String, dynamic> map) {
  return img.copyResize(
    map['image'],
    width: map['width'],
    height: map['height'],
  );
}*/

List<int> resizeAndEncodeJpg(String filePath) {
  final imageMaxSize = Platform.isWindows ? 2400 : 1200;

  // read image data from file and resize, using Image library (img namespace)
  var imgImage = img.decodeImage(File(filePath).readAsBytesSync());
  print(
      'IMAGE OLD WIDTH: ${imgImage.width}, IMAGE OLD HEIGHT: ${imgImage.height}');

  if (imgImage.width > imgImage.height && imgImage.width > imageMaxSize) {
    imgImage = img.copyResize(imgImage, width: imageMaxSize);
  } else if (imgImage.height > imgImage.width &&
      imgImage.height > imageMaxSize) {
    imgImage = img.copyResize(imgImage, height: imageMaxSize);
  }

  print(
      'IMAGE NEW WIDTH: ${imgImage.width}, IMAGE NEW HEIGHT: ${imgImage.height}');

  return img.encodeJpg(imgImage, quality: 100);
}

ui.Picture drawWatermark(Map<String, dynamic> map) {
  final message = map['message'] as String;
  final email = map['email'] as String;
  final signatureCode = map['signatureCode'] as String;
  final image = map['image'] as ui.Image;
  final waveImage = map['waveImage'] as ui.Image;

  //var image = await _loadImageFromFile(filePath);
  var width = image.width, height = image.height;

  ui.PictureRecorder recorder = new ui.PictureRecorder();
  Canvas canvas = new Canvas(recorder);

  canvas.drawImage(image, Offset(0.0, 0.0), Paint()..color = Colors.black);

  canvas.save();
  //canvas.translate(width / 2, height / 2);
  canvas.rotate(-3.14159 / 6.0);
  //canvas.translate(-width / 2, -height / 2);

  var tpBlack = getTextPainter(message, 36.0, Colors.black.withOpacity(0.1));
  var tpWhite = getTextPainter(message, 36.0, Colors.white.withOpacity(0.1));

  var code = signatureCode;
  // .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)}")
  // .substring(1);
  var tpSignatureCodeBlack =
      getTextPainter(code, 18.0, Colors.black.withOpacity(0.125));
  var tpSignatureCodeWhite =
      getTextPainter(code, 18.0, Colors.white.withOpacity(0.125));

  const VERTICAL_SPACE = 100;
  const HORIZONTAL_SPACE = 100;
  const START_X = -1500;
  var startX = START_X;
  var count = 0;
  for (var y = -100;
      y < height + 500;
      y += (tpBlack.height.round() + VERTICAL_SPACE)) {
    startX += 100;
    if (startX > -1000) startX = START_X;
    for (var x = startX;
        x < width + 100;
        x += (tpBlack.width.round() + HORIZONTAL_SPACE)) {
      //var tp = count++ % 2 == 0 ? tp1 : tp2;
      //tpWhite.paint(canvas, Offset(x.toDouble() + 3.0, y.toDouble() + 3.0));
      tpBlack.paint(canvas, Offset(x.toDouble(), y.toDouble()));

      if (count++ % 2 == 0) {
        tpSignatureCodeWhite.paint(
            canvas, Offset(x.toDouble(), y.toDouble() + tpBlack.height));
      } else {
        tpSignatureCodeBlack.paint(
            canvas, Offset(x.toDouble(), y.toDouble() + tpBlack.height));
      }
    }
  }

  /*tp.paint(canvas, new Offset(0.0, 0.0));
  tp.paint(canvas, new Offset(tp.width, 0.0));
  tp.paint(canvas, new Offset(2 * tp.width, 0.0));
  tp.paint(canvas, new Offset(3 * tp.width, 0.0));
  tp.paint(canvas, new Offset(0.0, height - tp.height));*/
  // optional, if you saved earlier
  canvas.restore();

  final waveRenderWidth = waveImage.width.toDouble();
  final waveRenderHeight = waveImage.height.toDouble();
  canvas.drawImageRect(
    waveImage,
    Rect.fromLTRB(
      0.0,
      0.0,
      waveImage.width.toDouble(),
      waveImage.height.toDouble(),
    ),
    Rect.fromLTRB(
      width - waveRenderWidth,
      height - waveRenderHeight,
      width.toDouble(),
      height.toDouble(),
    ),
    /*Offset(
        (width - waveImage.width).toDouble(),
        (height - waveImage.height).toDouble(),
      ),*/
    Paint()..color = Color.fromRGBO(0, 0, 0, 0.5),
  );
  /*var cp = CustomPaint(
      painter:
          ImageEditor(image: await loadUiImage('assets/images/bg_wave.png')),
    );*/

  var tp = TextPainter(
    text: TextSpan(
      text: signatureCode,
      style: TextStyle(
        fontSize: 40.0,
        color: Colors.white.withOpacity(0.5),
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  tp.layout();
  tp.paint(
    canvas,
    Offset(
      width - tp.width - (waveRenderWidth - tp.width) / 2,
      height - tp.height - (waveRenderHeight - tp.height) / 2,
    ),
  );

  tp = TextPainter(
    text: TextSpan(
      text: '$code\n$code',
      style: TextStyle(
        fontSize: 28.0,
        color: Colors.black.withOpacity(0.25),
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  tp.layout();
  tp.paint(
    canvas,
    Offset(
      width - tp.width - (waveRenderWidth - tp.width) / 2,
      height - tp.height - (waveRenderHeight - tp.height) / 2,
    ),
  );

  ui.Picture picture = recorder.endRecording();
  return picture;
}

TextPainter getTextPainter(String message, double fontSize, Color color) {
  TextSpan span = TextSpan(
    style: TextStyle(
      color: color,
      fontSize: fontSize,
    ),
    text: message,
  );
  var tp = TextPainter(text: span, textDirection: TextDirection.ltr);
  return tp..layout();
}

// ตัวแปร top-level เพื่อให้ isolate เข้าถึงได้
//ui.Image image, waveImage;
