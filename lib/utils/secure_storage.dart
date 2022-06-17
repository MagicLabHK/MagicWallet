import 'package:ethereum_addresses/ethereum_addresses.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:magic_wallet/utils/web3_library.dart';
import 'dart:convert';


class SecureStorage {
  static const storage = FlutterSecureStorage();

  static updatePrivateKey(String privateKey){
    storage.write(key: "wallet_private_key", value: privateKey);
    storage.write(key: "wallet_address", value: checksumEthereumAddress(Web3Library.getPubAddressFromPrivateKey(privateKey).hex));
  }

  static Future<String?> getWalletAddress(){
    return storage.read(key: "wallet_address");
  }

  static addTransactionRecord(String chainId, String tokenAddress, String txHash){
    storage.read(key: "transaction_history").then((transactionHistoryMap) {
      if(transactionHistoryMap == null){
        Map<String, Map> map = {
          chainId: {
            tokenAddress: [txHash]
          }
        };
        String mapString = json.encode(map);
        storage.write(key: "transaction_history", value: mapString);
      }
      else{
        Map<String, dynamic> map = json.decode(transactionHistoryMap);
        if(map.containsKey(chainId)){
          if(map[chainId]!.containsKey(tokenAddress)){
            map[chainId]![tokenAddress]!.insert(0, txHash);
          }
          else{
            map[chainId]![tokenAddress] = [txHash];
          }
        }
        else{
          map[chainId] = {
            tokenAddress: [txHash]
          };
        }
        String mapString = json.encode(map);
        storage.write(key: "transaction_history", value: mapString);
      }
    });
  }

  static Future<String?> readTransactionHistory(){
    return storage.read(key: "transaction_history");
  }

}