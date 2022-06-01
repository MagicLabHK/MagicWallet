import 'dart:math';

import 'package:http/http.dart';
import 'package:magic_wallet/abi/erc20.g.dart';
import 'package:magic_wallet/abi/uniswapv2router.g.dart';
import 'package:magic_wallet/utils/secure_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';


class Web3Library {
  static final web3Client = Web3Client("https://rpc.moonriver.moonbeam.network", Client());

  static Future<dynamic> getTokenBalance(String walletAddress, String tokenAddress) {
    if (tokenAddress == "0x0000000000000000000000000000000000000000") {
      return web3Client.getBalance(EthereumAddress.fromHex(walletAddress));
    } else {
      final token = Erc20(address: EthereumAddress.fromHex(tokenAddress), client: web3Client);
      return token.balanceOf(EthereumAddress.fromHex(walletAddress));
    }
  }

  static Future<List<BigInt>> getTokenPrice(String routerAddress, List<String> pathString, int decimals){
    final router = Uniswapv2router(address: EthereumAddress.fromHex(routerAddress), client: web3Client);
    List<EthereumAddress> path = [];
    for(var i = 0 ; i < pathString.length ; i++){
      path.add(EthereumAddress.fromHex(pathString[i]));
    }
    if(path.isEmpty){
      return Future<List<BigInt>>.value([BigInt.from(pow(10, decimals))]);
    }
    return router.getAmountsOut$2(BigInt.from(pow(10, decimals)), path, BigInt.from(30));
  }

  static BigInt decodeToBigInt(List<int> magnitude) {
    BigInt result;

    if (magnitude.length == 1) {
      result = BigInt.from(magnitude[0]);
    } else {
      result = BigInt.from(0);
      for (var i = 0; i < magnitude.length; i++) {
        var item = magnitude[magnitude.length - i - 1];
        result |= (BigInt.from(item) << (8 * i));
      }
    }

    if (result != BigInt.zero) {
      return result.toUnsigned(result.bitLength);
    }
    return BigInt.zero;
  }

  static EthereumAddress getPubAddressFromPrivateKey(String privateKeyString) {
    Uint8List privateKeyBytes = hexToBytes(privateKeyString);
    BigInt privateKeyInUnsignedInt = decodeToBigInt(privateKeyBytes);
    return EthereumAddress.fromPublicKey(privateKeyToPublic(privateKeyInUnsignedInt));
  }

  static Future<dynamic> getTokenBalanceByStorageWalletAddress(String tokenAddress) async{
    final walletAddress = await SecureStorage.getWalletAddress();
    return getTokenBalance(walletAddress!, tokenAddress);
  }

  static Future<TransactionInformation> getTransactionInformation(String transaction_hash){
    return web3Client.getTransactionByHash(transaction_hash);
  }

  static Map<String, dynamic> parseTokenTransferInputData(Uint8List input){
    return {
      "toAddress": EthereumAddress.fromHex(hex.encode(input.sublist(16, 36))).hexEip55,
      "amount": BigInt.parse(hex.encode(input.sublist(36, 68)), radix: 16)
    };
  }
}
