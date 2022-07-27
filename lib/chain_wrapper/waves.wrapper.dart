import 'dart:convert';

import 'package:bs58/bs58.dart';
import 'package:http/http.dart' as http;
import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/src/digests/digests.dart' as pn;
import 'package:cryptography/cryptography.dart';
import 'package:web3dart/crypto.dart';

import '../utils/logger.dart';
import '../utils/secure_storage.dart';

class WavesWrapper {
  static Future<BigInt> getTokenBalance(String wavesAddress) {
    final response = http.get(Uri.parse('https://nodes.wavesnodes.com/addresses/balance/' + wavesAddress));
    return response.then((value) {
      return BigInt.from(jsonDecode(value.body)['balance']);
    });
  }

  static Future<BigInt> getTokenPrice(String routerAddress, List<String> pathString, int decimals) {
    return Future.value(BigInt.zero);
  }

  static Future<dynamic> getTokenBalanceByStorageWalletAddress(String tokenAddress) async {
    final wavesAddress = await SecureStorage.getWavesAddress();
    return getTokenBalance(wavesAddress!);
  }

  static Future<String> getAddressFromSeed(String seed) async {
    var encodedSeed = "1111" + base58.encode(Uint8List.fromList(seed.codeUnits)).toString();
    var decodedSeed = base58.decode(encodedSeed);
    var accountSeedByte = pn.Hash.blake2b(decodedSeed, digestSize: 32);
    var accountSeed = keccak256(accountSeedByte);
    var accountSeedHash = pn.Hash.sha256(accountSeed);
    final algorithm = Cryptography.instance.x25519();
    final keyPair = await algorithm.newKeyPairFromSeed(accountSeedHash);
    final publicKey = await keyPair.extractPublicKey();
    final privateKey = await keyPair.extractPrivateKeyBytes();
    var address = [1, 87] + keccak256(pn.Hash.blake2b(publicKey.bytes.toUint8List(), digestSize: 32)).sublist(0, 20);
    var checksum = keccak256(pn.Hash.blake2b(address.toUint8List(), digestSize: 32)).sublist(0, 4);
    address.addAll(checksum);

    /*
    Logger.printConsoleLog(encodedSeed.toString());
    Logger.printConsoleLog(decodedSeed.toString());
    Logger.printConsoleLog(base58.encode(accountSeedHash).toString());
    Logger.printConsoleLog(base58.encode(publicKey.bytes.toUint8List()));
    Logger.printConsoleLog(base58.encode(privateKey.toUint8List()));
    Logger.printConsoleLog(checksum.toString());
    Logger.printConsoleLog(base58.encode(address.toUint8List()));

     */

    return Future.value(base58.encode(address.toUint8List()));
  }
}
