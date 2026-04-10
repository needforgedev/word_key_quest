import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() async {
  final dir = Directory('lib');
  final assetsDir = Directory('assets/images');
  if (!await assetsDir.exists()) {
    await assetsDir.create(recursive: true);
  }

  final files = await dir.list(recursive: true).toList();
  final dartFiles = files.whereType<File>().where((f) => f.path.endsWith('.dart'));

  final urlRegex = RegExp(r"https://lh3\.googleusercontent\.com/aida-public/[A-Za-z0-9_-]+");

  int downloadedCount = 0;
  final httpClient = HttpClient();

  print('Scanning .dart files for aida-public temporary URLs...');

  for (final file in dartFiles) {
    String content = await file.readAsString();
    final matches = urlRegex.allMatches(content).toList();
    if (matches.isEmpty) continue;

    bool fileChanged = false;

    // Iterate backwards to avoid index shifting when replacing string chunks
    for (final match in matches.reversed) { 
      final url = match.group(0)!;
      final bytes = utf8.encode(url);
      final digest = md5.convert(bytes).toString().substring(0, 8);
      final filename = 'image_$digest.jpg';
      final fileAssetPath = 'assets/images/$filename';

      final assetFile = File(fileAssetPath);
      if (!await assetFile.exists()) {
        try {
          final request = await httpClient.getUrl(Uri.parse(url));
          final response = await request.close();
          if (response.statusCode == 200) {
            await response.pipe(assetFile.openWrite());
            downloadedCount++;
            print('Downloaded $filename successfully.');
          } else {
             print('Failed to download $url - Status code: ${response.statusCode}');
          }
        } catch (e) {
          print('Failed to download $url: $e');
        }
      }

      content = content.replaceRange(match.start, match.end, fileAssetPath);
      fileChanged = true;
    }

    if (fileChanged) {
      // Finally, swap Image.network builder for Image.asset
      content = content.replaceAll('Image.network', 'Image.asset');
      await file.writeAsString(content);
      print('Updated references in ${file.path}');
    }
  }

  httpClient.close();
  print('---');
  print('Complete! Total unique new assets downloaded: $downloadedCount');
}
