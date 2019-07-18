/*
 * author: Created by 黄晓辉 on 2019/07/13.
 * email: 582087924@qq.com
 *  简单的自定义列表滚轮控件
 */

import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';

//是否开启调试模式
bool _DEBUG = true;

class WheelView extends StatelessWidget
{
    int initPos;
    Function onClickAt;
    List<String> arr;

    WheelView(this.initPos, this.arr, this.onClickAt);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
        height: WheelPaint.getViewHeight(),
        child: new WheelContent(initPos, onClickAt, arr),
    );
  }

}

class WheelContent extends StatefulWidget
{
    int initPos = 0;
    Function onClickAt = ()=>{};
    var arr = new List<String>();
    WheelContent(this.initPos, this.onClickAt, this.arr);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new WheelContentState(initPos, onClickAt, arr);
  }

}

class WheelContentState extends State<WheelContent> with SingleTickerProviderStateMixin<WheelContent>
{
    AnimationController animController;
    Animation<double> animation;

    double offsetTop = 0;
    Offset delta;
    var arr = new List<String>();
    var initPos = 0;
    Function onClickAt;
    WheelContentState(this.initPos, this.onClickAt, this.arr)
    {
      animController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));

      animController..addListener(() {
        if(animation == null)
          {
            return;
          }
        print("animation value:${animation.value}");
        offsetTop = animation.value;
        //通知刷新
        setState(() {
        });
      });

      animController.addStatusListener((AnimationStatus status)
      {
        print("动画当前状态：$status");
        //动画完成时，调用回调方法
        if(status == AnimationStatus.completed)
          {
            int pos = WheelPaint.getCenterPos(offsetTop);
            onClickAt(pos, arr[pos]);
          }
      });

      scrollTo(initPos);
      onClickAt(initPos, arr[initPos]);
    }

    ///
    /// 执行动画
    /// dura:动画执行时间
    void startAnimation(double b, double e, int dura)
    {
      animController.reset();

      //Curves.decelerate 减速
      Animation curve =  new CurvedAnimation(parent: animController, curve: Curves.decelerate);

      animation = new Tween(begin: b, end: e).animate(curve);

      animController.duration = Duration(milliseconds: dura);

      animController.forward();
    }

    void scrollTo(int pos)
    {

        if(pos < 0 || pos >= arr.length)
            {
                return;
            }
        offsetTop = -lineHeight * pos;
    }

    @override
    dispose() {
      animController.dispose();
      super.dispose();
    }



  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerMove: (PointerMoveEvent event)
        {
          delta = event.delta;
            offsetTop += delta.dy;

            if(offsetTop > 0)
            {
                offsetTop = 0;
            }else if(offsetTop < -(arr.length - 1) * lineHeight)
            {
                offsetTop = -(arr.length - 1).toDouble() * lineHeight;
            }else{
                //如果offsetTop的值是正常的，则刷新视图
                setState(() {

                });
            }
//            print("event move:$lastY  $offsetTop");
        },

        onPointerDown: (PointerDownEvent event)
        {
            animController.stop();
        },

        onPointerUp: (PointerUpEvent event)
        {
            int pos = WheelPaint.getCenterPos(offsetTop);
            //经测试，滑动较快的时候delta.dy 的绝对值差不多为50，这里就取个大概的倍数
            var percent = delta.dy~/10;
            if(percent > 5)
            {
                percent = 5;
            }

            //计算滑动后会到的位置索引，这里需要判断不超出范围， 这里的2是大概给的值，值越大滚动距离越长。
            //因为delta.dy大于0时手指向下移动，列表往上滚动；delta.dy小于0时手指向上移动，列表往下滚动，所以下面取负号
            pos -= (percent * 2);

            if(pos < 0)
            {
                pos = 0;
            }

            if(pos >= arr.length)
            {
                pos = arr.length - 1;
            }

            //计算要滚动到的位置的offsetTop
            var newoffsetTop = -lineHeight * pos;
            //计算动画执行的时间，至少200毫秒
            var dura= (percent * 200).abs();
            if(dura < 200){
               dura = 200;
            }

            print("startOffsetTop:$offsetTop");

            startAnimation(offsetTop, newoffsetTop, dura);

//            print("event up:$pos");
        },

        onPointerCancel: (PointerCancelEvent event)
        {
//            print("event cancel:$event");

        },

        child: Container(
            width: null,
            height: null,
            child: new CustomPaint(
                painter: new WheelPaint(offsetTop, arr)
            ),
        ),
    );;
  }

}


const double lineHeight = 50;

class WheelPaint extends CustomPainter
{
    double offsetTop = 0;
    List<String> arr;
    WheelPaint(this.offsetTop, this.arr);

  @override
  void paint(Canvas canvas, Size size) {

    double width = size.width;
    double height = size.height;

    //在某个区域内绘制，超出范围不绘制
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height), clipOp: ClipOp.intersect);

    if(_DEBUG)
        {
            canvas.drawColor(Colors.blueGrey, BlendMode.src);
        }

    int centerPos = getCenterPos(offsetTop);
    double centerY = height / 2;
    double centerTextSize = 25;

    for(int i = 0;i < arr.length;i++)
      {
        double itemStartY = i * lineHeight + (height - lineHeight) / 2 + offsetTop;
        //绘制开始位置大于视图高度的不绘制
        if(itemStartY > height)
            {
                break;
            }
        //
        if(itemStartY > -lineHeight)
            {
                double txtCenterY = itemStartY + lineHeight / 2;
                double percent = (txtCenterY - centerY).abs()/(height / 2);

                double txtSize = centerTextSize - (16 * percent) ;

                //黑色，透明度从0.1到1
                double opacity = 1 - percent;
                if(opacity <= 0.1)
                  {
                    opacity = 0.1;
                  }
                var txtColor = Color.fromRGBO(0, 0, 0, opacity);
                if(i == centerPos)
                {
                  txtColor = Colors.blueAccent;
                }

                TextSpan ts = new TextSpan(style: TextStyle(color: txtColor, fontSize: txtSize), text: arr[i]);
                TextPainter tp = new TextPainter(text:ts, textAlign:TextAlign.center, textDirection:TextDirection.ltr);
                tp.layout();

                if(_DEBUG)
                    {
                        var color = i % 2 == 0?Colors.yellow:Colors.green;
                        canvas.drawRect(Rect.fromLTRB(0, itemStartY, width, itemStartY + lineHeight), new Paint()..color = color);
                        canvas.drawLine(Offset(0, itemStartY + lineHeight / 2), Offset(width, itemStartY + lineHeight / 2), new Paint()..color = Colors.white);
                    }

                tp.paint(canvas, Offset((width - tp.width)/2, itemStartY + (lineHeight - tp.height)/2));
//                print("item $i ${arr[i]}");
            }
      }

    if(_DEBUG)
    {
        //画出中间线
        canvas.drawLine(Offset(0, height / 2), Offset(width, height / 2), Paint()..color = Colors.white ..style = PaintingStyle.fill);

        TextSpan ts = new TextSpan(style: TextStyle(color: Colors.red, fontSize: 9), text: "${offsetTop.toInt()}");
        TextPainter tp = new TextPainter(text:ts, textAlign:TextAlign.center, textDirection:TextDirection.ltr);
        tp.layout();

        tp.paint(canvas, Offset((width - tp.width)/2, (height - tp.height)/2));
  }

  }

  ///获取视图高度
  static double getViewHeight()
  {
      return lineHeight * 5;
  }

  ///获取offsetTop为某个值时滚轮滚动到的位置索引
    static int getCenterPos(double offsetTop)
    {
        //向下取整
        int pos = ((offsetTop - lineHeight / 2).abs()/lineHeight).floor();
        return pos;
    }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {

    return true;
  }

}