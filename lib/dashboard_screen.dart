import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nexus_kyt/login_screen.dart';
import 'package:provider/provider.dart';

import 'background_video_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // ===== Mock Data =====
  String userName = "Rana Tahir";
  String walletAddress = "0x1234...abcd";
  String kycStatus = "Pending";
  int kycStepCompleted = 1;

  final List<Map<String, dynamic>> walletAssets = [
    {"name": "Ethereum", "symbol": "ETH", "balance": 0.45, "usd": 1200.55},
    {"name": "Tether", "symbol": "USDT", "balance": 150.00, "usd": 150.00},
    {"name": "DAI", "symbol": "DAI", "balance": 75.30, "usd": 75.30},
    {"name": "Uniswap", "symbol": "UNI", "balance": 10.5, "usd": 42.10},
  ];

  final List<Map<String, String>> transactions = [
    {"id": "TX12345", "status": "KYC Submitted"},
    {"id": "TX67890", "status": "KYC Approved"},
    {"id": "TX54321", "status": "ID Uploaded"},
  ];

  final List<String> news = [
    "Ethereum gas fees dropped by 12% today.",
    "New KYC regulations announced for DeFi apps.",
    "USDT market cap crossed 100B milestone.",
  ];

  void verifyKYC() {
    setState(() {
      kycStatus = "Verified";
      kycStepCompleted = 3;
    });
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
        onTap: (index) => setState(() => _currentIndex = index),
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
        return _buildWalletScreen(h, w);
      case 2:
        return _buildTransactionHistory(fullScreen: true);
      case 3:
        return _buildSettingsScreen();
      default:
        return _buildHomeScreen(h, w, ts);
    }
  }

  // =============== HOME SCREEN =================
  Widget _buildHomeScreen(double h, double w, double ts) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        verifyKYC();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(w, ts),
            SizedBox(height: h * 0.02),
            _buildVerificationCard(ts),
            SizedBox(height: h * 0.02),
            _buildWalletSection(h, w),
            SizedBox(height: h * 0.02),
            _buildQuickActions(ts),
            SizedBox(height: h * 0.02),
            _buildTransactionHistory(),
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
                Text(userName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * ts,
                        fontWeight: FontWeight.bold)),
                Text(walletAddress,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white70, fontSize: 13 * ts)),
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

  // ============== WALLET SECTION =================
  Widget _buildWalletSection(double h, double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Wallet Assets",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: h * 0.015),
        SizedBox(
          height: h * 0.22,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: walletAssets.length,
            itemBuilder: (context, index) {
              final asset = walletAssets[index];
              return Container(
                width: w * 0.45,
                margin: EdgeInsets.only(right: w * 0.01),
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.04,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset["name"],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(asset["symbol"],
                        style: const TextStyle(color: Colors.grey)),
                    const Spacer(),
                    Text("${asset["balance"]} ${asset["symbol"]}",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    Text("\$${asset["usd"]}",
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

  // ============== TRANSACTIONS =================
  Widget _buildTransactionHistory({bool fullScreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!fullScreen)
          const Text("Transaction History",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ...transactions.map((tx) => Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.blue),
                title: Text(tx["id"]!),
                subtitle: Text(tx["status"]!),
              ),
            )),
      ],
    );
  }

  // ============== NEWS =================
  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Latest Updates",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        ...news.map((n) => Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.article, color: Colors.blue),
                title: Text(n),
              ),
            )),
      ],
    );
  }

  // ============== WALLET TAB =================
  Widget _buildWalletScreen(double h, double w) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(w * 0.04),
      child: Column(
        children: [
          _buildWalletSection(h, w),
          SizedBox(height: h * 0.02),
          _buildQuickActions(MediaQuery.of(context).textScaleFactor),
        ],
      ),
    );
  }

  // ============== SETTINGS TAB =================
  Widget _buildSettingsScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text("Enable Biometric Login",
              style: TextStyle(color: Colors.white)),
          value: true,
          onChanged: (_) {},
        ),
        SwitchListTile(
          title: const Text("Two-Factor Authentication",
              style: TextStyle(color: Colors.white)),
          value: false,
          onChanged: (_) {},
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout", style: TextStyle(color: Colors.white)),
          onTap: () {
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
  }
}
