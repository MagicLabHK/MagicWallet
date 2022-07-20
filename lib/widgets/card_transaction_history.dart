import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:magic_wallet/chain_wrapper/chain_wrapper.dart';
import 'package:magic_wallet/data_structure/ui_transaction.dart';
import 'package:magic_wallet/utils/secure_storage.dart';

import '../utils/constant.dart';

class TransactionHistoryCard extends StatefulWidget {
  final String _transactionHash;
  final int _tokenDecimals;
  final String _tokenAddress;
  final String _chainName;

  const TransactionHistoryCard(this._transactionHash, this._tokenDecimals, this._tokenAddress, this._chainName, {Key? key}) : super(key: key);

  @override
  State<TransactionHistoryCard> createState() => _TransactionHistoryCardState();
}

class _TransactionHistoryCardState extends State<TransactionHistoryCard> {
  @override
  Widget build(BuildContext context) {
    late Future<UITransaction> uiTransaction;
    switch (widget._chainName.toLowerCase()) {
      case Constant.chainMoonriver:
        uiTransaction = ChainWrapper.getTransactionInfoByHash(widget._chainName, widget._transactionHash, widget._tokenAddress);
        break;
      case Constant.chainNear:
        uiTransaction = SecureStorage.getNearAccountId().then((accountId) {
          return ChainWrapper.getTransactionInfoByHash(widget._chainName, widget._transactionHash, widget._tokenAddress, senderId: accountId);
        });
        break;
    }

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: FutureBuilder<UITransaction>(
          future: uiTransaction,
          builder: (BuildContext context, AsyncSnapshot<UITransaction> snapshot) {
            if (snapshot.hasData) {
              UITransaction transactionInfo = snapshot.data!;
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
                              child: Text(transactionInfo.toAddress,
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
                                if (transactionInfo.status) {
                                  return const Text("Confirmed", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green));
                                } else {
                                  return const Text("Failed", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red));
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
                                child: Text((transactionInfo.amount / BigInt.from(pow(10, widget._tokenDecimals))).toStringAsFixed(4),
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
