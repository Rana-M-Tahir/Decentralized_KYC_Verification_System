import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nexus_kyt/auth_provider.dart';
import 'package:nexus_kyt/crypto_provider.dart';
import 'package:nexus_kyt/login_screen.dart';
import 'package:nexus_kyt/news_provider.dart';
import 'package:nexus_kyt/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'background_video_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final TextEditingController _walletController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mark that user is on DashboardScreen
    Future.microtask(() {
      context.read<AuthProvider>().setCurrentScreen('dashboard');
      context.read<AuthProvider>().fetchUser();
      context.read<NewsProvider>().fetchNews();
      context.read<CryptoProvider>().fetchCryptoHistory();
    });
  }

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  // ===== Mock Data =====
  String userName = "Rana Tahir";
  String walletAddress = "0x1234...abcd";
  String kycStatus = "Pending";
  int kycStepCompleted = 1;

  void verifyKYC() {
    setState(() {
      kycStatus = "Verified";
      kycStepCompleted = 3;
    });
  }

  Future<void> _connectMetaMask() async {
    if (!kIsWeb) {
      // Mobile: Attempt to open MetaMask app
      const String metaMaskDeepLink = "metamask://";
      final Uri uri = Uri.parse(metaMaskDeepLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(Uri.parse("https://metamask.io/download/"),
            mode: LaunchMode.externalApplication);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("For Web: Install 'flutter_web3' to connect.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<BackgroundVideoProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlockchainBackground(
        child: SafeArea(
          child: _buildBody(screenHeight, screenWidth, textScale),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 2) {
            // Fetch transactions when tab is selected
            final auth = context.read<AuthProvider>();
            final address = auth.userData?['walletAddress'] ?? walletAddress;
            context.read<TransactionProvider>().fetchTransactions(address);
          }
        },
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: "Transactions"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildBody(double h, double w, double ts) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen(h, w, ts);
      case 1:
        return _buildWalletScreen(h, w, ts);
      case 2:
        return _buildTransactionsScreen(h, w, ts);
      case 3:
        return _buildSettingsScreen();
      default:
        return _buildHomeScreen(h, w, ts);
    }
  }

  // =============== WALLET SCREEN =================
  Widget _buildWalletScreen(double h, double w, double ts) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Wallet Login",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22 * ts,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: h * 0.03),
            TextField(
              controller: _walletController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter Wallet Address",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.account_balance_wallet,
                    color: Colors.white70),
              ),
            ),
            SizedBox(height: h * 0.03),
            Consumer<AuthProvider>(builder: (context, auth, _) {
              return auth.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_walletController.text.trim().isEmpty) return;
                        final success = await auth.walletLogin(
                            walletAddress: _walletController.text.trim());
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Wallet login successful!"),
                                  backgroundColor: Colors.green));
                        } else if (mounted && auth.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(auth.error!),
                              backgroundColor: Colors.red));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        padding: EdgeInsets.symmetric(
                            horizontal: w * 0.1, vertical: h * 0.015),
                      ),
                      child: Text("Connect Wallet",
                          style: TextStyle(
                              color: Colors.white, fontSize: 16 * ts)),
                    );
            }),
            SizedBox(height: h * 0.02),
            OutlinedButton.icon(
              onPressed: _connectMetaMask,
              icon: const Icon(Icons.wallet, color: Colors.orange),
              label: Text("Connect MetaMask",
                  style: TextStyle(color: Colors.orange, fontSize: 16 * ts)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange),
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.1, vertical: h * 0.015),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============== TRANSACTIONS SCREEN =================
  Widget _buildTransactionsScreen(double h, double w, double ts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
          child: Text(
            "Transaction History",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22 * ts,
                fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(provider.error!,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                );
              }

              if (provider.transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.swap_horiz,
                          size: 60, color: Colors.white54),
                      const SizedBox(height: 16),
                      const Text("No transactions found",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final auth = context.read<AuthProvider>();
                          final address =
                              auth.userData?['walletAddress'] ?? walletAddress;
                          provider.fetchTransactions(address);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900),
                        child: const Text("Refresh",
                            style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final auth = context.read<AuthProvider>();
                  final address =
                      auth.userData?['walletAddress'] ?? walletAddress;
                  await provider.fetchTransactions(address);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = provider.transactions[index];
                    final date =
                        DateTime.tryParse(tx['block_timestamp'] ?? '') ??
                            DateTime.now();
                    final formattedDate =
                        "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";

                    // Value formatting
                    String valueStr = "0 ETH";
                    if (tx['value'] != null) {
                      try {
                        double val = double.parse(tx['value']) / 1e18;
                        valueStr = "${val.toStringAsFixed(4)} ETH";
                      } catch (e) {}
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.blue.shade900.withOpacity(0.5),
                          child: const Icon(Icons.receipt_long,
                              color: Colors.white),
                        ),
                        title: Text(
                          tx['summary'] ?? 'Transaction',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(formattedDate,
                            style: const TextStyle(color: Colors.white54)),
                        trailing: Text(valueStr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =============== HOME SCREEN =================
  Widget _buildHomeScreen(double h, double w, double ts) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<NewsProvider>().fetchNews();
        await context.read<CryptoProvider>().fetchCryptoHistory();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(w, ts),
            SizedBox(height: h * 0.02),
            // _buildVerificationCard(ts),
            // SizedBox(height: h * 0.02),
            // _buildQuickActions(ts),
            // SizedBox(height: h * 0.02),
            _buildCryptoChartSection(h, w),
            SizedBox(height: h * 0.02),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  // =============== HEADER =================
  Widget _buildHeader(double w, double ts) {
    return Container(
      padding: EdgeInsets.all(w * 0.01),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: w * 0.04,
            backgroundImage: const AssetImage("assets/images/logo.png"),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome to Nexus KYT",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * ts,
                        fontWeight: FontWeight.bold)),
                // Text(walletAddress,
                //     overflow: TextOverflow.ellipsis,
                //     style: TextStyle(color: Colors.white70, fontSize: 13 * ts)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============== KYC CARD =================
  Widget _buildVerificationCard(double ts) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(14 * ts),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: kycStatus == "Verified" ? Colors.green : Colors.orange,
                  size: 30 * ts,
                ),
                SizedBox(width: 10 * ts),
                Expanded(
                  child: Text(
                    "KYC Status: $kycStatus\nSteps Completed: $kycStepCompleted/3",
                    style: TextStyle(fontSize: 14 * ts),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900),
                  child: Text("Continue",
                      style: TextStyle(color: Colors.white, fontSize: 12 * ts)),
                ),
              ],
            ),
            SizedBox(height: 10 * ts),
            LinearProgressIndicator(
              value: kycStepCompleted / 3,
              backgroundColor: Colors.grey[200],
              color: Colors.blue.shade900,
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  // ============== QUICK ACTIONS =================
  Widget _buildQuickActions(double ts) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(Icons.send, "Send", ts),
        _actionButton(Icons.call_received, "Receive", ts),
        _actionButton(Icons.swap_horiz, "Swap", ts),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, double ts) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22 * ts,
          backgroundColor: Colors.blue.shade900,
          child: Icon(icon, color: Colors.white, size: 20 * ts),
        ),
        SizedBox(height: 4 * ts),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 13 * ts)),
      ],
    );
  }

  // ============== CRYPTO CHART =================
  Widget _buildCryptoChartSection(double h, double w) {
    return Consumer<CryptoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (provider.error != null || provider.priceData.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get latest price
        final currentPrice = provider.priceData.last[1];
        final startPrice = provider.priceData.first[1];
        final isUp = currentPrice >= startPrice;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Bitcoin (30D)",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(
                    "\$${currentPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: isUp ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  painter: CryptoChartPainter(
                    data: provider.priceData,
                    lineColor: isUp ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============== NEWS =================
  Widget _buildNewsSection() {
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Latest Crypto Updates",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.error != null)
              Text("Error: ${provider.error}",
                  style: const TextStyle(color: Colors.red))
            else if (provider.articles.isEmpty)
              const Text("No news found.",
                  style: TextStyle(color: Colors.white))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.articles.length,
                itemBuilder: (context, index) {
                  final article = provider.articles[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.white.withOpacity(0.9),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () async {
                        final url = article['url'];
                        if (url != null) {
                          final uri = Uri.parse(url);
                          try {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint("Could not launch url: $e");
                          }
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article['urlToImage'] != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.network(
                                article['urlToImage'],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article['title'] ?? 'No Title',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  article['description'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey[800], fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      article['source']?['name'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (article['publishedAt'] != null)
                                      Text(
                                        article['publishedAt']
                                            .toString()
                                            .substring(0, 10),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  // ============== SETTINGS TAB =================
  Widget _buildSettingsScreen() {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      final user = auth.userData;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_circle,
                      size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(user['name'] ?? 'User',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(user['email'] ?? '',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  _infoRow("User ID", user['id'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _infoRow("Role", user['role'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _infoRow("Wallet", user['walletAddress'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _infoRow("KYC Status", user['kycStatus'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _infoRow("Identity Submitted",
                      (user['identity'] == true) ? "Yes" : "No"),
                  const SizedBox(height: 8),
                  _infoRow(
                      "Docs Uploaded", (user['upload'] == true) ? "Yes" : "No"),
                  const SizedBox(height: 8),
                  _infoRow("Verification",
                      (user['verification'] == true) ? "Yes" : "No"),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.white)),
            onTap: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 250),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const login_screen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                        position: offsetAnimation, child: child);
                  },
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CryptoChartPainter extends CustomPainter {
  final List<dynamic> data; // [[time, price], ...]
  final Color lineColor;

  CryptoChartPainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // 1. Find Min/Max
    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;
    for (var point in data) {
      double price = point[1].toDouble();
      if (price < minPrice) minPrice = price;
      if (price > maxPrice) maxPrice = price;
    }

    // Add padding to range
    final range = maxPrice - minPrice;
    final paddedMin = minPrice - (range * 0.1);
    final paddedMax = maxPrice + (range * 0.1);
    final paddedRange = paddedMax - paddedMin;

    final path = Path();
    final fillPath = Path();

    double widthStep = size.width / (data.length - 1);

    // 2. Build Path
    for (int i = 0; i < data.length; i++) {
      double price = data[i][1].toDouble();
      double x = i * widthStep;
      // Normalize price to 0..1, then flip for Y (0 is top)
      double normalizedY = (price - paddedMin) / paddedRange;
      double y = size.height * (1 - normalizedY);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // 3. Draw Fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.0)],
    );
    final paintFill = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, paintFill);

    // 4. Draw Line
    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
