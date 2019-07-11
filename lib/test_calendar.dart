import 'simple_calendar.dart';
import 'package:flutter/material.dart';

void main() => runApp(
    new MaterialApp(
        home: new Scaffold(
            appBar: AppBar(title: Text("日历"),),
            body: new Container(
                margin: EdgeInsets.all(0),
                child: CalendarWidget(
                    clickFunc: (int year, int month, int day)
                    {
                        print("----$year $month $day----");
                    },
                )
            ),
        ),
    )
);