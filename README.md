firebaseのユーザー関連から (導入は省く)
firebaseのwebページから、左メニューのAuthenticationにて、メール・パスワードの上のを有効にする
次に、yamlにfirebase_auth, fluter_signin_buttonを導入
firebase_authは以下のリンクより詳細
https://pub.dev/packages/firebase_auth/example

登録画面はサンプルコードより、register_page.dartをそのままコピる
registerpageクラスに定数idを宣言する。後にnavigatorでの画面遷移時に使う
  static const String id = 'register_page';

signin_page.dartを同様にコピペ
signinpageクラスにnavigator用にidを同じように宣言する
