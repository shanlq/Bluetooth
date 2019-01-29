//
//  NoBase64DES.h
//  DESEncryVC
//
//  Created by apple on 17/8/24.
//  Copyright © 2017年 slq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoBase64DES : NSObject

// 把一个byte数据转换为字符串
+(NSString *) parseByte2HexString:(Byte *) bytes;
// 把一个byte数组转换为字符串
+(NSString *) parseByteArray2HexString:(Byte[]) bytes;



// nsData 转16进制
+ (NSString*)stringWithHexBytes2:(NSData *)sender;



/****** 加密 ******/
+(NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key;
/****** 解密 ******/
+(NSString *) decryptUseDES:(NSString *)plainText key:(NSString *)key;

@end
