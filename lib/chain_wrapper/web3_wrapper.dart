import 'dart:math';

import 'package:http/http.dart';
import 'package:magic_wallet/abi/erc20.g.dart';
import 'package:magic_wallet/abi/uniswapv2router.g.dart';
import 'package:magic_wallet/data_structure/ui_transaction.dart';
import 'package:magic_wallet/utils/secure_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';

class Web3Wrapper {
  static final web3Client = Web3Client("https://rpc.moonriver.moonbeam.network", Client());

  static Future<dynamic> getTokenBalance(String walletAddress, String tokenAddress) {
    if (tokenAddress == "0x0000000000000000000000000000000000000000") {
      return web3Client.getBalance(EthereumAddress.fromHex(walletAddress));
    } else {
      final token = Erc20(address: EthereumAddress.fromHex(tokenAddress), client: web3Client);
      return token.balanceOf(EthereumAddress.fromHex(walletAddress));
    }
  }

  static Future<BigInt> getTokenPrice(String routerAddress, List<String> pathString, int decimals) {
    final router = Uniswapv2router(address: EthereumAddress.fromHex(routerAddress), client: web3Client);
    List<EthereumAddress> path = [];
    for (var i = 0; i < pathString.length; i++) {
      path.add(EthereumAddress.fromHex(pathString[i]));
    }
    if (path.isEmpty) {
      return Future<List<BigInt>>.value([BigInt.from(pow(10, decimals))]).then((value) => value[value.length - 1]);
    }
    return router.getAmountsOut$2(BigInt.from(pow(10, decimals)), path, BigInt.from(30)).then((value) => value[value.length - 1]);
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

  static Future<dynamic> getTokenBalanceByStorageWalletAddress(String tokenAddress) async {
    final walletAddress = await SecureStorage.getWalletAddress();
    return getTokenBalance(walletAddress!, tokenAddress);
  }

  static Future<TransactionInformation> getTransactionInformation(String transaction_hash) {
    return web3Client.getTransactionByHash(transaction_hash);
  }

  static Future<TransactionReceipt?> getTransactionReceipt(String transaction_hash) {
    return web3Client.getTransactionReceipt(transaction_hash);
  }

  static Future<UITransaction> getTransactionInfoByHash(String transactionHash, String tokenAddress) async{
    var transactionInformation = await web3Client.getTransactionByHash(transactionHash);
    var transactionReceipt = await web3Client.getTransactionReceipt(transactionHash);
    Map<String, dynamic> transactionInput;
    if (tokenAddress != "0x0000000000000000000000000000000000000000") {
      transactionInput = Web3Wrapper.parseTokenTransferInputData(transactionInformation.input);
    } else {
      transactionInput = {"toAddress": transactionInformation.to?.hexEip55, "amount": transactionInformation.value.getInWei};
    }
    return UITransaction(transactionInput['toAddress'], transactionInput['amount'], transactionReceipt!.status!);
  }

  static Map<String, dynamic> parseTokenTransferInputData(Uint8List input) {
    return {
      "toAddress": EthereumAddress.fromHex(hex.encode(input.sublist(16, 36))).hexEip55,
      "amount": BigInt.parse(hex.encode(input.sublist(36, 68)), radix: 16)
    };
  }

  static Future<EtherAmount> getNetworkGasPrice() {
    return web3Client.getGasPrice();
  }

  static Future<BigInt> estimateGas(String senderAddress, String receiverAddress, String tokenAddress) {
    if (tokenAddress == "0x0000000000000000000000000000000000000000") {
      return web3Client.estimateGas(sender: EthereumAddress.fromHex(senderAddress), to: EthereumAddress.fromHex(receiverAddress), value: EtherAmount.zero());
    } else {
      // Transfer function ABI
      final contractAbi = ContractAbi.fromJson(
          '[{"constant": false,"inputs": [{"internalType": "address","name": "recipient","type": "address"},{"internalType": "uint256","name": "amount","type": "uint256"}],"name": "transfer","outputs": [{"internalType": "bool","name": "","type": "bool"}],"payable": false,"stateMutability": "nonpayable","type": "function"}]',
          'Erc20');
      final contract = DeployedContract(contractAbi, EthereumAddress.fromHex(tokenAddress));
      final transferFunction = contractAbi.functions[0];
      final transaction = Transaction.callContract(
        contract: contract,
        function: transferFunction,
        parameters: [
          EthereumAddress.fromHex(receiverAddress),
          BigInt.from(1),
        ],
      );

      return web3Client.estimateGas(
          sender: EthereumAddress.fromHex(senderAddress), to: EthereumAddress.fromHex(tokenAddress), value: transaction.value, data: transaction.data);
    }
  }

  static Future<String> sendToken(
      String senderAddress, String privateKey, String toAddress, String tokenAddress, BigInt amount, BigInt gas, BigInt gasPrice, int chainId) {
    Transaction transaction;
    if (tokenAddress == "0x0000000000000000000000000000000000000000") {
      transaction = Transaction(
          from: EthereumAddress.fromHex(senderAddress),
          to: EthereumAddress.fromHex(toAddress),
          maxGas: gas.toInt(),
          gasPrice: EtherAmount.inWei(gasPrice),
          value: EtherAmount.inWei(amount));

      return web3Client
          .signTransaction(EthPrivateKey.fromHex(privateKey), transaction, chainId: chainId)
          .then((signedTransaction) => web3Client.sendRawTransaction(signedTransaction));
    } else {
      final token = Erc20(address: EthereumAddress.fromHex(tokenAddress), client: web3Client);
      return token.transfer(EthereumAddress.fromHex(toAddress), amount,
          credentials: EthPrivateKey.fromHex(privateKey), transaction: Transaction(maxGas: gas.toInt(), gasPrice: EtherAmount.inWei(gasPrice)));
    }
  }
}
