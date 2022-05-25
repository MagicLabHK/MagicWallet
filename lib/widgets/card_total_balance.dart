import 'dart:async';

import 'package:flutter/material.dart';

class TotalBalanceCard extends StatefulWidget {
  final StreamController<List<dynamic>> _tokenBalanceStreamController;

  const TotalBalanceCard(this._tokenBalanceStreamController, {Key? key})
      : super(key: key);

  @override
  State<TotalBalanceCard> createState() => _TotalBalanceCardState();
}

class _TotalBalanceCardState extends State<TotalBalanceCard> {
  double _totalUsdBalance = 0.0;
  final Map<String, double> _tokensUsdValueMap = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
              child: Center(
                child: Text("Total Balance",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
            child: Center(
              child: StreamBuilder<List<dynamic>>(
                stream: widget._tokenBalanceStreamController.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    _tokensUsdValueMap[snapshot.data![0]] = snapshot.data![1];
                  }
                  _totalUsdBalance = 0.0;
                  _tokensUsdValueMap.forEach((key, tokenBalance) {
                    _totalUsdBalance = _totalUsdBalance + tokenBalance;
                  });
                  return Text("\$" + _totalUsdBalance.toStringAsFixed(2),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 28));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
