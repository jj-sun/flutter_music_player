import 'dart:convert';
import 'dart:math';
import 'dart:core';
import 'package:encrypt/encrypt.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:flutter_music_player/utils/rsa_no_padding_encoding.dart';


class CryptoUtil {

  static String aesEncrypt(String text,String key,String iv) {
    // const keyutf = CryptoJS.enc.Utf8.parse(key);
    // const ivBin = CryptoJS.enc.Utf8.parse(iv);
    // const enc = CryptoJS.AES.encrypt(text, keyutf, {
    //   iv: ivBin,
    //   mode: CryptoJS.mode.CBC,
    // });
    // const encStr = enc.toString();
    //
    // return encStr;
    Key keyutf = Key.fromUtf8(key);

    IV ivBin = IV.fromUtf8(iv);

    final encrypter = Encrypter(AES(keyutf, mode: AESMode.cbc));
    var enc = encrypter.encrypt(text, iv: ivBin);
    var encStr = enc.base64.toString(); //需要用64位的
    return encStr;
  }

  static String rsaEncrypt(String text,String key) {
    /*const rsaEncryptObject = new JSEncrypt({ padding: 'RSA_ZERO_PADDING' });

    rsaEncryptObject.setPublicKey(key);
    String secKey = rsaEncryptObject.encrypt(text);
    String buf = CryptoJS.enc.Base64.parse(secKey);  //解密

    return CryptoJS.enc.Hex.stringify(buf);*/

    RSAPublicKey rsaPublicKey = RSAKeyParser().parse(key) as RSAPublicKey;


    final encrypter = Encrypter(RSAExt(publicKey: rsaPublicKey));
    Encrypted secKey = encrypter.encrypt(text);

    //Uint8List buf = base64Decode(secKey.base64);
    return hex.encode(secKey.bytes);
  }

  static String reverseString(String str) {
    return str
        .split('')
        .reversed
        .join('');
  }

  static String getRandomBase62(int length) {
    String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String result = '';

    for (int i = length; i > 0; --i) {
      int charLength = chars.length;
      int random = Random().nextInt(charLength) ;
      result += chars[random];
    }
    return result;
  }

  static Map<String, dynamic> weapi(object) {
    const iv = '0102030405060708';
    const presetKey = '0CoJUm6Qyw8W8jud';
    const publicKey =
        '-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB\n-----END PUBLIC KEY-----';

    String text = jsonEncode(object);
    String secretKey = getRandomBase62(16);

    print('随机字符串:${secretKey}');

    return <String, dynamic>{
      'params': aesEncrypt(aesEncrypt(text, presetKey, iv),secretKey,iv),
      'encSecKey': rsaEncrypt(reverseString(secretKey), publicKey)
    };
  }

}
