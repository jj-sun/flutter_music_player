
import 'dart:developer';

import 'package:flutter_music_player/api/provider/netease.dart';
import 'package:flutter_music_player/utils/request_util.dart';
import 'package:flutter_music_player/utils/rsa_no_padding_encoding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:core';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/asymmetric/api.dart';

void main() {

  test('dio', () async {
    await NeteaseUtil.showPlaylist(0).then((value) {
      print('结果: ${value.toString()}');
    });
  });

  test('ceshijiekou ', () async {


    await RequestUtil.getAction('http://172.16.0.252:8081/lx_exam/api/dingtalk/testApi').then((value){
      print(value);
    });
  });

  test('AES加密测试', () {

    Map<String, dynamic> query = {
      'cat': '全部',
      'order': 'hot',
      'limit': 30,
      'offset': 0,
      'total': true
    };


    String key = "0CoJUm6Qyw8W8jud";

    String iv = "0102030405060708";

    Key keyutf = Key.fromUtf8(key);

    IV ivBin = IV.fromUtf8(iv);

    final encrypter = Encrypter(AES(keyutf, mode: AESMode.cbc));
    var enc = encrypter.encrypt(jsonEncode(query), iv: ivBin);

    print(enc.bytes);
    print(enc.base16);
    print(enc.base64);
  });

  test('RSA加密', () {

      String text = '1234123412341234';

      String key =
          '-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB\n-----END PUBLIC KEY-----';

      RSAPublicKey rsaAsymmetricKey = RSAKeyParser().parse(key)  as RSAPublicKey;

      print('公钥：${rsaAsymmetricKey.publicExponent}');

      final encrypter = Encrypter(RSA(publicKey: rsaAsymmetricKey,encoding: RSAEncoding.values.single));
      Encrypted secKey = encrypter.encryptBytes(text.codeUnits);

      print('base64:${secKey.base16}');

      Uint8List buf = base64Decode(secKey.base64);
      //print(buf.length);
       String str= hex.encode(buf.toList());
       print(str);
     // print(hex.encode(secKey.bytes));


  });

  test('rsa自定义解密', (){
    String text = '1234123412341234';

    String key =
        '-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB\n-----END PUBLIC KEY-----';

    RSAPublicKey rsaAsymmetricKey = RSAKeyParser().parse(key)  as RSAPublicKey;
    final encrypter = Encrypter(RSAExt(publicKey: rsaAsymmetricKey));
    Encrypted secKey = encrypter.encrypt(text);
    print(secKey.base16);
    print(hex.encode(secKey.bytes));
  });
  
}