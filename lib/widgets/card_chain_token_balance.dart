import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:magic_wallet/pages/page_token.dart';
import 'package:web3dart/web3dart.dart';

import '../chain_wrapper/chain_wrapper.dart';
import '../utils/logger.dart';

class ChainTokenBalanceCard extends StatefulWidget {
  final String _chainId;
  final String _chainName;
  final String _chainIconUrl;
  final String _tokenAddress;
  final String _tokenSymbol;
  final String _tokenName;
  final int _tokenDecimals;
  final String _tokenIconUrl;
  final String _routerAddress;
  final List<String> _path;
  final int _flatDecimals;
  final StreamController<List<dynamic>>? _tokenBalanceStreamController;
  final bool clickable;

  const ChainTokenBalanceCard(this._chainId, this._chainName, this._chainIconUrl, this._tokenAddress, this._tokenSymbol, this._tokenName, this._tokenDecimals,
      this._tokenIconUrl, this._routerAddress, this._path, this._flatDecimals, this._tokenBalanceStreamController,
      {Key? key, this.clickable = true})
      : super(key: key);

  @override
  State<ChainTokenBalanceCard> createState() => _ChainTokenBalanceCardState();
}

class _ChainTokenBalanceCardState extends State<ChainTokenBalanceCard> {
  BigInt _tokenBalance = BigInt.zero;
  BigInt _tokenPrice = BigInt.zero;
  double _tokenUsdBalance = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {
              if (widget.clickable)
                {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TokenTransferPage(
                                widget._chainId,
                                widget._chainName,
                                widget._chainIconUrl,
                                widget._tokenAddress,
                                widget._tokenSymbol,
                                widget._tokenName,
                                widget._tokenDecimals,
                                widget._tokenIconUrl,
                                widget._routerAddress,
                                widget._path,
                                widget._flatDecimals,
                              )))
                }
            },
        child: Card(
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
                        child: Text(widget._tokenSymbol,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 96, 96), fontSize: 20))),
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
                    future: ChainWrapper.getTokenBalanceByStorageWalletAddress(widget._chainName, widget._tokenAddress),
                    // a previously-obtained Future<String> or null
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data is EtherAmount) {
                          _tokenBalance = (snapshot.data! as EtherAmount).getInWei;
                        } else {
                          _tokenBalance = snapshot.data!;
                        }
                      }
                      if(snapshot.hasError){
                        Logger.printConsoleLog(snapshot.error.toString());
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Align(
                                alignment: const FractionalOffset(0, 0),
                                child: Text((_tokenBalance / BigInt.from(10).pow(widget._tokenDecimals)).toStringAsFixed(4),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 96, 96), fontSize: 20))),
                          ),
                          FutureBuilder<BigInt>(
                              future: ChainWrapper.getTokenPrice(widget._chainName, widget._routerAddress, widget._path, widget._tokenDecimals),
                              builder: (BuildContext context, AsyncSnapshot<BigInt> snapshot) {
                                if (snapshot.hasData) {
                                  _tokenPrice = snapshot.data!;
                                } else {
                                  _tokenPrice = BigInt.zero;
                                }
                                _tokenUsdBalance =
                                    _tokenBalance / BigInt.from(pow(10, widget._tokenDecimals)) * _tokenPrice.toDouble() / pow(10, widget._flatDecimals);
                                widget._tokenBalanceStreamController?.sink.add([widget._chainId.toString() + widget._tokenAddress, _tokenUsdBalance]);
                                return Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Align(
                                        alignment: const FractionalOffset(0, 0),
                                        child: Text("\$" + _tokenUsdBalance.toStringAsFixed(4),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))));
                              })
                        ],
                      );
                    },
                  ))
            ],
          ),
        ));
  }
}
