import 'dart:typed_data';

import 'package:magic_wallet/chain_wrapper/near_wrapper.dart';
import 'package:magic_wallet/chain_wrapper/web3_wrapper.dart';
import 'package:magic_wallet/utils/constant.dart';
import 'package:web3dart/web3dart.dart';


class ChainWrapper {
  static Future<dynamic> getTokenBalance(String chainName, String walletAddress, String tokenAddress) {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.getTokenBalance(walletAddress, tokenAddress);
      case Constant.chainNear:
        return NearWrapper.getTokenBalance(walletAddress);
      default:
        throw Exception(["getTokenBalance(walletAddress, tokenAddress) is not implemented for $chainName"]);
    }
  }

  static Future<BigInt> getTokenPrice(String chainName, String routerAddress, List<String> pathString, int decimals) {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.getTokenPrice(routerAddress, pathString, decimals);
      case Constant.chainNear:
        return NearWrapper.getTokenPrice(routerAddress, pathString, decimals);
      default:
        throw Exception(["getTokenPrice(routerAddress, pathString, decimals) is not implemented for $chainName"]);
    }
  }

  static EthereumAddress getPubAddressFromPrivateKey(String chainName, String privateKeyString) {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.getPubAddressFromPrivateKey(privateKeyString);
      default:
        throw Exception(["getPubAddressFromPrivateKey(String privateKeyString) is not implemented for $chainName"]);
    }
  }

  static Future<dynamic> getTokenBalanceByStorageWalletAddress(String chainName, String tokenAddress) async {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.getTokenBalanceByStorageWalletAddress(tokenAddress);
      case Constant.chainNear:
        return NearWrapper.getTokenBalanceByStorageWalletAddress(tokenAddress);
      default:
        throw Exception(["getTokenBalanceByStorageWalletAddress(String tokenAddress) is not implemented for $chainName"]);
    }
  }

  static Future<TransactionInformation> getTransactionInformation(String chainName, String transactionHash) {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.getTransactionInformation(transactionHash);
      default:
        throw Exception(["getTransactionInformation(transactionHash) is not implemented for $chainName"]);
    }
  }

  static Future<TransactionReceipt?> getTransactionReceipt(String chainName, String transactionHash) {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.getTransactionReceipt(transactionHash);
      default:
        throw Exception(["getTransactionReceipt(transactionHash) is not implemented for $chainName"]);
    }
  }

  static Map<String, dynamic> parseTokenTransferInputData(String chainName, Uint8List input) {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.parseTokenTransferInputData(input);
      default:
        throw Exception(["parseTokenTransferInputData(input) is not implemented for $chainName"]);
    }
  }

  static Future<EtherAmount> getNetworkGasPrice(String chainName) {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.getNetworkGasPrice();
      default:
        throw Exception(["getNetworkGasPrice() is not implemented for $chainName"]);
    }
  }

  static Future<BigInt> estimateGas(String chainName, String senderAddress, String receiverAddress, String tokenAddress) {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.estimateGas(senderAddress, receiverAddress, tokenAddress);
      default:
        throw Exception(["estimateGas(senderAddress, receiverAddress, tokenAddress) is not implemented for $chainName"]);
    }
  }

  static Future<String> sendToken(String chainName, String senderAddress, String privateKey, String toAddress, String tokenAddress, BigInt amount, BigInt gas,
      BigInt gasPrice, int chainId) {
    switch (chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        return Web3Wrapper.sendToken(senderAddress, privateKey, toAddress, tokenAddress, amount, gas, gasPrice, chainId);
      default:
        throw Exception(["sendToken(senderAddress, privateKey, toAddress, tokenAddress, amount, gas, gasPrice, chainId) is not implemented for $chainName"]);
    }
  }
}
