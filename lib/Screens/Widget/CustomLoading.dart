import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../util/Global.dart';

Animation<double> _angleAnimation;

Animation<double> _scaleAnimation;
Widget customLoadingWidget({String text = "", Color color = Colors.blue}){
  return Column(
    children: [
      ClipOval(
        child: SpinKitDoubleBounce(
          color: color,
          size: 50.0,
        )
      ),
      if(text.isNotEmpty)
        SizedBox(height: 15,),
      if(text.isNotEmpty)
        Text(text,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontFamily: Global.font,
          ),
        )
    ],
  );
}
// Widget _buildAnimation() {
//     double circleWidth = 10.0 * _scaleAnimation.value;
//     Widget circles = new Container(
//       width: circleWidth * 2.0,
//       height: circleWidth * 2.0,
//       child: new Column(
//         children: <Widget>[
//           new Row (
//               children: <Widget>[
//                 _buildCircle(circleWidth,Colors.blue),
//                 _buildCircle(circleWidth,Colors.red),
//               ],
//           ),
//           new Row (
//             children: <Widget>[
//               _buildCircle(circleWidth,Colors.yellow),
//               _buildCircle(circleWidth,Colors.green),
//             ],
//           ),
//         ],
//       ),
//     );
 
//     double angleInDegrees = _angleAnimation.value;
//     return new Transform.rotate(
//       angle: angleInDegrees / 360 * 2 * PI,
//       child: new Container(
//         child: circles,
//       ),
//     );
//   }
 
//   Widget _buildCircle(double circleWidth, Color color) {
//     return new Container(
//       width: circleWidth,
//       height: circleWidth,
//       decoration: new BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//       ),
//     );
//   }