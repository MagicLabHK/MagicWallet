import 'dart:math';

import 'package:flutter/material.dart';
import 'package:magic_wallet/utils/logger.dart';
import 'package:magic_wallet/utils/secure_storage.dart';
import 'package:magic_wallet/utils/web3_library.dart';
import 'package:web3dart/web3dart.dart';

class ChainTokenBalanceCard extends StatefulWidget {
  final int _chainId;
  final String _chainName;
  final String _chainIconUrl;
  final String _tokenAddress;
  final String _tokenSymbol;
  final String _tokenName;
  final int _tokenDecimals;
  final String _tokenIconUrl;

  const ChainTokenBalanceCard(this._chainId, this._chainName, this._chainIconUrl, this._tokenAddress, this._tokenSymbol, this._tokenName, this._tokenDecimals,
      this._tokenIconUrl,
      {Key? key})
      : super(key: key);

  @override
  State<ChainTokenBalanceCard> createState() => _ChainTokenBalanceCardState();
}

class _ChainTokenBalanceCardState extends State<ChainTokenBalanceCard> {
  BigInt _tokenBalance = BigInt.zero;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(padding: const EdgeInsets.all(25.0), child: SizedBox(child: Image.asset(widget._tokenIconUrl), width: 32)),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Align(
                    alignment: const FractionalOffset(0, 0),
                    child:
                        Text(widget._tokenSymbol, style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 96, 96), fontSize: 20))),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Align(
                      alignment: const FractionalOffset(0, 0),
                      child: Text(widget._tokenName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))))
            ],
          ),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
              child: FutureBuilder<dynamic>(
                future: Web3Library.getTokenBalanceByStoragedWalletAddress(widget._tokenAddress),
                // a previously-obtained Future<String> or null
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data is EtherAmount){
                      _tokenBalance = (snapshot.data! as EtherAmount).getInWei;
                    }
                    else{
                      _tokenBalance = snapshot.data!;
                    }
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Align(
                            alignment: const FractionalOffset(0, 0),
                            child: Text((_tokenBalance / BigInt.from(pow(10, widget._tokenDecimals))).toStringAsFixed(4),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 96, 96), fontSize: 20))),
                      ),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Align(
                              alignment: FractionalOffset(0, 0), child: Text("\$4000.00", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))),
                    ],
                  );
                },
              ))
        ],
      ),
    );
  }
}
