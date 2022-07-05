import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:magic_wallet/dialogs/dialog_transfer_token.dart';
import 'package:magic_wallet/utils/secure_storage.dart';
import 'package:magic_wallet/widgets/card_transaction_history.dart';

import '../widgets/card_chain_token_balance.dart';
import '../widgets/text_list_sub_heading.dart';

class TokenTransferPage extends StatefulWidget {
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
  final int _priceDecimals;

  const TokenTransferPage(this._chainId, this._chainName, this._chainIconUrl, this._tokenAddress, this._tokenSymbol, this._tokenName, this._tokenDecimals,
      this._tokenIconUrl, this._routerAddress, this._path, this._priceDecimals,
      {Key? key})
      : super(key: key);

  @override
  State<TokenTransferPage> createState() => _TokenTransferPageState();
}

class _TokenTransferPageState extends State<TokenTransferPage> {
  List<dynamic> _transactionHashList = [];

  _TokenTransferPageState() {
    readChainTokenList();
  }

  Future<void> readChainTokenList() async {
    final String? response = await SecureStorage.readTransactionHistory();
    final Map<String, dynamic> data = await json.decode(response!);
    setState(() {
      if (data.containsKey(widget._chainId.toString())) {
        if (data[widget._chainId.toString()][widget._tokenAddress] != null) {
          _transactionHashList = data[widget._chainId.toString()][widget._tokenAddress];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = <Widget>[
      ListSubHeadingText(widget._chainName),
      ChainTokenBalanceCard(
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
        widget._priceDecimals,
        null,
        clickable: false,
      ),
      const ListSubHeadingText("Transaction History"),
    ];

    if (_transactionHashList.length > 0) {
      for (String transactionHash in _transactionHashList) {
        widgetList.add(TransactionHistoryCard(transactionHash, widget._tokenDecimals, widget._tokenAddress, widget._chainName));
      }
    } else {
      widgetList.add(SizedBox(
        // 1st child of listView
        height: MediaQuery.of(context).size.height - 400,
        child: const Center(
          child: Text("No Transaction history"),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Token Transfer'),
      ),
      body: Center(
        child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: widgetList.length,
            itemBuilder: (BuildContext context, int index) {
              return widgetList[index];
            }),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 15,
              height: 50,
              child: RawMaterialButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return TransferTokenDialog(
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
                        widget._priceDecimals,
                      );
                    },
                  );
                },
                elevation: 2.0,
                fillColor: Colors.lightBlue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.arrow_upward,
                      size: 25.0,
                      color: Colors.white,
                    ),
                    Text('Send', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
                  ],
                ),
                padding: const EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 15,
              height: 50,
              child: RawMaterialButton(
                onPressed: () {},
                elevation: 2.0,
                fillColor: Colors.lightBlue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.arrow_downward,
                      size: 25.0,
                      color: Colors.white,
                    ),
                    Text('Receive', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
                  ],
                ),
                padding: const EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              ),
            )
          ])),
    );
  }
}
