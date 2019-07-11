1.简单的自定义日历控件。
2.使用方法，例如:

  void main() => runApp(
    new MaterialApp(
        home: new Scaffold(
            appBar: AppBar(title: Text("日历"),),
            body: new Container(
                margin: EdgeInsets.all(0),
                child: CalendarWidget(
                    //日期点击回调方法
                    clickFunc: (int year, int month, int day)
                    {
                        print("----$year $month $day----");
                    },
                )
            ),
        ),
    )
);

