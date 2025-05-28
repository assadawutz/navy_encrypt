import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileSize {
  static const kilo = 1000;
  static const mega = kilo * kilo;
  static const giga = kilo * mega;

  final int _size;

  FileSize(this._size);

  factory FileSize.fromString(String sizeText) {
    if (sizeText == null) return null;

    var size = int.tryParse(sizeText.toString());
    return size != null ? FileSize(size) : null;
  }

  String getDisplayByteSize() {
    var formatter = NumberFormat('#,###,###');
    return formatter.format(_size);
  }

  /// A method returns a human readable string representing a file _size
  String getDisplaySize([int round = 2]) {
    /**
     * the optional parameter [round] specifies the number
     * of digits after comma/point (default is 2)
     */

    if (_size < kilo) {
      return '$_size B';
    }

    if (_size < kilo * kilo && _size % kilo == 0) {
      return '${(_size / kilo).toStringAsFixed(0)} kB';
    }

    if (_size < kilo * kilo) {
      return '${(_size / kilo).toStringAsFixed(round)} kB';
    }

    if (_size < kilo * kilo * kilo && _size % kilo == 0) {
      return '${(_size / (kilo * kilo)).toStringAsFixed(0)} MB';
    }

    if (_size < kilo * kilo * kilo) {
      return '${(_size / kilo / kilo).toStringAsFixed(round)} MB';
    }

    if (_size < kilo * kilo * kilo * kilo && _size % kilo == 0) {
      return '${(_size / (kilo * kilo * kilo)).toStringAsFixed(0)} GB';
    }

    if (_size < kilo * kilo * kilo * kilo) {
      return '${(_size / kilo / kilo / kilo).toStringAsFixed(round)} GB';
    }

    if (_size < kilo * kilo * kilo * kilo * kilo && _size % kilo == 0) {
      num r = _size / kilo / kilo / kilo / kilo;
      return '${r.toStringAsFixed(0)} TB';
    }

    if (_size < kilo * kilo * kilo * kilo * kilo) {
      num r = _size / kilo / kilo / kilo / kilo;
      return '${r.toStringAsFixed(round)} TB';
    }

    if (_size < kilo * kilo * kilo * kilo * kilo * kilo && _size % kilo == 0) {
      num r = _size / kilo / kilo / kilo / kilo / kilo;
      return '${r.toStringAsFixed(0)} PB';
    } else {
      num r = _size / kilo / kilo / kilo / kilo / kilo;
      return '${r.toStringAsFixed(round)} PB';
    }
  }

  Color getColor() {
    Color color;
    if (_size < 3 * mega) {
      color = Colors.greenAccent;
    } else if (_size < 10 * mega) {
      color = Colors.yellowAccent;
    } else if (_size < 50 * mega) {
      color = Colors.orangeAccent;
    } else if (_size < 100 * mega) {
      color = Colors.deepOrangeAccent;
    } else if (_size < 200 * mega) {
      color = Colors.red;
    } else {
      color = Colors.black;
    }
    return color;
  }
}
