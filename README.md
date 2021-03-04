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

アプリの初期画面
また、動的に変化する部分がないからstatelessにする。

レイアウトの基本
Column(列)、Row(行)

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('1行目'),
    Text('2行目'),
    Text('3行目'),
    
  ],
)
とすることで、テキストを3行分縦に並べる
crossAxisAlignmentで左右位置を変える
mainAxisAlignmentは上下位置、mainAxisSizeは上下サイズ

Containerは中に別のWidgetを配置することでレイアウトの補助的な役割を果たす。様々な位置指定が可能になる
コンテナのプロパティについては
colorは背景色、borderRadiusは角

データ管理には「Cloud Firestore」を使い、一連の会話を保管する「Collection : messages」を定義する
具体的には、Collectionに1つの発言を「1 document」として「発言内容(messages)、発言者(sender)、発言日時(time)」を記録する
Cloud FirestoreはCollectionに対して簡単にデータの読み込みができる
例えば、今回の会話のデータを書き込む場合、collectionに対してaddメソッドを発行するだけでデータの追加が完了する
また、FieldValue.serverTimestamp()を値として指定することでサーバー側でタイムスタンプを記録することもできる
例
final _db = FirebaseFirestore.instance;
_db.collection('messages').add({
               'sender': _user.email,
               'text': messageText,
               'time': FieldValue.serverTimestamp(),
});

読み出しについては、直接ドキュメントを読み出すことも可能だけど、「コレクション」に対して「クエリ」を発行することもできる
今回は最新の50エントリを取得したいので、時間で並び替えて取得するように書く
このとき返されるのは直接のデータじゃなくてsnapshotというクエリ結果の集合オブジェクトとなる
例
_db.collection('messages')
   .orderBy('time', descending: true)
   .limit(50)
   .snapshots()

snapshotは、サーバのデータが更新されるとsnapshotのデータが同期して更新されるという機能を持つ。
つまり、データの更新をプログラマーがいちいち確認しにいく必要がなくなる。
さらに、Streamの機能と相性が良い。
Firestore上の特定のコレクションの更新を監視して、更新の旅に処理を行うためにFlutterのStreamBuilderクラスを利用する
StreamBuilderを使うとサーバ上のデータ更新があるたびにbuilderで指定した関数が呼び出され、自動的に画面をbuildしてくれるようになる
例
StreamBuilder<QuerySnapshot>(
  stream: _db
    .collection('messages)
    .orderBy('time', descending: true)
    .limit(50)
    .snapshots(),
  builder: (context, snapshot) {
.....


androidアプリの配布
アイコン、ファイルを生成するパッケージを使う。まずpubspec.yamlに以下を追加する
dev_dependencies:
  flutter_launcher_icons: ^0.7.5
flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon.png"
  
次に、flutter pub get実行し、さらに
flutter pub run flutter_launcher_icons:main  を実行する

そして、yamlにバージョン番号を設定する。これはビルド時に反映され、アプリが更新されたことをシステムに知らせる役割を持つ
version: 1.0.0+1
形式は A.B.C+Xとなっており、ABCはバージョン名、Xはバージョンコード(ビルド番号)となる
Play Storeに公開する再には同じバージョンのパッケージは使えない。
また、バージョン番号を比較してアップデートの配布がされるため、同じパッケージで数字の小さい古いバージョンに戻してはいけない
アプリをリリースするたんいでバージョン番号をすすめるようにする

次に、デジタル署名鍵の作成をする
Play Storeに公開するには電子署名が必要で、作成にはJava実行環境を使う。
androidstudioに同梱されているJava実行環境の場所は
cd /Applications/Android Studio.app/Contents/jre/jdk/Contents/Home/bin
で、移動したら作成コマンドをうつ
./keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

次に、電子署名を行うためのビルド設定
作った署名鍵の情報を"(アプリのルート)/android/key.properties"ファイルを作って以下の内容を保管する
storePassword=(直前に作成したキーストアのパスワード)
keyPassword=(直前に作成した署名鍵のパスワード)
keyAlias=key
storeFile=(直前に作成したキーストアの場所)

そして、"(アプリのルート)/android/app/build.gradle"ファイルを開き、
作ったkey.propertiesファイルを読み込むステートメントをandroid{ステートメント}の直前に追加する
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
android { .....

さらに、リリースビルド用に作り署名鍵を使うステートメントを追加する
buildTypesステートメントの直前に次のsigningConfigsを追加する
signingConfigs {
  releas {
    keyAlias keystoreProperties['keyAlias']
    keyPassword keystoreProperties['keyPassword']
    storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
    storePassword keystoreProperties['storePassword']
  }
}
buildTypes {
  release {
    signingConfig signingConfigs.release  //ここも変更
  }
} .......

配布用パッケージの作成
Androidで使われる配布形式は App Bundleパッケージと、apkパッケージの2つあり
App BundleパッケージはPlayStore経由の配布で使うが、直接インストール・実行はできない
メールなどで直接配布する場合にはapkパッケージを使う
どちらのパッケージも以下のコマンドで作れる
flutter build appbundle             appbundleパケ
flutter build apk -split-per-abi    apkパケ
正常に終了するとapp/outputsフォルダ配下にリリースビルドのアプリパッケージが作られているはず
これで配布用パッケージが完成して、apkファイルをメールで配布することでアプリを配布できる
PlayStoreを使う場合にはGoogle Play Consoleの説明を参考にする https://developer.android.com/distribute/console?h1=ja

iPhoneアプリの配布
ビルドの手順は変わらず、Flutterオフィシャルサイトに手順が掲載されている https://flutter.dev/docs/deployment/ios
ただし、Apple Developer Programの利用が前提となるため、契約と使い方を学習する必要あり
https://developer.apple.com/jp/programs/
