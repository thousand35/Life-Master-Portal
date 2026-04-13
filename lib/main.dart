import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const LifeMasterPortal());
}

class LifeMasterPortal extends StatelessWidget {
  const LifeMasterPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Master Portal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0288D1)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8), // HTMLの背景色
      ),
      home: const PortalHomePage(),
    );
  }
}

class PortalHomePage extends StatefulWidget {
  const PortalHomePage({super.key});

  @override
  State<PortalHomePage> createState() => _PortalHomePageState();
}

class _PortalHomePageState extends State<PortalHomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // アプリデータ構造
  final List<Map<String, dynamic>> apps = [
    {
      'name': '家計簿マスター',
      'id': 'my_kakeibo',
      'icon': Icons.account_balance_wallet,
      'color': Colors.orange,
      'emoji': '💰',
      'subtitle': '収支管理・Vポイント最適化',
      'description': '日々の収支をスマートに管理。ポイ活ルートの最適化にも対応した家計簿アプリです。',
      'download_url': 'https://github.com/thousand35/my_kakeibo/releases/latest/download/app-release.apk',
    },
    {
      'name': 'パスワードマスター',
      'id': 'password_master',
      'icon': Icons.vpn_key,
      'color': Colors.blue,
      'emoji': '🔐',
      'subtitle': 'セキュア・パスワード管理',
      'description': '安全で強固なパスワード管理。あなたのデジタルライフをローカル保存で守ります。',
      'download_url': 'https://github.com/thousand35/password_master/releases/latest/download/app-release.apk',
    },
    {
      'name': '燃費管理マスター',
      'id': 'fuel_master',
      'icon': Icons.local_gas_station,
      'color': const Color(0xFF0288D1),
      'emoji': '⛽',
      'subtitle': '燃費管理・家計分析ツール',
      'description': '最新のAndroid用アプリ(APK)をダウンロードして、愛車の管理を始めましょう。',
      'download_url': 'https://github.com/thousand35/fuel_master/releases/latest/download/app-release.apk',
    },
    {
      'name': '蔵書管理マスター',
      'id': 'book_manager',
      'icon': Icons.menu_book,
      'color': Colors.brown,
      'emoji': '📚',
      'subtitle': '蔵書・コレクション管理',
      'description': 'ライトノベルや漫画のダブり買いを防止。手元のコレクションを完璧に把握します。',
      'download_url': 'https://github.com/thousand35/book_manager/releases/latest/download/app-release.apk',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 上部：2段2列のスリムな横長タイル
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8, // 横長にするための比率
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final isSelected = _currentPage == index;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? apps[index]['color'] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            apps[index]['icon'],
                            size: 20,
                            color: isSelected ? Colors.white : apps[index]['color'],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              apps[index]['name'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 下部：メインコンテンツスライダー（HTMLのデザインを再現）
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${app['emoji']} ${app['name']}',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: app['color'],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              app['subtitle'],
                              style: const TextStyle(
                                color: Color(0xFF78909C),
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              app['description'],
                              style: const TextStyle(fontSize: 15, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            
                            // ダウンロードボタン
                            ElevatedButton(
                              onPressed: () => _launchURL(app['download_url']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: app['color'],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                elevation: 5,
                              ),
                              child: const Text('最新版をダウンロード', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // インストール手順ガイド
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1F5FE),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: const Color(0xFFB3E5FC)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.settings, size: 20, color: Color(0xFF0277BD)),
                                      SizedBox(width: 8),
                                      Text('⚙️ インストール手順', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0277BD))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStep('① 「ダウンロード」ボタンを押し、APKファイルを保存します。'),
                                  _buildStep('② スマホの「ファイル」アプリを開き、「ダウンロード」フォルダを確認します。'),
                                  _buildStep('③ 「app-release.apk」をタップして起動します。'),
                                  _buildStep('④ Androidの警告が出た場合は、一時的に「この提供元のアプリを許可」をONにして完了させてください。'),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            const Text(
                              '※本アプリはGoogle Playストア外の配布ですが、個人開発による安全なツールです。\n※インストール後は「設定」から許可をオフに戻しても問題ありません。',
                              style: TextStyle(fontSize: 11, color: Color(0xFF90A4AE), height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // お問い合わせ
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                onPressed: () => _launchURL('https://docs.google.com/forms/d/e/あなたのフォームID/viewform'),
                child: const Text('ご意見・ご要望はこちら'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFB3E5FC), style: BorderStyle.solid, width: 0.5)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}