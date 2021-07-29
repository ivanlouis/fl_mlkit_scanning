# fl_mlkit_scanning

基于[Google ML Kit](https://developers.google.com/ml-kit/vision/barcode-scanning) 实现快速稳定扫码功能，支持Android \ IOS

ios 添加相机权限

```plist
	<key>NSCameraUsageDescription</key>
	<string>是否允许FlMlKitScanning使用你的相机？</string>
```

### 使用

- 预览

```dart

Widget build(BuildContext context) {
  bool backState = true;
  return FlMlKitScanning(

    /// 显示在预览上层
      overlay: const ScannerLine(),

      /// 是否全屏预览（由于原生相机预览为固定尺寸 设置全屏 会裁剪预览）
      isFullScreen: true,

      /// 闪光灯状态
      onFlashChange: (FlashState state) {
        showToast('闪光灯状态\n$state');
      },

      /// 相机未初始化时的UI
      uninitialized: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child:
          const Text('相机未初始化', style: TextStyle(color: Colors.white))),

      /// 二维码识别类型
      barcodeFormats: barcodeFormats,

      /// 扫码回调
      onListen: (List<BarcodeModel> barcodes) {
        if (backState && barcodes.isNotEmpty) {
          backState = false;
          pop(barcodes);
        }
      });
}

```

- 方法

```dart
void func() {
  /// 设置设别码类型
  FlMLKitScanningMethodCall.instance.setBarcodeFormat();

  /// 识别图片字节
  FlMLKitScanningMethodCall.instance.scanImageByte();

  /// 打开\关闭 闪光灯 
  FlMLKitScanningMethodCall.instance.setFlashMode();
}

```