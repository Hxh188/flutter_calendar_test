/*
 * author: Created by 黄晓辉 on 2019/07/11.
 * email: 582087924@qq.com
 *  简单的自定义日历控件
 */

import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_flutter_test/simple_wheelview.dart';

//是否开启调试模式
bool _DEBUG = true;

class CalendarWidget extends StatelessWidget
{
    GlobalKey<CalendarContentState> calendarKey = new GlobalKey();
    GlobalKey<TextState> txtKey = new GlobalKey();

    //日期点击回调
    Function clickFunc = () => {};
    CalendarWidget({this.clickFunc}):super();

    @override
    Widget build(BuildContext context) {
        return new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        new IconButton(
                            tooltip: '上一月',
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                                calendarKey?.currentState?._nextPage(-1);
                                },
                        ),
                        new Container(
                            padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
                            child: FlatButton(onPressed: () => _showSelectMonthDialog(context, (int year, int month){
                                //获取要跳转的年月在数据列表中的位置索引
                                int gotoPos = calendarKey?.currentState?.getPosOfYearMonth(year, month);
                                if(gotoPos >= 0)
                                    {
                                        //获取当前页面显示年月
                                        YearMonth ym = calendarKey?.currentState?.getCurrentShowYearMonth();
                                        //获取当前页面显示年月的1号在网格中的位置索引
                                        int startPos = CalendarUtil.getStartPosOfMonth(ym.year, ym.month);
                                        //获取当前页面显示年月默认显示几号
                                        int showDay = ym.initPos - startPos + 1;

                                        //获取要跳转的年月
                                        YearMonth gotoYm = calendarKey?.currentState?.choices[gotoPos];
                                        //设置要跳转的年月默认显示几号，跟当前页面显示年月显示几号是一样的。。
                                        CalendarUtil.setMonthInitCount(gotoYm, showDay);
                                        //跳到要跳转的年月
                                        calendarKey?.currentState?.setCurrentPos(gotoPos);
                                    }
                            }), child:
                            new TextWidget(txtKey)
                            )
                        )
                        ,
                        new IconButton(
                            tooltip: '下一月',
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                                calendarKey?.currentState?._nextPage(1);
                                },
                        ),

                    ]),
                new Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                    child: new Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                            new Text("日"),
                            new Text("一"),
                            new Text("二"),
                            new Text("三"),
                            new Text("四"),
                            new Text("五"),
                            new Text("六")
                        ],
                    ),
                ),
                new Container(
                    width: null,
                    height: LabelViewPainter.getHeight(),
                    child: new CalendarContent(calendarKey, (){
                        _showCurrentMonth();
                    }, this.clickFunc),
                )
            ],
        );
    }

    ///在中间标题显示当前月份
    void _showCurrentMonth()
    {
        try
        {
            txtKey?.currentState?.setStr("${calendarKey?.currentState?.getCurrentMonthStr()}");
        }catch(e)
        {
            print(e);
        }
    }
}

class TextWidget extends StatefulWidget
{
    TextWidget(Key txtKey):super(key:txtKey);
  @override
  State<StatefulWidget> createState() {
    var ts = new TextState();
    return ts;
  }

}

class TextState extends State<TextWidget>
{
    String monthStr = "";
    TextState()
    {
        var date = DateTime.now();
        monthStr = "${date.toString().substring(0, 7)}";
    }
    void setStr(String sss)
    {
        setState(() {
            this.monthStr = sss;
        });
    }

  @override
  Widget build(BuildContext context) {
    return new Text(monthStr);
  }

}

class CalendarContent extends StatefulWidget
{
    //日期点击回调方法
    Function clickFunc = () => {};
    //页面切换回调方法
    Function pageChangeCallback = () =>{};
    CalendarContent(Key key, this.pageChangeCallback, this.clickFunc):super(key:key);
    @override
    State<StatefulWidget> createState() {
        return new CalendarContentState(pageChangeCallback, this.clickFunc);
    }
}

class CalendarContentState extends State<CalendarContent>  with SingleTickerProviderStateMixin {
    Function clickFunc = () => {};
    Function pageChangeCallback = () => {};

    //当前年份的前yearCount，后yearCount年
    static final int yearCount = 30;
    static final int allMonthCount = (yearCount * 2 + 1) * 12; //当前年的前yearCount年，到当前年的后yearCount年，这些的月份
    var choices = List<YearMonth>();
    PageController mPageController;

    CalendarContentState(this.pageChangeCallback, this.clickFunc) :super();

    @override
    void initState() {
        super.initState();
        var now = DateTime.now();
        int currentYear = now.year;
        for (var i = -yearCount; i < 0; i++) {
            int year = currentYear + i;
            for (int j = 1; j <= 12; j++) {
                choices.add(YearMonth(year, j));
            }
        }
        for (var i = 0; i <= yearCount; i++) {
            int year = currentYear + i;
            for (int j = 1; j <= 12; j++) {
                var ym = YearMonth(year, j);
                //如果是现在所在的月份，则默认显示今天
                if(i == 0 && j == now.month){

                    ym.initPos = CalendarUtil.getStartPosOfMonth(currentYear, j) + now.day - 1;
                }
                choices.add(ym);
            }
        }

        //回调今天
        clickFunc(currentYear, now.month, now.day);
        int nowMonthPos = getNowMonthPos();
        setDefaultPosInPreAndNext(nowMonthPos, now.day);
        mPageController = new PageController(initialPage: nowMonthPos);
    }

    @override
    void dispose() {
        mPageController.dispose();
        super.dispose();
    }

    void _nextPage(int delta) {
        final int newIndex = getCurrentPos() + delta;
        if (newIndex < 0 || newIndex >= choices.length)
            return;

        if(delta == 1){
            mPageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.decelerate);
        }else if(delta == -1){
            mPageController.previousPage(duration: Duration(milliseconds: 400), curve: Curves.decelerate);
        }
    }

    void setCurrentPos(int pos)
    {
        mPageController.jumpToPage(pos);
    }



    int getPosOfYearMonth(int year, int month)
    {
        int size = choices.length;
        for(int i = 0;i < size;i++)
            {
                YearMonth ym = choices[i];
                if(ym.year == year && ym.month == month)
                    {
                        return i;
                    }
            }
        return -1;
    }

    ///获取当前页索引
    int getCurrentPos() {
        return mPageController.page.round();
    }

    ///获取当前页索引代表的月份
    String getCurrentMonthStr() {
        var data = choices[getCurrentPos()];
        return "${data.year}-${data.month > 9 ? ("${data.month}") : ("0${data
            .month}")}";
    }


    ///获取现在的月份在数据列表中的位置
    int getNowMonthPos() {
        var now = DateTime.now();
        var nowYear = now.year;
        var nowMonth = now.month;
        for (int i = 0; i < 12; i++) {
            var pos = yearCount * 12 + i;
            if (choices[pos].year == nowYear &&
                choices[pos].month == nowMonth) {
                return pos;
            }
        }
        return -1;
    }
    @override
    Widget build(BuildContext context) {
        var pageView = PageView.builder(
            itemCount: choices.length,
            onPageChanged: (index) {
                int pos = index;

                var ym = choices[pos];

                int firstDay = CalendarUtil.getStartPosOfMonth(
                    ym.year, ym.month);
                int day = ym.initPos - firstDay + 1;
                clickFunc(ym.year, ym.month, day);

                pageChangeCallback();

                setDefaultPosInPreAndNext(pos, day);
            },
            controller: mPageController,
            itemBuilder: (BuildContext context, int index) {
                YearMonth choice = choices[index];
                var view = new CalendarItemPage(
                    new GlobalKey<CalendarItemPageState>(),
                        (int year, int month, int day, MonthType mt) {
                        int pos = getCurrentPos();

                        if (mt == MonthType.LastMonth) {
                            //若不是第一页，可跳转至上一页
                            if (pos > 0) {
                                var ym = choices[pos - 1];
                                ym.initPos =
                                    CalendarUtil.getStartPosOfMonth(
                                        ym.year, ym.month) + day - 1;
                                _nextPage(-1);
                            }
                        } else if (mt == MonthType.NextMonth) {
                            //若不是最后一页，可跳转到下一页
                            if (pos < choices.length - 1) {
                                var ym = choices[pos + 1];
                                ym.initPos =
                                    CalendarUtil.getStartPosOfMonth(
                                        ym.year, ym.month) + day - 1;
                                _nextPage(1);
                            }
                        } else { //当月
                            clickFunc(year, month, day);
                            setDefaultPosInPreAndNext(pos, day);
                        }
                    }
                    , ym: choice);


                return view;
            }
        );
        return pageView;
    }

    ///设置前一个月，后一个月的默认显示的日期
  void setDefaultPosInPreAndNext(int pos, int day) {
      if (pos > 0) {
          var ym = choices[pos - 1];
          CalendarUtil.setMonthInitCount(ym, day);
      }

      if (pos < choices.length - 1) {
          var ym = choices[pos + 1];
          CalendarUtil.setMonthInitCount(ym, day);
      }
  }

  ///获取视图当前显示的年月
  YearMonth getCurrentShowYearMonth()
  {
      int pos = getCurrentPos();
      if(pos >= 0)
          {
              return choices[pos];
          }else
              {
                  return null;
              }
  }

}

class CalendarItemPage extends StatefulWidget {
    YearMonth ym;
    Function clickFunc = () => {};
    CalendarItemPage(Key key, this.clickFunc, {this.ym}):super(key:key);
    @override
    State<StatefulWidget> createState() => CalendarItemPageState(key, clickFunc, ym:ym);
}

class CalendarItemPageState extends State<CalendarItemPage> {
    YearMonth ym;
    GlobalKey<CalendarItemPageState> _globalKey;
    Function clickFunc = () => {};

    CalendarItemPageState(this._globalKey, this.clickFunc, {this.ym});

    @override
    Widget build(BuildContext context) {
        //指定月份在网格中对应的数据
        var dataList = CalendarUtil._initMonthData(ym.year, ym.month);
        return Container(
                child: GestureDetector(
                    onTapUp: (TapUpDetails details) {
                        //点击，通知更新视图
                        setState(() {
                            RenderBox renderBox = _globalKey?.currentContext?.findRenderObject();
                            //获取日历视图的大小
                            var viewSize = renderBox.size;
                            //获取日历视图全局坐标
                            var offset =  renderBox.localToGlobal(Offset.zero);

                            var pos = details?.globalPosition;
                            //获取点击位置在日历视图中的相对位置坐标值，所以x，y 需要减去日历的x， y
                            var posInView = Offset(pos.dx - offset.dx, pos.dy - offset.dy);
                            int clickPos = LabelViewPainter.getClickItemPos(posInView, viewSize.width);

                            if(clickPos >= 0)
                            {
                                ym.initPos = clickPos;
                                var item = dataList[clickPos];
                                clickFunc(item.year, item.month, item.day, item.monthType);
                            }

                        });
                    },
                    child:
                        CustomPaint(
                            painter: new LabelViewPainter(this.ym, ym.initPos, clickFunc, dataList),
                            child: Center( child: Text(""))
                        )
                    ,
                )
        );

    }
}

class LabelViewPainter extends CustomPainter {

    //圆圈半径
    static final double circleRadius = 20.0;

    List<ItemData> _datas;

    //当前点击位置
    int clickPos = -1;

    Function clickFunc = () => {};

    YearMonth ym;

    LabelViewPainter(this.ym, int clickPos, Function clickFunc, this._datas) {
        this.clickPos = clickPos;
        this.clickFunc = clickFunc;
    }


    @override
    void paint(Canvas canvas, Size size) {
        var viewWidth = size.width;
        var sigleWidth = viewWidth / 7;

        for(var i = 0;i < _datas.length;i++)
        {
            //获取列号
            var rowPos = i % 7;
            //获取行号, ~/ 相当于整除
            var linePos = i ~/ 7;
            var posX = sigleWidth * rowPos + (sigleWidth/2);
            var posY = circleRadius + linePos * circleRadius * 2;
            var txtColor = Colors.black;
            
            if(_DEBUG)
                {
                    var itemBgColor = i % 2 == 0?Colors.green:Colors.yellow;
                    var rect = Rect.fromLTRB(sigleWidth * rowPos, linePos * circleRadius * 2, sigleWidth * (rowPos + 1), (linePos + 1) * circleRadius * 2);
                    canvas.drawRect(rect, new Paint()..color = itemBgColor .. style = PaintingStyle.fill);
                }

            switch (_datas[i].monthType)
            {
                case MonthType.CurrentMonth:
                    txtColor = Colors.black;
                    break;
                default:
                    txtColor = Colors.grey;
                    break;
            }

            //显示点击位置的圆圈
            if(i == clickPos)
            {
                var paint = Paint()
                    ..color = Colors.blue
                    ..isAntiAlias = true
                    ..style = PaintingStyle.stroke;

                paint..style = PaintingStyle.fill;
                txtColor = Colors.white;
                canvas.drawCircle(Offset(posX, posY), circleRadius, paint);
            }

            TextSpan span = new TextSpan(style: TextStyle(color: txtColor), text: "${_datas[i].day}");
            TextPainter tp = new TextPainter(text:span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
            tp.layout();

            tp.paint(canvas, Offset(posX - tp.width / 2, posY - tp.height / 2));
        }

    }

    @override
    bool shouldRepaint(CustomPainter oldDelegate) {
        //oldDelegate 从来不可能为null
        var old = oldDelegate as LabelViewPainter;
        int oldPos = old.clickPos;
        //当点击位置更新时，更新视图
        return clickPos != oldPos;
    }

    ///获取视图高度
    static double getHeight()
    {
        return 6 * circleRadius * 2;
    }

    ///获取点击的坐标所在数据的位置索引
    ///viewWidth 为日历视图宽度
    static int getClickItemPos(Offset _currentClickCoord, double viewWidth) {
        //单行高度
        double rowHeight = circleRadius * 2;
        if(_currentClickCoord == null)
        {
            return -1;
        }
        var posX = _currentClickCoord.dx;
        var posY = _currentClickCoord.dy;
        //列数向下取整
        var columnPos = (posX/(viewWidth/7)).floor();
        //行数向下取整
        var rowPos = (posY/rowHeight).floor();

        var isInRange = (columnPos >= 0 && columnPos < 7 && rowPos >= 0 && rowPos < 6);
        if(isInRange)
        {
            int pos = rowPos * 7 + columnPos;
            return pos;
        }else
        {
            return -1;
        }
  }
}

class ItemData
{
    int year;
    int month;
    int day;
    MonthType monthType;//-1:上一个月， 0:本月， 1:下一个月
    ItemData({this.monthType = MonthType.CurrentMonth, this.year, this.month, this.day});
}

enum MonthType
{
    LastMonth,//上一月
    CurrentMonth,//当月
    NextMonth//下一月
}

class YearMonth
{
    int year, month;
    //网格中默认显示的位置
    int initPos;
    YearMonth(this.year, this.month, {this.initPos = -1});
}

class CalendarUtil
{
    ///获取某个年月的1号在网格中的位置索引
    static int getStartPosOfMonth(int year, int month)
    {
        int startPos = DateTime(year, month, 1).weekday;
        //日历视图以星期日开始，故当为sunday，即7时初始位置为0
        if(startPos == DateTime.sunday)
        {
            startPos = 0;
        }
        return startPos;
    }

    ///获取某个年月在网格中对应的数据
    static List<ItemData> _initMonthData(int year, int month)
    {
        List<ItemData> _datas = new List();
        //当前指定月的上一个月的天数
        int previousMonthDays = getPreviousMonthDay(year, month);
        //当前指定月的天数
        int curMonthDays = getCurMonthDay(year, month);
        //当前指定月1号在网格中的位置索引
        int startPos = getStartPosOfMonth(year, month);
        //获取当前一个月所指年月
        List<int> previousMonthValue = getPreviousMonth(year, month);
        //获取下一个月所指年月
        List<int> nextMonthValue = getNextMonth(year, month);

        //添加上一个月的数据
        for(var i = startPos - 1;i >= 0;i--)
        {
            var item = ItemData(monthType:MonthType.LastMonth, year:previousMonthValue[0], month:previousMonthValue[1]
                , day:previousMonthDays - i);
            _datas.add(item);
        }
        //添加当前月的数据
        for(var i = 1;i <= curMonthDays;i++)
        {
            var item = ItemData(year:year, month:month, day:i);
            _datas.add(item);
        }
        //添加下一个月的数据，个数等于42减去当前数据个数
        var remainCount = 42 - _datas.length;
        for(var i = 1;i <= remainCount;i++)
        {
            var item = ItemData(monthType:MonthType.NextMonth, year:nextMonthValue[0], month:nextMonthValue[1]
                , day:i);
            _datas.add(item);
        }
        return _datas;
    }

    ///获取与指定年月的前一个月的所在年月，0位置值为年，1位置值为月
    static List<int> getPreviousMonth(int year, int month)
    {
        if(month == 1)
        {
            year -= 1;
            month = 12;
        }else {
            month -= 1;
        }
        return [year, month];
    }
    ///获取与指定年月的下一个月的所在年月，0位置值为年，1位置值为月
    static List<int> getNextMonth(int year, int month)
    {
        if(month == 12)
        {
            year += 1;
            month = 1;
        }else {
            month += 1;
        }
        return [year, month];
    }

    ///获取指定月的上一个月的天数
    static int getPreviousMonthDay(int year, int month)
    {
        List<int> previousMonthValue = getPreviousMonth(year, month);
        var curMonth = DateTime(year, month, 1);
        DateTime previousMonth = DateTime(previousMonthValue[0], previousMonthValue[1], 1);
        var betweenDays = curMonth.difference(previousMonth).inDays;
        return betweenDays;
    }

    ///获取指定月的天数
    static int getCurMonthDay(int year, int month)
    {
        List<int> nextMonthValue = getNextMonth(year, month);
        var curMonth = DateTime(year, month, 1);
        DateTime nextMonth = DateTime(nextMonthValue[0], nextMonthValue[1], 1);
        var betweenDays = nextMonth.difference(curMonth).inDays;
        return betweenDays;
    }

    ///设置某个年月初始显示几号
    static void setMonthInitCount(YearMonth ym, int day)
    {
        int ymDayCount = getCurMonthDay(ym.year, ym.month);
        if(day > ymDayCount){
            day = ymDayCount;
        }
        ym.initPos = getStartPosOfMonth( ym.year, ym.month) + day - 1;
    }

}

/// 显示月份选择切换对话框
void _showSelectMonthDialog(BuildContext ctx, Function fun)
{
    var year = 0;
    var month = 0;
    showDialog(context: ctx, builder: (ctx){
        var currentYear = DateTime.now().year;
        var listYear = List<String>.generate(61, (int index) => "${currentYear - 30 + index}");
        var listMonth = List<String>.generate(12, (int index) => "${index + 1}");
        // 对话框视图默认填充整个屏幕c
        return Container(
            alignment: Alignment.bottomCenter,
            child: Container(//要设置背景色
                color: Colors.white,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                FlatButton(child: Text(" 取消 ", style: TextStyle(color: Colors.blue)), onPressed: (){Navigator.of(ctx).pop();}),
                                FlatButton(child: Text(" 确定 ", style: TextStyle(color: Colors.blue)), onPressed: (){
                                    fun(year, month);
                                    Navigator.of(ctx).pop();

                                })
                            ],
                        ),

                        Container(
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children:<Widget>[

                                    Container(
                                        width: 100,
                                        child:
                                        WheelView(0, listYear, (int pos, String str){
                                            year = num.parse(str);
                                            print("$pos = $str");
                                        })
                                        ,),

                                    Text("年", style: TextStyle(color: Colors.black, fontSize: 15),),

                                    Container(
                                        width: 100,
                                        child:
                                        WheelView(0, listMonth,  (int pos, String str){
                                            month = num.parse(str);
                                            print("$pos = $str");
                                        })
                                    ),

                                    Text("月", style: TextStyle(color: Colors.black, fontSize: 15)),

                                ]
                            ),
                        )



                    ],),
            ),
        );
    });
}
