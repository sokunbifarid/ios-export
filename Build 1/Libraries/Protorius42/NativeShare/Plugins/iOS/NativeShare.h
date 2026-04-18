#import <UIKit/UIKit.h>

@interface NativeShare : UIViewController
{
    UINavigationController *navController;
    int err;
}

struct NativeSharingStruct {
    char* url;
    char* text;
    char* subject;
    char* packageName;
    char* image; //TODO
};

typedef enum {
    NoError = 0,
    UnknownError = 100,
    NoImplemented = 101,
    ExceptionThrows = 102,
    TitleIsEmpty = 103,
    MessageIsEmpty = 104
} NativeShareErrorCode;

#ifdef __cplusplus
extern "C" {
#endif
    
    int _ShowNativeSharing(struct NativeSharingStruct *confStruct);
    
#ifdef __cplusplus
}
#endif


@end
