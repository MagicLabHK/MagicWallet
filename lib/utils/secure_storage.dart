import 'package:ethereum_addresses/ethereum_addresses.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:magic_wallet/chain_wrapper/chain_wrapper.dart';
import 'dart:convert';

import 'package:bs58/bs58.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/src/digests/digests.dart' as pn;
import 'package:cryptography/cryptography.dart';
import 'package:web3dart/crypto.dart';

class SecureStorage {
  static const storage = FlutterSecureStorage();

  static updatePrivateKey(String chainName, String privateKey) {
    storage.write(key: "wallet_private_key", value: privateKey);
    storage.write(key: "wallet_address", value: checksumEthereumAddress(ChainWrapper.getPubAddressFromPrivateKey(chainName, privateKey).hex));
  }

  static Future<String?> getWalletAddress() {
    return storage.read(key: "wallet_address");
  }

  static Future<String?> getWalletPrivateKey() {
    return storage.read(key: "wallet_private_key");
  }

  static updateNearWalletAccount(String privateKey, String accountId) {
    if (privateKey.contains(":")) {
      privateKey = privateKey.split(":")[1];
    }
    storage.write(key: "near_private_key", value: privateKey);
    storage.write(key: "near_account_id", value: accountId);
  }

  static updateWavesSeed(String seed) async {
    const seed = "bomb inhale example craft elder depart equip hand define double left left useless help disagree";
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

    storage.write(key: "waves_seed", value: seed);
    storage.write(key: "waves_address", value: base58.encode(address.toUint8List()));
    storage.write(key: "waves_public_key", value: base58.encode(publicKey.bytes.toUint8List()));
    storage.write(key: "waves_private_key", value: base58.encode(privateKey.toUint8List()));
  }

  static Future<String?> getNearAccountId() {
    return storage.read(key: "near_account_id");
  }

  static Future<String?> getNearPrivateKey() {
    return storage.read(key: "near_private_key");
  }

  static Future<String?> getWavesAddress() {
    return storage.read(key: "waves_address");
  }

  static Future<String?> getWavesPrivateKey() {
    return storage.read(key: "waves_private_key");
  }

  static Future<String?> getWavesPublicKey() {
    return storage.read(key: "waves_public_key");
  }

  static addTransactionRecord(String chainId, String tokenAddress, String txHash) {
    storage.read(key: "transaction_history").then((transactionHistoryMap) {
      if (transactionHistoryMap == null) {
        Map<String, Map> map = {
          chainId: {
            tokenAddress: [txHash]
          }
        };
        String mapString = json.encode(map);
        storage.write(key: "transaction_history", value: mapString);
      } else {
        Map<String, dynamic> map = json.decode(transactionHistoryMap);
        if (map.containsKey(chainId)) {
          if (map[chainId]!.containsKey(tokenAddress)) {
            map[chainId]![tokenAddress]!.insert(0, txHash);
          } else {
            map[chainId]![tokenAddress] = [txHash];
          }
        } else {
          map[chainId] = {
            tokenAddress: [txHash]
          };
        }
        String mapString = json.encode(map);
        storage.write(key: "transaction_history", value: mapString);
      }
    });
  }

  static Future<String?> readTransactionHistory() {
    return storage.read(key: "transaction_history");
  }
}
