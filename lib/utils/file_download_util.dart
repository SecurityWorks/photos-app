import 'dart:io' as io;
import 'dart:typed_data';

import "package:computer/computer.dart";
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/network/network.dart';
import 'package:photos/models/file.dart' as ente;
import 'package:photos/services/collections_service.dart';
import 'package:photos/utils/crypto_util.dart';

final _logger = Logger("file_download_util");

Future<io.File?> downloadAndDecrypt(
  ente.File file, {
  ProgressCallback? progressCallback,
}) {
  _logger.info("Downloading file " + file.uploadedFileID.toString());
  final encryptedFilePath = Configuration.instance.getTempDirectory() +
      file.generatedID.toString() +
      ".encrypted";
  final encryptedFile = io.File(encryptedFilePath);
  final startTime = DateTime.now().millisecondsSinceEpoch;
  return NetworkClient.instance
      .getDio()
      .download(
        file.downloadUrl,
        encryptedFilePath,
        options: Options(
          headers: {"X-Auth-Token": Configuration.instance.getToken()},
        ),
        onReceiveProgress: progressCallback,
      )
      .then((response) async {
    if (response.statusCode != 200) {
      _logger.warning("Could not download file: ", response.toString());
      return null;
    } else if (!encryptedFile.existsSync()) {
      _logger.warning("File was not downloaded correctly.");
      return null;
    }
    _logger.info("File downloaded: " + file.uploadedFileID.toString());
    _logger.info(
      "Download speed: " +
          (await io.File(encryptedFilePath).length() /
                  (DateTime.now().millisecondsSinceEpoch - startTime))
              .toString() +
          "kBps",
    );
    final decryptedFilePath = Configuration.instance.getTempDirectory() +
        file.generatedID.toString() +
        ".decrypted";
    final decryptedFile = io.File(decryptedFilePath);
    await CryptoUtil.decryptFile(
      encryptedFilePath,
      decryptedFilePath,
      CryptoUtil.base642bin(file.fileDecryptionHeader!),
      getFileKey(file),
    );
    _logger.info("File decrypted: " + file.uploadedFileID.toString());
    await encryptedFile.delete();
    return decryptedFile;
  });
}

Uint8List getFileKey(ente.File file) {
  final encryptedKey = CryptoUtil.base642bin(file.encryptedKey!);
  final nonce = CryptoUtil.base642bin(file.keyDecryptionNonce!);
  final collectionKey =
      CollectionsService.instance.getCollectionKey(file.collectionID!);
  return CryptoUtil.decryptSync(encryptedKey, collectionKey, nonce);
}

Future<Uint8List> getFileKeyUsingBgWorker(ente.File file) async {
  final collectionKey =
      CollectionsService.instance.getCollectionKey(file.collectionID!);
  return await Computer.shared().compute(
    _decryptFileKey,
    param: <String, dynamic>{
      "encryptedKey": file.encryptedKey,
      "keyDecryptionNonce": file.keyDecryptionNonce,
      "collectionKey": collectionKey,
    },
  );
}

Uint8List _decryptFileKey(Map<String, dynamic> args) {
  final encryptedKey = CryptoUtil.base642bin(args["encryptedKey"]);
  final nonce = CryptoUtil.base642bin(args["keyDecryptionNonce"]);
  return CryptoUtil.decryptSync(
    encryptedKey,
    args["collectionKey"],
    nonce,
  );
}
