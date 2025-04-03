import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class BlueThermalPrinter {
  // Existing constants and basic setup
  static const int STATE_OFF = 10;
  static const int STATE_TURNING_ON = 11;
  static const int STATE_ON = 12;
  static const int STATE_TURNING_OFF = 13;
  static const int STATE_BLE_TURNING_ON = 14;
  static const int STATE_BLE_ON = 15;
  static const int STATE_BLE_TURNING_OFF = 16;
  static const int ERROR = -1;
  static const int CONNECTED = 1;
  static const int DISCONNECTED = 0;
  static const int DISCONNECT_REQUESTED = 2;

  static const String namespace = 'blue_thermal_printer';
  static const MethodChannel _channel = MethodChannel('$namespace/methods');
  static const EventChannel _readChannel = EventChannel('$namespace/read');
  static const EventChannel _stateChannel = EventChannel('$namespace/state');

  PaperSize _paperSize = PaperSize.mm58;
  FontType _defaultFont = FontType.small;

  // Singleton setup
  static final BlueThermalPrinter _instance = BlueThermalPrinter._();
  BlueThermalPrinter._();
  static BlueThermalPrinter get instance => _instance;

  // Stream controllers and existing methods
  final StreamController<MethodCall> _methodStreamController =
      StreamController.broadcast();
  Stream<int?> onStateChanged() async* {
    yield await _channel.invokeMethod('state').then((buffer) => buffer);

    yield* _stateChannel.receiveBroadcastStream().map((buffer) => buffer);
  }

  ///onRead()
  Stream<String> onRead() =>
      _readChannel.receiveBroadcastStream().map((buffer) => buffer.toString());

  Future<bool?> get isAvailable async =>
      await _channel.invokeMethod('isAvailable');

  Future<bool?> get isOn async => await _channel.invokeMethod('isOn');

  Future<bool?> get isConnected async =>
      await _channel.invokeMethod('isConnected');

  Future<bool?> get openSettings async =>
      await _channel.invokeMethod('openSettings');

  ///getBondedDevices()
  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List list = await (_channel.invokeMethod('getBondedDevices'));
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  Future<bool?> isDeviceConnected(BluetoothDevice device) =>
      _channel.invokeMethod('isDeviceConnected', device.toMap());
  Future<dynamic> connect(BluetoothDevice device) =>
      _channel.invokeMethod('connect', device.toMap());
  Future<dynamic> disconnect() => _channel.invokeMethod('disconnect');

  // New formatting features
  Future<dynamic> setPaperSize(PaperSize size) async {
    _paperSize = size;
    return _channel.invokeMethod('setPaperSize', {'size': size.value});
  }

  Future<dynamic> setDefaultFont(FontType font) async {
    _defaultFont = font;
    return _channel.invokeMethod('setDefaultFont', {'font': font.value});
  }

  // Enhanced print methods
  Future<dynamic> printRow(List<RowData> columns, {FontType? font}) async {
    final data = columns.map((col) => col.toMap()).toList();
    return _channel.invokeMethod('printRow', {
      'columns': data,
      'paperWidth': _paperSize.width,
      'font': (font ?? _defaultFont).value,
    });
  }

  Future<dynamic> printStyled(
    String text, {
    FontType? font,
    Align align = Align.left,
    bool bold = false,
    bool underline = false,
  }) async {
    return _channel.invokeMethod('printStyled', {
      'text': text,
      'font': (font ?? _defaultFont).value,
      'align': align.value,
      'bold': bold,
      'underline': underline,
    });
  }

  // Modified existing methods to use new font system
  Future<dynamic> printCustom(
    String message,
    FontType font,
    Align align, {
    String? charset,
  }) => _channel.invokeMethod('printCustom', {
    'message': message,
    'font': font.value,
    'align': align.value,
    'charset': charset,
  });

  ///printNewLine()
  Future<dynamic> printNewLine() => _channel.invokeMethod('printNewLine');

  ///paperCut()
  Future<dynamic> paperCut() => _channel.invokeMethod('paperCut');

  ///drawerPin5()
  Future<dynamic> drawerPin2() => _channel.invokeMethod('drawerPin2');

  ///drawerPin5()
  Future<dynamic> drawerPin5() => _channel.invokeMethod('drawerPin5');

  ///printImage(String pathImage)
  Future<dynamic> printImage(String pathImage) =>
      _channel.invokeMethod('printImage', {'pathImage': pathImage});

  ///printImageBytes(Uint8List bytes)
  Future<dynamic> printImageBytes(Uint8List bytes) =>
      _channel.invokeMethod('printImageBytes', {'bytes': bytes});

  ///printQRcode(String textToQR, int width, int height, int align)
  Future<dynamic> printQRcode(
    String textToQR,
    int width,
    int height,
    int align,
  ) => _channel.invokeMethod('printQRcode', {
    'textToQR': textToQR,
    'width': width,
    'height': height,
    'align': align,
  });

  ///printLeftRight(String string1, String string2, int size,{String? charset, String? format})
  Future<dynamic> printLeftRight(
    String string1,
    String string2,
    int size, {
    String? charset,
    String? format,
  }) => _channel.invokeMethod('printLeftRight', {
    'string1': string1,
    'string2': string2,
    'size': size,
    'charset': charset,
    'format': format,
  });

  ///print3Column(String string1, String string2, String string3, int size,{String? charset, String? format})
  Future<dynamic> print3Column(
    String string1,
    String string2,
    String string3,
    int size, {
    String? charset,
    String? format,
  }) => _channel.invokeMethod('print3Column', {
    'string1': string1,
    'string2': string2,
    'string3': string3,
    'size': size,
    'charset': charset,
    'format': format,
  });

  ///print4Column(String string1, String string2, String string3,String string4, int size,{String? charset, String? format})
  Future<dynamic> print4Column(
    String string1,
    String string2,
    String string3,
    String string4,
    int size, {
    String? charset,
    String? format,
  }) => _channel.invokeMethod('print4Column', {
    'string1': string1,
    'string2': string2,
    'string3': string3,
    'string4': string4,
    'size': size,
    'charset': charset,
    'format': format,
  });
}

class BluetoothDevice {
  final String? name;
  final String? address;
  final int type = 0;
  bool connected = false;

  BluetoothDevice(this.name, this.address);

  BluetoothDevice.fromMap(Map map)
    : name = map['name'],
      address = map['address'];

  Map<String, dynamic> toMap() => {
    'name': this.name,
    'address': this.address,
    'type': this.type,
    'connected': this.connected,
  };

  operator ==(Object other) {
    return other is BluetoothDevice && other.address == this.address;
  }

  @override
  int get hashCode => address.hashCode;
}

class RowData {
  final String text;
  final double widthRatio; // 0-1 for proportional width
  final Align align;

  RowData(this.text, {this.widthRatio = 1.0, this.align = Align.left});

  Map<String, dynamic> toMap() => {
    'text': text,
    'widthRatio': widthRatio,
    'align': align.value,
  };
}

enum Align {
  left(0),
  center(1),
  right(2);

  final int value;
  const Align(this.value);
}

enum FontType {
  small(0),    // 12x24
  medium(1),   // 16x32
  large(2);    // 24x48

  final int value;
  const FontType(this.value);
}

class PaperSize {
  final int value;
  final int width;
  const PaperSize._internal(this.value, this.width);

  static const mm58 = PaperSize._internal(1, 384);
  static const mm72 = PaperSize._internal(2, 512);
  static const mm80 = PaperSize._internal(3, 576);
}
