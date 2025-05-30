// import 'package:flutter/material.dart';
// import 'dart:async';
//
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key key}) : super(key: key);
//
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   StreamSubscription _intentDataStreamSubscription;
//   List<SharedMediaFile> _sharedFiles;
//   String _sharedText;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // For sharing images coming from outside the app while the app is in the memory
//     _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
//         .listen((List<SharedMediaFile> value) {
//       setState(() {
//         _sharedFiles = value;
//         debugPrint(
//             "Shared:" + (_sharedFiles.map((f) => f.path).join(",") ?? ""));
//       });
//     }, onError: (err) {
//       debugPrint("getIntentDataStream error: $err");
//     });
//
//     // For sharing images coming from outside the app while the app is closed
//     ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
//       setState(() {
//         _sharedFiles = value;
//         debugPrint(
//             "Shared:" + (_sharedFiles.map((f) => f.path).join(",") ?? ""));
//       });
//     });
//
//     // For sharing or opening urls/text coming from outside the app while the app is in the memory
//     _intentDataStreamSubscription =
//         ReceiveSharingIntent.getTextStream().listen((String value) {
//       setState(() {
//         _sharedText = value;
//         debugPrint("Shared: $_sharedText");
//       });
//     }, onError: (err) {
//       debugPrint("getLinkStream error: $err");
//     });
//
//     // For sharing or opening urls/text coming from outside the app while the app is closed
//     ReceiveSharingIntent.getInitialText().then((String value) {
//       setState(() {
//         _sharedText = value;
//         debugPrint("Shared: $_sharedText");
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _intentDataStreamSubscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const textStyleBold = TextStyle(fontWeight: FontWeight.bold);
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('รับส่งไฟล์'),
//         ),
//         body: Center(
//           child: Column(
//             children: <Widget>[
//               const Text("Shared files:", style: textStyleBold),
//               Text(_sharedFiles
//                       .map((f) =>
//                           "{Path: ${f.path}, Type: ${f.type.toString().replaceFirst("SharedMediaType.", "")}}\n")
//                       .join(",\n") ??
//                   ""),
//               const SizedBox(height: 100),
//               const Text("Shared urls/text:", style: textStyleBold),
//               Text(_sharedText ?? "")
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
