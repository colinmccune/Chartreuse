//
//  DonutChart.m
//
//  Created by Dain on 7/23/10.
//  Copyright 2010 Dain Kaplan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DonutChartView.h"

@interface DonutChartItem : NSObject
{
	DonutChartItemColor _color;
	float _value;
}

@property (nonatomic, assign) DonutChartItemColor color;
@property (nonatomic, assign) float value;

@end


@implementation DonutChartItem

- (id)init
{	
    if (self = [super init]) {
		_value = 0.0;
	}
	return self;
}

@synthesize color = _color;
@synthesize value = _value;

@end


@interface DonutChartView()
// Private interface
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
- (UIImage *)createCircleMaskUsingCenterPoint:(CGPoint)point andRadius:(float)radius;
- (UIImage *)createGradientImageUsingRect:(CGRect)rect;
@end

@implementation DonutChartView


- (id)initWithFrame:(CGRect)aRect
{	
    if (self = [super initWithFrame:aRect]) {
		_gradientFillColor = DonutChartItemColorMake(0.0, 0.0, 0.0, 0.4);
		_gradientStart = 0.3;
		_gradientEnd = 1.0;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

// XXX: In the case this view is being loaded from a NIB/XIB (and not programmatically)
// initWithCoder is called instead of initWithFrame:
- (id)initWithCoder:(NSCoder *)decoder
{	
    if (self = [super initWithCoder:decoder]) {
		_gradientFillColor = DonutChartItemColorMake(0.0, 0.0, 0.0, 0.4);
		_gradientStart = 0.3;
		_gradientEnd = 1.0;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)clearItems 
{
	if( _donutItems ) {
		[_donutItems removeAllObjects];	
	}
	
	_sum = 0.0;
}

- (void)addItemValue:(float)value withColor:(DonutChartItemColor)color
{
	DonutChartItem *item = [[DonutChartItem alloc] init];
	
	item.value = value;
	item.color = color;
	
	if( !_donutItems ) {
		_donutItems = [[NSMutableArray alloc] initWithCapacity:3];
	}
	
	[_donutItems addObject:item];
	
	[item release];
	
	_sum += value;
}

- (void)setNoDataFillColorRed:(float)r green:(float)g blue:(float)b
{
	_noDataFillColor = DonutChartItemColorMake(r, g, b, 1.0);
}

- (void)setNoDataFillColor:(DonutChartItemColor)color
{
	_noDataFillColor = color;
}

- (void)setGradientFillColorRed:(float)r green:(float)g blue:(float)b
{
	_gradientFillColor = DonutChartItemColorMake(r, g, b, 0.4);
}

- (void)setGradientFillColor:(DonutChartItemColor)color
{
	_gradientFillColor = color;
}

- (void)setGradientFillStart:(float)start andEnd:(float)end
{
	_gradientStart = start;
	_gradientEnd = end;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	
	float startDeg = 0;
	float endDeg = 0;
	
	int x = self.center.x;
	int y = self.center.y;
	int r = (self.bounds.size.width>self.bounds.size.height?self.bounds.size.height:self.bounds.size.width)/2 * 0.8;
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(ctx, 1.0);

	
	// Loop through all the values and draw the graph
	startDeg = 0;
	
	NSLog(@"Total of %d donut items to draw.", [_donutItems count]);
	
	NSUInteger idx = 0;
	for( idx = 0; idx < [_donutItems count]; idx++ ) {
		
		DonutChartItem *item = [_donutItems objectAtIndex:idx];
		
		DonutChartItemColor color = item.color;
		float currentValue = item.value;
		
		float theta = (360.0 * (currentValue/_sum));
		
		if( theta > 0.0 ) {
			endDeg += theta;
			
			NSLog(@"Drawing arc [%d] from %f to %f.", idx, startDeg, endDeg);
			
			if( startDeg != endDeg ) {
				CGContextSetRGBFillColor(ctx, color.red, color.green, color.blue, color.alpha );
				CGContextMoveToPoint(ctx, x, y);
				CGContextAddArc(ctx, x, y, r, (startDeg-90)*M_PI/180.0, (endDeg-90)*M_PI/180.0, 0);
				CGContextClosePath(ctx);
				CGContextFillPath(ctx);
			}
		}
		
		startDeg = endDeg;
	}
	
	// Draw the remaining portion as a no-data-fill color, though there should never be one. (current code doesn't allow it)
	if( endDeg < 360.0 ) {
		
		startDeg = endDeg;
		endDeg = 360.0;
		
		NSLog(@"Drawing bg arc from %f to %f.", startDeg, endDeg);
		
		if( startDeg != endDeg ) {
			CGContextSetRGBFillColor(ctx, _noDataFillColor.red, _noDataFillColor.green, _noDataFillColor.blue, _noDataFillColor.alpha );
			CGContextMoveToPoint(ctx, x, y);
			CGContextAddArc(ctx, x, y, r, (startDeg-90)*M_PI/180.0, (endDeg-90)*M_PI/180.0, 0);
			CGContextClosePath(ctx);
			CGContextFillPath(ctx);
		}	
	}
	
	// Now we want to create an overlay for the gradient to make it look *fancy*
	// We do this by:
	// (0) Create circle mask
	// (1) Creating a blanket gradient image the size of the DonutChart
	// (2) Masking the gradient image with a circle the same size as the DonutChart
	// (3) compositing the gradient onto the DonutChart
	
  /*
	// (0)
	UIImage *maskImage = [self createCircleMaskUsingCenterPoint: CGPointMake(x, y) andRadius: r];
	
	// (1)
	UIImage *gradientImage = [self createGradientImageUsingRect: self.bounds];
	
	// (2)
	UIImage *fadeImage = [self maskImage:gradientImage withMask:maskImage];
	
	// (3)
	CGContextDrawImage(ctx, self.bounds, fadeImage.CGImage);
	*/
	// Finally set shadows
  
  //Draw Donut, with stroke
	CGContextSetLineWidth(ctx, 1.0);
  CGContextSetRGBFillColor(ctx, 1, 1, 1, 1 );
  CGContextAddArc(ctx, x, y, r-10, 0.0, 360.0*M_PI/180.0, 0);
	CGContextClosePath(ctx);
  CGContextFillPath(ctx);
  

}


- (void)dealloc {
	[_donutItems release];
    [super dealloc];
}

@end
