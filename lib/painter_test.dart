import 'package:my_flutter_test/simple_time_select_view.dart';

import 'simple_calendar.dart';
import 'package:flutter/material.dart';

void main() => runApp(
    new MaterialApp(
        routes: {


            "calendar":(BuildContext context) =>
                new Scaffold(
                    appBar: AppBar(title: Text("简单日历控件初版"),),
                    body: new Container(
                        margin: EdgeInsets.fromLTRB(30, 50, 0, 0),
                        child:
                        CalendarWidget(
                            clickFunc: (int year, int month, int day)
                            {
                                print("----$year $month $day----");
                            },
                        )
                    )
                ),

            "timeselect":(BuildContext context) =>
                new Scaffold(
                    appBar: AppBar(title: Text("时间选择控件初版"),),
                    body: new Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child:  TimeSelectWidget()
                    )
                ),


        },
        home: new Scaffold(
            appBar: AppBar(title: Text("painter 学习"),),
            body: ButtonsWidget()
        ),
    )
);

class ButtonsWidget extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
            FlatButton(child: Text("简单日历控件初版"), onPressed: (){
                Navigator.pushNamed(context, "calendar");
            },),
//            FlatButton(child: Text("时间选择控件初版"), onPressed: (){
//                Navigator.pushNamed(context, "timeselect");
//            },),
        ],
    );
  }

}