import 'package:ethereum_addresses/ethereum_addresses.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:magic_wallet/utils/web3_library.dart';


class SecureStorage {
  static const storage = FlutterSecureStorage();

  static updatePrivateKey(String privateKey){
    storage.write(key: "wallet_private_key", value: privateKey);
    storage.write(key: "wallet_address", value: checksumEthereumAddress(Web3Library.getPubAddressFromPrivateKey(privateKey).hex));
  }

  static Future<String?> getWalletAddress(){
    return storage.read(key: "wallet_address");
  }

}