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
160行目の _EmailLinkSignInSectionクラスから下のコードは消す
Stateで呼び出してる消されたクラスの記述も消す
importされてるものも不必要なものは消す

画面遷移の作成
ここでそれぞれの画面に追加した定数idを使う。
各画面のクラスに名前をもたせておくことで呼び出しを簡単にする
initialRouteで指定した画面名のwidgetが初期画面として表示される。登録画面を初期画面とする。
また、
この時点で登録画面でデータを登録できるはずだが、環境によってできない場合もあるので、その場合は
register_pageの_RegisterPageStateクラスの_registerメソッドを編集する

  Future<void> _register() async {
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;

  を
  
  void _register() async {
    try {
      final User user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ))
         .user;
