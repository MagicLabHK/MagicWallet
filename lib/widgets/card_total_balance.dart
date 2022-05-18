import 'package:flutter/material.dart';

class TotalBalanceCard extends StatelessWidget {
  const TotalBalanceCard({Key? key}) : super(key: key);

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
        children: const <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
              child: Center(
                child: Text("Total Balance",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              )),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
            child: Center(
              child: Text("\$4000.00",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 28)),
            ),
          ),
        ],
      ),
    );
  }
}
