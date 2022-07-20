import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:bs58/bs58.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:pinenacl/ed25519.dart';
import 'dart:math';

import '../data_structure/ui_transaction.dart';
import '../utils/secure_storage.dart';

class NearWrapper {
  static Future<BigInt> getTokenBalance(String nearAccount) {
    final response = http.post(
      Uri.parse('https://rpc.mainnet.near.org'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "jsonrpc": "2.0",
        "id": "dontcare",
        "method": "query",
        "params": {"request_type": "view_account", "finality": "final", "account_id": nearAccount}
      }),
    );

    return response.then((value) {
      return BigInt.parse(jsonDecode(value.body)['result']['amount']);
    });
  }

  static Future<dynamic> getTokenBalanceByStorageWalletAddress(String tokenAddress) async {
    final nearAccount = await SecureStorage.getNearAccountId();
    return getTokenBalance(nearAccount!);
  }

  static String getPublicKey(String privateKey) {
    var decodedRaw = base58.decode(privateKey);
    var signingKey = SigningKey.fromValidBytes(decodedRaw);
    return base58.encode(signingKey.publicKey.asTypedList);
  }

  static Future<BigInt> getTokenPrice(String routerAddress, List<String> pathString, int decimals) {
    return Future.value(BigInt.zero);
  }

  static Future<String> sendToken(String signerId, String privateKey, String toId, BigInt amount) async {
    String blockHash = await getLatestBlockHash();
    int nonce = await getPublicKeyNonce(signerId, privateKey);
    BinaryWriter binaryWriter = BinaryWriter();
    binaryWriter.writeString(signerId);
    var decodedRaw = base58.decode(privateKey);
    var signingKey = SigningKey.fromValidBytes(decodedRaw);
    binaryWriter.writePublicKey(signingKey.publicKey.asTypedList);
    binaryWriter.writeNonce(nonce + 1);
    binaryWriter.writeString(toId);
    binaryWriter.writeBlockHash(base58.decode(blockHash));
    binaryWriter.writeTransfer(amount);
    var serializedTx = binaryWriter.toUint8List();
    var serializedTxHash = sha256.convert(serializedTx).bytes.toUint8List();
    var signature = signingKey.sign(serializedTxHash).signature.asTypedList;

    BinaryWriter signedTransactionBinaryWriter = BinaryWriter();
    signedTransactionBinaryWriter.addBytes(serializedTx);
    signedTransactionBinaryWriter.addBytes(Uint8List.fromList([0]));
    signedTransactionBinaryWriter.addBytes(signature);
    var encodedTransaction = base64.encode(signedTransactionBinaryWriter.toUint8List());
    final response = http.post(
      Uri.parse('https://rpc.mainnet.near.org'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "jsonrpc": "2.0",
        "id": "",
        "method": "broadcast_tx_async",
        "params": [encodedTransaction]
      }),
    );
    return response.then((value) => jsonDecode(value.body)["result"].toString());
  }

  static Future<String> getLatestBlockHash() {
    final response = http.post(
      Uri.parse('https://rpc.mainnet.near.org'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{"jsonrpc": "2.0", "id": "", "method": "status", "params": []}),
    );
    return response.then((value) {
      return jsonDecode(value.body)['result']['sync_info']['latest_block_hash'];
    });
  }

  static Future<int> getPublicKeyNonce(String signerId, String privateKey) {
    final response = http.post(
      Uri.parse('https://rpc.mainnet.near.org'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "jsonrpc": "2.0",
        "id": "",
        "method": "query",
        "params": {"request_type": "view_access_key", "finality": "final", "account_id": signerId, "public_key": "ed25519:" + getPublicKey(privateKey)}
      }),
    );
    return response.then((value) {
      return jsonDecode(value.body)['result']['nonce'];
    });
  }

  static Future<UITransaction> getTransactionInfoByHash(String transactionHash, String tokenAddress, String senderId) async {
    final response = await http.post(
      Uri.parse('https://rpc.mainnet.near.org'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "jsonrpc": "2.0",
        "id": "",
        "method": "tx",
        "params": [transactionHash, senderId]
      }),
    );
    final responseJson = jsonDecode(response.body);

    return UITransaction(
        responseJson['result']["transaction"]["receiver_id"], BigInt.parse(responseJson['result']["transaction"]["actions"][0]["Transfer"]["deposit"]), true);
  }
}

class BinaryWriter {
  List<int> buffer = [];

  addBytes(Uint8List bytes) {
    for (var byte in bytes) {
      buffer.add(byte);
    }
  }

  writeString(String string) {
    var bytes = const Utf8Codec().encoder.convert(string);
    var byteLength = Uint8List.fromList(HEX.decode((string.length.toRadixString(16).padLeft(8, "0"))));
    addBytes(Uint8List.fromList(byteLength.reversed.toList()));
    addBytes(bytes);
  }

  writePublicKey(Uint8List publicKey) {
    addBytes(Uint8List.fromList([0]));
    addBytes(publicKey);
  }

  writeNonce(int nonce) {
    Uint8List nonceList = (Uint8List(8)..buffer.asByteData().setInt64(0, nonce, Endian.little));
    num result = 0;
    int count = 0;
    for (var number in nonceList) {
      result = result + number * pow(256, count);
      count = count + 1;
    }
    addBytes(Uint8List(8)..buffer.asByteData().setInt64(0, nonce, Endian.little));
  }

  writeBlockHash(Uint8List blockHash) {
    addBytes(blockHash);
  }

  writeTransfer(BigInt amount) {
    addBytes(Uint8List.fromList([0, 0, 0, 1].reversed.toList()));
    addBytes(Uint8List.fromList([3]));
    addBytes(Uint8List.fromList(bigIntToBytes(amount).reversed.toList()));
  }

  Uint8List bigIntToBytes(BigInt bigInt) {
    return Uint8List.fromList(HEX.decode((bigInt.toRadixString(16).padLeft(32, "0"))));
  }

  Uint8List toUint8List() {
    return Uint8List.fromList(buffer);
  }
}
