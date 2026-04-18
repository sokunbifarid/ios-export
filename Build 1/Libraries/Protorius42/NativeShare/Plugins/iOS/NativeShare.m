#import "NativeShare.h"

@implementation NativeShare{
}

extern UIViewController* UnityGetGLViewController();

+(id) withTitle:(char*)title withMessage:(char*)message{
	
	return [[NativeShare alloc] initWithTitle:title withMessage:message];
}

-(id) initWithTitle:(char*)title withMessage:(char*)message{
	
	self = [super init];
	
	if( !self ) return self;
	
	return self;
}

+(id) withText:(char*)text withURL:(char*)url withImage:(char*)image withSubject:(char*)subject withPackageName:(char*)packageName {
	
    return [[NativeShare alloc] initWithText:text withURL:url withImage:image withSubject:subject withPackageName:packageName];
}

-(id) initWithText:(char*)text withURL:(char*)url withImage:(char*)image withSubject:(char*)subject withPackageName:(char*)packageName {
	
	self = [super init];
	
	if( !self ) return self;
	
    self->err = NoError;
    
    NSString *mText = text ? [[NSString alloc] initWithUTF8String:text] : nil;
    //NSLog(@"mText %@", mText);
	
    NSString *mUrl = url ? [[NSString alloc] initWithUTF8String:url] : nil;
    //NSLog(@"mUrl %@", mUrl);
    
    NSString *mImage = image ? [[NSString alloc] initWithUTF8String:image] : nil;
    //NSLog(@"mImage %@", mImage);
    
    NSString *mSubject = subject ? [[NSString alloc] initWithUTF8String:subject] : nil;
    //NSLog(@"mSubject %@", mSubject);
    
    NSString *mPackageName = packageName ? [[NSString alloc] initWithUTF8String:packageName] : nil;
    //NSLog(@"mPackageName %@", mPackageName);
    
    
    /*
    if ([mPackageName isEqualToString:@"com.facebook.orca"]) {
        //NSString *str_url = [NSString stringWithFormat:@"fb-messenger://share/?link=%@", mText];
        NSString *str_url = [NSString stringWithFormat:@"https://m.me?text=www.google.com"];
      
        NSURL *url = [NSURL URLWithString:str_url];
        if ( [[UIApplication sharedApplication] canOpenURL:url] ) {
            [[UIApplication sharedApplication] openURL:url];
            NSLog(@"Messenger success!");
        }
        else {
            NSLog(@"Messenger error: url can not be opened!");
        }
        return self;
    }
    */
    
	NSMutableArray *items = [NSMutableArray new];
	
	if(mText != NULL && mText.length > 0){
		[items addObject:mText];
	}
	
	if(mUrl != NULL && mUrl.length > 0){
		
		NSURL *formattedURL = [NSURL URLWithString:mUrl];
		
        if (formattedURL) {
            [items addObject:formattedURL];
        }
        else {
            NSLog(@"Error URL is not valid!!!");
        }
	}
    
	if(mImage != NULL && mImage.length > 0){
		
		if([mImage hasPrefix:@"http"])
		{
			NSURL *urlImage = [NSURL URLWithString:mImage];
			
            NSError *error = nil;
            NSData *dataImage = [NSData dataWithContentsOfURL:urlImage options:0 error:&error];
            
            if (!error) {
                UIImage *imageFromUrl = [UIImage imageWithData:dataImage];
                [items addObject:imageFromUrl];
            }
            else
            {
                NSLog(@"Error Cannot load image");
                self->err = 1;
            }
        }
        else if ( [self isStringValideBase64:mImage])
        {
            NSData* imageBase64Data = [[NSData alloc] initWithBase64EncodedString:mImage options:0];
            UIImage* image = [UIImage imageWithData:imageBase64Data];
            if (image!= nil){
                [items addObject:image];
            }
            else
            {
                 NSLog(@"Error Cannot load image form base64");
                self->err = 2;
            }
        }
        else
        {
			NSFileManager *fileMgr = [NSFileManager defaultManager];
			if([fileMgr fileExistsAtPath:mImage]){
				
				NSData *dataImage = [NSData dataWithContentsOfFile:mImage];
				
				UIImage *imageFromUrl = [UIImage imageWithData:dataImage];
				
				[items addObject:imageFromUrl];
			}
            else
            {
                NSLog(@"Error Cannot find image");
                self->err = 3;
			}
		}
	}
	
	UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:Nil];
   
    NSMutableArray<UIActivityType> *types = [[NSMutableArray alloc] init];
    
    [types addObjectsFromArray:@[
        UIActivityTypeAssignToContact,
        UIActivityTypePrint,
        UIActivityTypeAddToReadingList,
        UIActivityTypeSaveToCameraRoll,
        UIActivityTypeOpenInIBooks,
        @"com.apple.mobilenotes.SharingExtension",
        @"com.apple.reminders.RemindersEditorExtension",
        @"com.apple.reminders.sharingextension",
        UIActivityTypeAirDrop,
        UIActivityTypeMarkupAsPDF
    ]];
    
    if ([mPackageName isEqualToString:@"com.facebook.orca"]) {
        [types addObjectsFromArray:@[
            UIActivityTypePostToTwitter,
            UIActivityTypePostToWeibo,
            UIActivityTypeMessage,
            UIActivityTypeMail,
            UIActivityTypeCopyToPasteboard,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]];
    }
    
    activity.excludedActivityTypes = types;
    
    if(mSubject != NULL) {
        [activity setValue:mSubject forKey:@"subject"];
    } else {
        [activity setValue:@"" forKey:@"subject"];
    }
	
	UIViewController *rootViewController = UnityGetGLViewController();
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [rootViewController presentViewController:activity animated:YES completion:Nil];
    }
    //if iPad
    else
    {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activity];
        [popup presentPopoverFromRect:CGRectMake(rootViewController.view.frame.size.width/2, rootViewController.view.frame.size.height/4, 0, 0)inView:rootViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    return self;
}

-(BOOL) isStringValideBase64:(NSString*)string {
    
    NSString *regExPattern = @"^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
    return regExMatches != 0;
}

# pragma mark - C API
NativeShare* instance;

int _ShowSocialSharing(struct NativeSharingStruct *confStruct) {
    instance = [NativeShare withText:confStruct->text withURL:confStruct->url withImage:confStruct->image withSubject:confStruct->subject withPackageName:confStruct->packageName];
    
    return instance->err;
}

@end
