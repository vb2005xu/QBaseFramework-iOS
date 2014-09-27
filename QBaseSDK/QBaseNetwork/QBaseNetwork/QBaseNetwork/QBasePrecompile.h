//
//  QBasePrecompile.h
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#ifndef QBaseFramework_QBasePrecompile_h
#define QBaseFramework_QBasePrecompile_h

//单例宏定义
#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;


//#if (!__has_feature(objc_arc)) \
//todo:把【aa new】也放到里面
#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}


#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)instance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)instance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

CG_INLINE void DEBUG_NSLOG (NSString *format, ...)
{
    
#if DEBUG
    va_list args;
    va_start(args,format);
    if (format != nil)
    {
        NSLogv(format, args);
    }
#endif
    
}

#endif
