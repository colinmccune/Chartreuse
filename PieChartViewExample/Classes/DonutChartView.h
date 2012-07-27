//
//  DonutChart.h
//
//  Created by Dain on 7/23/10.
//  Copyright 2010 Dain Kaplan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
	float red;
	float green;
	float blue;
	float alpha;
} DonutChartItemColor;

CG_INLINE DonutChartItemColor
DonutChartItemColorMake(float r, float g, float b, float a)
{
	DonutChartItemColor c; c.red = r; c.green = g; c.blue = b; c.alpha = a; return c;
}

@interface DonutChartView : UIView {	
	NSMutableArray *_donutItems;
	float _sum;
	DonutChartItemColor _noDataFillColor;
	DonutChartItemColor _gradientFillColor;
	
	float _gradientStart;
	float _gradientEnd;
}

- (void)clearItems;
- (void)addItemValue:(float)value withColor:(DonutChartItemColor)color;
- (void)setNoDataFillColorRed:(float)r green:(float)g blue:(float)b;
- (void)setNoDataFillColor:(DonutChartItemColor)color;
- (void)setGradientFillColorRed:(float)r green:(float)g blue:(float)b;
- (void)setGradientFillColor:(DonutChartItemColor)color;

// Values ranging from 0.0-1.0 specifying where to begin/end the fills. 
// E.g. A start of 0.0 starts at the top of the Donutchart, and 0.3 starts a third of the way from the top.
- (void)setGradientFillStart:(float)start andEnd:(float)end;

@end
