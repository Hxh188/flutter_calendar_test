/*
 * author: Created by 黄晓辉 on 2019/07/13.
 * email: 582087924@qq.com
 *  简单的自定义列表滚轮控件
 */

import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';

bool DEBUG = true;

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
            var percent = delta.dy~/10;
            if(percent > 5)
            {
                percent = 5;
            }

            if(delta != 0)
              {
                pos -= (percent * 2);
              }
              if(pos < 0)
                {
                  pos = 0;
                }

                if(pos >= arr.length)
                  {
                    pos = arr.length - 1;
                  }


            var newoffsetTop = -lineHeight * pos;
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
    static bool debug = true;
    double offsetTop = 0;
    List<String> arr;
    WheelPaint(this.offsetTop, this.arr);

  @override
  void paint(Canvas canvas, Size size) {

    double width = size.width;
    double height = size.height;

    //在某个区域内绘制，超出范围不绘制
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height), clipOp: ClipOp.intersect);

    if(DEBUG)
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

                if(DEBUG)
                    {
                        var color = i % 2 == 0?Colors.yellow:Colors.green;
                        canvas.drawRect(Rect.fromLTRB(0, itemStartY, width, itemStartY + lineHeight), new Paint()..color = color);
                        canvas.drawLine(Offset(0, itemStartY + lineHeight / 2), Offset(width, itemStartY + lineHeight / 2), new Paint()..color = Colors.white);
                    }

                tp.paint(canvas, Offset((width - tp.width)/2, itemStartY + (lineHeight - tp.height)/2));
//                print("item $i ${arr[i]}");
            }
      }

    if(DEBUG)
    {
        canvas.drawLine(Offset(0, height / 2), Offset(width, height / 2), Paint()..color = Colors.red ..style = PaintingStyle.fill);

        TextSpan ts = new TextSpan(style: TextStyle(color: Colors.red, fontSize: 9), text: "$offsetTop");
        TextPainter tp = new TextPainter(text:ts, textAlign:TextAlign.center, textDirection:TextDirection.ltr);
        tp.layout();

        tp.paint(canvas, Offset((width - tp.width)/2, (height - tp.height)/2));
  }

  }

  static double getViewHeight()
  {
      return lineHeight * 5;
  }

    static int getCenterPos(double offsetTop)
    {
        int pos = ((offsetTop - lineHeight / 2).abs()/lineHeight).floor();
        return pos;
    }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {

    return true;
  }

}