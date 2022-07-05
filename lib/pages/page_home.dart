import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_wallet/widgets/card_chain_token_balance.dart';
import 'package:magic_wallet/widgets/card_total_balance.dart';
import 'package:magic_wallet/widgets/text_list_sub_heading.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _chainTokenList = [];
  final StreamController<List<dynamic>> _tokenBalanceStreamController = StreamController();

  _HomePageState() {
    readChainTokenList();
  }

  Future<void> readChainTokenList() async {
    final String response =
        await rootBundle.loadString('assets/data/chain_token_list.json');
    final data = await json.decode(response);
    setState(() {
      _chainTokenList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = <Widget>[
      const ListSubHeadingText("Main"),
      TotalBalanceCard(_tokenBalanceStreamController),
    ];
    for (var chain in _chainTokenList) {
      String chainId = chain["chain_id"];
      String chainName = chain["chain_name"];
      String chainIconUrl = chain["chain_icon_url"];
      widgetList.add(ListSubHeadingText(chainName + " Assets"));
      for (var token in chain["token_list"]) {
        String tokenAddress = token["token_address"];
        String tokenName = token["token_name"];
        String tokenSymbol = token["token_symbol"];
        int tokenDecimals = token["token_decimals"];
        String tokenIconUrl = token["token_icon_url"];
        String routerAddress = token['price_router'];
        List<dynamic> pathTmp = token['price_path'];
        List<String> path = [];
        for (var i = 0; i < pathTmp.length; i++) {
          path.add(pathTmp[i] as String);
        }
        int priceDecimals = token["price_decimals"];

        widgetList.add(ChainTokenBalanceCard(
            chainId,
            chainName,
            chainIconUrl,
            tokenAddress,
            tokenSymbol,
            tokenName,
            tokenDecimals,
            tokenIconUrl,
            routerAddress,
            path,
            priceDecimals,
            _tokenBalanceStreamController));
      }
    }

    return ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: widgetList.length,
        itemBuilder: (BuildContext context, int index) {
          return widgetList[index];
        });
  }
}
