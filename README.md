# PictureFold
图片折叠，锚点anchorPoint,手势pan,渐变CAGradientLayer，CATransform3D的m34

![image](https://github.com/LiDami/PictureFold/blob/master/pictureFlod.gif)


### 图片折叠
	
##### 1.分析界面效果
		当鼠标在图片上拖动的时候,图片有一个折叠的效果.
		这种折叠效果其实就是图片的上半部分绕着X轴做一个旋转的操作.
		我们图片的旋转都是绕着锚点进行旋转的.所以如果是一张图片的,办不到只上图片的上半部分进行一个旋转.
		其实是两张图片, 把两张图片合成一张图片的方法, 
		实现方案.弄上下两张图片,上上部图片只显示上半部分, 下部图片只显示下半部分.
		
##### 	 2.如果让一张图片只显示上半部分或者下半部分?
		利用CALayer的一个属性contentsRect = CGRectMake(0, 0, 1, 0.5);
		contentsRect就是要显示的范围.它是取值范围是(0~1);
		想让上部图片只显示上半部分contentsRect设置CGRectMake(0, 0, 1, 0.5); 
		让下部图片只显示下半部分contentsRect设置为CGRectMake(0, 0.5, 1, 0.5)
		
##### 	 3.让上部图片绕着锚点进行旋转,但是图片的默认锚点在中心,所以要把上部图片的锚点设在最底部.
	 	修改上部分的锚点为anchorPoint = CGPointMake(0.5, 1)
	 	但是修过锚点之后, 会出现一个问题,就是上部分的图片,会往上走.导致两个图片中间有一个空隙.
	 	解决办法为.把两张图片放到一起.设置上部分图片的锚点后.上部分图片会上走一半的距离.
	 	然后再设置下部图片的锚点.设置上图片的最上面设置下部图片锚点值为anchorPoint = CGPointMake(0.5, 0);
		这样就能够办到两张图片合成一张的效果.
		
##### 	 4. 给上部图片添加手势.根据手指向下拖动的距离.来计算旋转的角度.
	 	拖动的时候,发现它的拖动范围为整个图片.所以添加手势的时候,不能只添加上部分或着下部分.
	 	可以弄一个跟View相同大小的的View,把手势添加给这个UIView.
	 	添加完手势时, 在手势方法当中去旋转上部分图片.
	 	要來计算旋转的角度,上半部分旋转的角度是根据手指向上拖动的Y值来决定.当手指到最下部时正好旋转180度.
	 	假设手指移动到最下部为200.那旋转角度应该为 angel =  transP.Y * M_PI / 200.0;
	 	
	 	
##### 	5. 拖动的时候让它有一个立体产效果
		立体的效果就是有一种近大远小的感觉.	
		想要设置立体效果.要修改它的TransForm当中的一个M34值,设置方式为
		弄一个空的TransFrom3D
		CATransform3D transform = CATransform3DIdentity; 
		200.0可以理解为，人的眼睛离手机屏幕的垂直距离，近大远小效果越明显
		transform.m34 = - 1 / 200.0;	
	 	transform = CATransform3DRotate(transform, angle, 1, 0, 0);
	 	相对上一次改了m34的形变,再去旋转
	 	为什么不用Make,make会让m34清空,这个地方不能让m34清空
	 	
##### 	6. 给下部分图片添加阴影的效果.阴影是有渐变的效果.是从透明到黑色的一个渐变.
		我们可以通过CAGradientLayer这个层来创建渐变.这个层我们就称它是一个渐变层.
		渐变层也是需要添加到一个层上面才能够显示.
		
		渐变层里面有一个colors属性.这个属性就是设置要渐变的颜色.它是一个数组.
		数组当中要求我们传入都是CGColorRef类型,所以我们要把颜色转成CGColor.
		但是转成CGColor后,数组就认识它是一个对象了,就要通过在前面加上一个(id)来告诉编译器是一个对象.
		
		可以设置渐变的方向:
		通过startPoint和endPoint这两个属性来设置渐变的方向.它的取值范围也是(0~1)
		
		 默认方向为上下渐变为:
         	gradientL.startPoint = CGPointMake(0, 0);
         	gradientL.endPoint = CGPointMake(0, 1);
         设置左右渐变
          	gradientL.startPoint = CGPointMake(0, 0);
          	gradientL.endPoint = CGPointMake(1, 0);
		
	 	可以设置渐变从一个颜色到下一个颜色的位置
	 	设置属性为locations = @[@0.3,@0.7]
	 	
	 	渐变层同时还有一个opacity属性.这个属性是调协渐变层的不透明度.它的取值范围同样也是0-1,
	 	当为0时代表透明, 当为1明,代码不透明.
	 	
	 	
	 	所以我们可以给下部分图片添加一个渐变层,渐变层的颜色为从透明到黑色.
	 	gradientL.colors = 
	 	@[(id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor];
	 	
	 	开始时没有渐变,所以可以把渐变层设为透明状态.
	 	之后随着手指向下拖动的时,渐变层的透明度跟着改变.
	 	
	 	当手指拖到最下面的时候,渐变层的透明度正好为1.所以要中间可以有一个比例.
	 	 CGFloat opacity  =  1 * transP.y / 200.0;
	 	在手指拖动的时候,设置它的不透度
	 	
	 	
##### 	7. 在手指拖动过程当中,松开手指时,有一个动画返弹回去的效果.
		所以我们要坚听手指的状态.当手势状态为结束时
		把渐变层的透明度设为透明
		把上部图片的旋转设为0,也就是清空之前的形变.
		
		同时加上一个返弹动画的效果.
		返弹动画添加方法为
		
			
			
		 Duration:动画的执行时长
		 delay:动画延时时长.
		 Damping:动画的弹性系数,越小,弹簧效果越明显
		 initialSpringVelocity:弹簧初始化速度
		 [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.1        												   initialSpringVelocity:0 
		 										options:UIViewAnimationOptionCurveLinear 
		 										animations:^{
        
        						动画执行代码    
        
      	  } completion:^(BOOL finished) {
            	动画完成时调用.
        }];
		
		
		
