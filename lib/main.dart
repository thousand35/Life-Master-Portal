import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0288D1),
          primary: const Color(0xFF0288D1),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      home: const PortalHomePage(),
    );
  }
}

class AppReleaseInfo {
  final String version;
  final String body;
  final String downloadUrl;
  final bool isLoading;

  AppReleaseInfo({
    this.version = '---',
    this.body = '情報を取得しています...',
    this.downloadUrl = '',
    this.isLoading = true,
  });

  AppReleaseInfo copyWith({
    String? version,
    String? body,
    String? downloadUrl,
    bool? isLoading,
  }) {
    return AppReleaseInfo(
      version: version ?? this.version,
      body: body ?? this.body,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isLoading: isLoading ?? this.isLoading,
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

  // 取得した情報を保持するマップ
  final Map<String, AppReleaseInfo> _releaseData = {};

  final List<Map<String, dynamic>> apps = [
    {
      'name': '家計簿マスター',
      'id': 'my_kakeibo',
      'repo': 'kakeibo_download',
      'icon': Icons.account_balance_wallet,
      'color': Colors.orange,
      'emoji': '💰',
      'subtitle': 'シンプル・高機能な収支管理',
      'description': '日々の収支をカレンダーやグラフで直感的に管理。CSV入出力やクラウド同期にも対応した、長く使い続けられる家計簿アプリです。',
      'default_download': 'https://github.com/thousand35/kakeibo_download/releases/latest/download/app-release.apk',
    },
    {
      'name': 'パスワードマスター',
      'id': 'password_master',
      'repo': 'password_download',
      'icon': Icons.vpn_key,
      'color': Colors.blue,
      'emoji': '🔐',
      'subtitle': '安心・安全のローカル保存型管理',
      'description': '大切なパスワードを強力な暗号化で保護。あえてクラウドを使わない「ローカル完結」の設計で、究極のプライバシーと安全を提供します。',
      'default_download': 'https://github.com/thousand35/password_download/releases/latest/download/app-release.apk',
    },
    {
      'name': '燃費管理マスター',
      'id': 'fuel_master',
      'repo': 'fuel_download',
      'icon': Icons.local_gas_station,
      'color': const Color(0xFF0288D1),
      'emoji': '⛽',
      'subtitle': '愛車の健康と燃料コストを可視化',
      'description': '給油情報を入れるだけで燃費や維持費を自動計算。推移グラフで無駄をチェックし、愛車とのカーライフをより経済的にサポートします。',
      'default_download': 'https://github.com/thousand35/fuel_download/releases/latest/download/app-release.apk',
    },
    {
      'name': '蔵書管理マスター',
      'id': 'book_manager',
      'repo': 'book_download',
      'icon': Icons.menu_book,
      'color': Colors.brown,
      'emoji': '📚',
      'subtitle': 'スマホで完結する蔵書・積読管理',
      'description': 'バーコードをスキャンするだけで本棚をデジタル化。持っている本をいつでも確認でき、書店での「ダブり買い」や「積読」の悩みから解放します。',
      'default_download': 'https://github.com/thousand35/book_download/releases/latest/download/app-release.apk',
    },
  ];

  @override
  void initState() {
    super.initState();
    for (var app in apps) {
      _releaseData[app['id']] = AppReleaseInfo();
    }
    _fetchAllReleaseInfo();
  }

  Future<void> _fetchAllReleaseInfo() async {
    for (var app in apps) {
      _fetchReleaseInfo(app['id'], app['repo'], app['default_download']);
    }
  }

  Future<void> _fetchReleaseInfo(String appId, String repo, String fallbackUrl) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/thousand35/$repo/releases/latest'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final assets = data['assets'] as List;
        String downloadUrl = fallbackUrl;
        
        // APKファイルを探す
        for (var asset in assets) {
          if (asset['name'].toString().endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'];
            break;
          }
        }

        if (mounted) {
          setState(() {
            _releaseData[appId] = AppReleaseInfo(
              version: data['tag_name'] ?? 'Unknown',
              body: data['body'] ?? '更新詳細はありません。',
              downloadUrl: downloadUrl,
              isLoading: false,
            );
          });
        }
      } else {
        throw Exception('Failed to load release info');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _releaseData[appId] = AppReleaseInfo(
            version: '取得エラー',
            body: 'GitHubからの情報取得に失敗しました。',
            downloadUrl: fallbackUrl,
            isLoading: false,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 上部：2×2の極小ボタン
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4.5, // より横長・スリムに
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final isSelected = _currentPage == index;
                  final app = apps[index];
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutQuart,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? app['color'] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          if (isSelected) 
                            BoxShadow(color: app['color'].withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 3))
                          else
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 3, offset: const Offset(0, 1))
                        ],
                        border: Border.all(
                          color: isSelected ? app['color'] : Colors.grey.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            app['icon'],
                            size: 14,
                            color: isSelected ? Colors.white : app['color'],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              app['name'],
                              style: TextStyle(
                                fontSize: 11,
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

            // 下部：メインコンテンツ（スワイプ対応）
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  final release = _releaseData[app['id']] ?? AppReleaseInfo();
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    '${app['emoji']} ${app['name']}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: app['color'],
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    app['subtitle'],
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade400,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              app['description'],
                              style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            
                            // バージョン & 更新内容
                            _buildInfoSection(
                              title: '最新バージョン情報',
                              icon: Icons.new_releases_outlined,
                              color: app['color'],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('バージョン：', style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (release.isLoading)
                                        const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                                      else
                                        Text(release.version, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('更新履歴：', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Text(
                                      release.body,
                                      style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),

                            // ダウンロードボタン
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: release.isLoading ? null : () => _launchURL(release.downloadUrl),
                                icon: const Icon(Icons.download),
                                label: const Text('最新版 APKをダウンロード', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: app['color'],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                  elevation: 4,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // インストール手順ガイド
                            _buildInfoSection(
                              title: 'インストール手順',
                              icon: Icons.install_mobile_outlined,
                              color: const Color(0xFF0277BD),
                              backgroundColor: const Color(0xFFE3F2FD),
                              child: Column(
                                children: [
                                  _buildStep('1', 'APKファイルをダウンロードして保存します。'),
                                  _buildStep('2', '通知やファイル管理アプリから APKを開きます。'),
                                  _buildStep('3', '「この提供元のアプリを許可」をしてインストール。'),
                                  _buildStep('4', '完了！安全なツールですので安心してお使いください。'),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            const Center(
                              child: Text(
                                '※ Google Playストアを通さない配布のため、警告が出ることがあります。\n※ 弊社アプリは公式の署名鍵で保護されており、安全です。',
                                style: TextStyle(fontSize: 10, color: Color(0xFF90A4AE), height: 1.5),
                                textAlign: TextAlign.center,
                              ),
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
              child: TextButton.icon(
                onPressed: () => _launchURL('https://docs.google.com/forms/d/e/1FAIpQLSfw-yPjeWq_Vd101oZ5OFSGYDHvGBnuYBwudogxKZRQHgnQ2g/viewform?usp=dialog'),
                icon: const Icon(Icons.mail_outline, size: 16),
                label: const Text('ご意見・ご要望はこちら', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: backgroundColor == null ? Border.all(color: Colors.grey.shade100) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF0288D1),
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('リンクを開けませんでした: $urlString')),
        );
      }
    }
  }
}
