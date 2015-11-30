# OAUClock

[![CI Status](http://img.shields.io/travis/Austin Ugbeme/OAUClock.svg?style=flat)](https://travis-ci.org/Austin Ugbeme/OAUClock)
[![Version](https://img.shields.io/cocoapods/v/OAUClock.svg?style=flat)](http://cocoapods.org/pods/OAUClock)
[![License](https://img.shields.io/cocoapods/l/OAUClock.svg?style=flat)](http://cocoapods.org/pods/OAUClock)
[![Platform](https://img.shields.io/cocoapods/p/OAUClock.svg?style=flat)](http://cocoapods.org/pods/OAUClock)

![](clockscreenshot.png?raw=true "OAUClock screenshot")

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* iOS 7.0
* Xcode 7.0
* ARC

## Installation

OAUClock is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "OAUClock"
```

## Configuration

1. Import "OAUClock.h" into desired view controller:
	```objective-c
	#import "OAUClock.h"
	```

2. Initialize the clock. Typically in your `viewDidLoad` method:
	```objective-c
	self.clock = [[OAUClock alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
	[self.view addSubview:self.clock];
	```

2. Various configurations exist for OAUClock. Some example controls include:
	**To set the current hour/minute/sec respectively**
	```objective-c
	self.clock.hour = 10;
	self.clock.minute = 10;
	self.clock.seconds = 30;
	```

	**To control the AM/PM text**
	```objective-c
	self.clock.showMeridies = YES;
	self.clock.meridiesColor = [UIColor redColor];
	```
	**To allow clock track the devices' time**
	```objective-c
	self.clock.realTime = YES;
	```

## License

OAUClock is available under the MIT license. See the LICENSE file for more info.
