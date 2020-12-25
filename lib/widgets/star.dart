import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

class StarWidget extends StatelessWidget {
  double score1;
  int total;
  StarWidget(this.score1, this.total);

  @override
  Widget build(BuildContext context) {
    double score = score1 / 2;
    List<Widget> _list = List<Widget>();
    for (var i = 0; i < total; i++) {
      double factor = (score - i);
      if (factor >= 1) {
        factor = 1.0;
      } else if (factor < 0) {
        factor = 0;
      }
      Stack _st = Stack(
        children: <Widget>[
          Icon(
            Icons.star,
            color: Colors.grey,
            size: 12,
          ),
          ClipRect(
              child: Align(
            alignment: Alignment.topLeft,
            widthFactor: factor,
            child: Icon(
              Icons.star,
              color: Color.fromARGB(255, 255, 185, 15),
              size: 12.0,
            ),
          ))
        ],
      );
      _list.add(_st);
    }
    NumUtil.getNumByValueDouble(score1, 2);
    _list.add(Text(
      '$score1',
      style: TextStyle(fontSize: 10),
    ));
    return Row(
      children: _list,
    );
  }


}
