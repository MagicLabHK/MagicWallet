import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magic_wallet/utils/web3_library.dart';
import 'package:web3dart/web3dart.dart';

import '../utils/logger.dart';

class TransactionHistoryCard extends StatefulWidget {
  final String _transaction_hash;

  const TransactionHistoryCard(this._transaction_hash, {Key? key})
      : super(key: key);

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
      child: FutureBuilder<TransactionInformation?>(
        future: Web3Library.getTransactionInformation(widget._transaction_hash),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            Logger.printConsoleLog("Loaded data");
          }
          return Center();
        }
      ),
    );
  }
}
