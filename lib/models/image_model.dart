import 'dart:io';

class ImageModel {
  ImageModel(
      {required this.id,
      required this.title,
      required this.path,
      this.isSvg,
      this.isHDR,
      this.isRemote,
      this.file});

  final String id;
  final String title;
  final String path;
  final File? file;
  final bool? isSvg;
  final bool? isHDR;
  final bool? isRemote;

  ImageModel copyWith({
    String? id,
    String? title,
    String? path,
    File? file,
    bool? isSvg,
    bool? isHDR,
    bool? isRemote
  }) {
    return ImageModel(
        id: id ?? this.id,
        title: title ?? this.title,
        path: path ?? this.path,
        file: file ?? this.file,
        isSvg: isSvg ?? this.isSvg,
        isHDR: isHDR ?? this.isHDR,
        isRemote: isRemote ?? this.isRemote);
  }
}
