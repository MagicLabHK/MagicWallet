import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/logger.dart';
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
        "params": {
          "request_type": "view_account",
          "finality": "final",
          "account_id": nearAccount
        }
      }),
    );

    return response.then((value){return BigInt.parse(jsonDecode(value.body)['result']['amount']);});
  }

  static Future<dynamic> getTokenBalanceByStorageWalletAddress(String tokenAddress) async {
    final nearAccount = await SecureStorage.getNearWalletAccount();
    return getTokenBalance(nearAccount!);
  }

  static Future<BigInt> getTokenPrice(String routerAddress, List<String> pathString, int decimals) {
    return Future.value(BigInt.zero);
  }
}
