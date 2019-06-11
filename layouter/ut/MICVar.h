//
//  MICVar.h
//  今まで、だれも考えつかなかった、var/let 型を定義してしまおうという極めて野心的かつ革新的なヘッダーファイル
//  __I_LIKE_KOTLIN__をdefineしてから、importすれば、val も使えるよ。
//
//  Created by @toyota-m2k on 2018/10/11.
//  Copyright  2018年 @toyota-m2k Corporation. All rights reserved.
//

#ifndef MICVar_h
#define MICVar_h

#define var __auto_type
#define let __auto_type const

#ifdef __I_LIKE_KOTLIN__
#define val __auto_type const
#endif

#endif /* MICVar_h */
