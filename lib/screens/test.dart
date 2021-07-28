import 'package:flutter/material.dart';
import 'package:house_input/services/style.dart';

class Test extends StatelessWidget {
  final data;
  const Test({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Text(data.toString(),
                style: TextStyle(color: black, fontSize: 24)),
          ),
        )
        //     ListView.builder(
        //   itemBuilder: (ctx, idx) {
        //     return Text(data[idx].date.toString());
        //   },
        //   itemCount: data.length,
        // )),
        );
  }
}
