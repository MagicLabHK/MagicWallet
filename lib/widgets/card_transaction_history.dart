import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:magic_wallet/chain_wrapper/chain_wrapper.dart';
import 'package:magic_wallet/chain_wrapper/web3_wrapper.dart';
import 'package:web3dart/web3dart.dart';

class TransactionHistoryCard extends StatefulWidget {
  final String _transaction_hash;
  final int _tokenDecimals;
  final String _tokenAddress;
  final String _chainName;

  const TransactionHistoryCard(this._transaction_hash, this._tokenDecimals, this._tokenAddress, this._chainName, {Key? key}) : super(key: key);

  @override
  State<TransactionHistoryCard> createState() => _TransactionHistoryCardState();
}

class _TransactionHistoryCardState extends State<TransactionHistoryCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            ChainWrapper.getTransactionInformation(widget._chainName, widget._transaction_hash),
            ChainWrapper.getTransactionReceipt(widget._chainName, widget._transaction_hash)
          ]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data.length > 0) {
              final TransactionInformation transactionInformation = snapshot.data[0];
              final TransactionReceipt? transactionReceipt = snapshot.data[1];
              Map<String, dynamic> transactionInput;
              if (widget._tokenAddress != "0x0000000000000000000000000000000000000000") {
                transactionInput = ChainWrapper.parseTokenTransferInputData(widget._chainName, transactionInformation.input);
              } else {
                transactionInput = {"toAddress": transactionInformation.to?.hexEip55, "amount": transactionInformation.value.getInWei};
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(padding: EdgeInsets.all(25.0), child: SizedBox(child: Icon(Icons.upload), width: 24)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Align(
                            alignment: FractionalOffset(0, 0),
                            child: Text("Transfer Token to:",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: true,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 96, 96)))),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Align(
                            alignment: const FractionalOffset(0, 0),
                            child: SizedBox(
                              width: 200,
                              child: Text((transactionInput['toAddress'] as String),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: true,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 96, 96))),
                            )),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Align(
                              alignment: const FractionalOffset(0, 0),
                              child: (() {
                                if (transactionReceipt != null) {
                                  if (transactionReceipt.status ?? true) {
                                    return const Text("Confirmed", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green));
                                  } else {
                                    return const Text("Failed", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red));
                                  }
                                }
                              }())))
                    ],
                  ),
                  const Spacer(),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Align(
                                alignment: const FractionalOffset(0, 0),
                                child: Text((transactionInput['amount'] / BigInt.from(pow(10, widget._tokenDecimals))).toStringAsFixed(4),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 96, 96), fontSize: 20))),
                          ),
                        ],
                      ))
                ],
              );
            }
            return Center();
          }),
    );
  }
}
