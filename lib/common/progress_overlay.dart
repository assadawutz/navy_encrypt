import 'package:flutter/material.dart';

class ProgressOverlay extends StatelessWidget {
  final String progressMessage;
  final double progressValue;

  const ProgressOverlay({Key key, this.progressMessage, this.progressValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: progressValue,
                color: Colors.white.withOpacity(0.75),
              ),
              if (progressMessage.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    progressMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 20.0,
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
