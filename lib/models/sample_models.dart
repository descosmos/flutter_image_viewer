import 'image_model.dart';

List<ImageModel> sampleItems = <ImageModel>[
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "gallery_pic.jpg",
    path: "assets/gallery_pic.jpg",
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "large-image.jpg",
    path: "assets/large-image.jpg",
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "wide_gamut.jpg",
    path: "assets/wide_gamut.jpg",
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "hdr-normal.HEIC",
    path: "assets/HDR.HEIC",
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "hdr-real.HEIC",
    path: "assets/HDR.HEIC",
    isHDR: true,
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "neat.gif",
    path: "assets/neat.gif",
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "DisplayP3_pic.png",
    path: "assets/DisplayP3_pic.png",
  ),
  // ImageModel(
  //   id: DateTime.now().millisecondsSinceEpoch.toString(),
  //   title: "avif_pic.avif",
  //   path: "assets/avif_pic.avif",
  // ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "bmp_pic.bmp",
    path: "assets/bmp_pic.bmp",
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "webp_pic.webp",
    path: "assets/webp_pic.webp",
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "TIFF_1MB.tiff",
    path: "assets/file_example_TIFF_1MB.tiff",
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "ico_pic.ico",
    path: "assets/ico_pic.ico",
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "firefox_pic.svg",
    path: "assets/firefox_pic.svg",
    isSvg: true,
  ),
  ImageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "network.jpg",
    path: "https://oss-ata.alibaba.com/article/2023/11/c0043d04-ccd5-4aad-b950-a4850e55fb4f.jpg",
    isRemote: true,
  ),
];
