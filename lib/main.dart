import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; 

void main() {
  runApp(const MyApp());
}

// ============================================================
//  (About page)
// ============================================================
class AppInfo {
  static const String appName = 'Baggifly';
  static const String version = '1.0.0';
  static const String authorName = 'NUR AZILA BALQIS BINTI MOHAMAD YASIN';
  static const String matricNo = '2025432714';
  static const String course = 'CS251';
  static const String githubUrl =
    'https://github.com/Azilabalqis26/baggifly';
}

// ============================================================
//  BUSINESS RULES 
// ============================================================
class BaggageRules {
  static const double economyAllowanceKg = 20; // economy = 20 kg
  static const double businessAllowanceKg = 40; // business = 40 kg
  static const double serviceTaxRate = 0.08; // 8% service tax
}

// ============================================================
//  THEME COLOURS
// ============================================================
class AppColors {
  static const Color colorPrimary = Color(0xFFDB2F7F); // pink
  static const Color colorOnPrimary = Color(0xFFFFFFFF);
  static const Color colorSecondary = Color(0xFF2F6FDE); // blue
  static const Color colorOnSecondary = Color(0xFFFFFFFF);
  static const Color colorBackground = Color(0xFFFFF3F8); // very light pink
  static const Color colorSoftBlue = Color(0xFFEAF2FF); // very light blue
}

const LinearGradient appGradient = LinearGradient(
  colors: [AppColors.colorPrimary, AppColors.colorSecondary],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ============================================================
//  CALCULATION LOGIC
// ============================================================
class BaggageResult {
  final double weight; // input
  final double ratePerKg; // input
  final double allowance; // X (20 or 40)
  final double rawDifference; // weight - X (can be negative)
  final double excessWeight; // never negative
  final double excessCharge; // excessWeight * rate
  final double serviceTax; // 8% * excessCharge
  final double total; // excessCharge + serviceTax

  const BaggageResult({
    required this.weight,
    required this.ratePerKg,
    required this.allowance,
    required this.rawDifference,
    required this.excessWeight,
    required this.excessCharge,
    required this.serviceTax,
    required this.total,
  });
}

BaggageResult calculateBaggageFee({
  required double weight,
  required String ticketClass,
  required double ratePerKg,
}) {
  // X = 20 kg for economy, 40 kg for business
  final double allowance = ticketClass == 'Business'
      ? BaggageRules.businessAllowanceKg
      : BaggageRules.economyAllowanceKg;

  // excess weight = weight - X  (never negative)
  final double rawDifference = weight - allowance;
  double excessWeight = rawDifference;
  if (excessWeight < 0) {
    excessWeight = 0;
  }

  // excess charge = excess weight * rate per kg
  final double excessCharge = excessWeight * ratePerKg;

  // total = excess charge + (8% * excess charge)
  final double serviceTax = excessCharge * BaggageRules.serviceTaxRate;
  final double total = excessCharge + serviceTax;

  return BaggageResult(
    weight: weight,
    ratePerKg: ratePerKg,
    allowance: allowance,
    rawDifference: rawDifference,
    excessWeight: excessWeight,
    excessCharge: excessCharge,
    serviceTax: serviceTax,
    total: total,
  );
}

// 5.0 -> "5", 2.5 -> "2.5", 2.25 -> "2.25"
String fmtKg(double value) {
  String text = value.toStringAsFixed(2);
  text = text.replaceFirst(RegExp(r'0+$'), '');
  text = text.replaceFirst(RegExp(r'\.$'), '');
  return text;
}

// 81 -> "RM 81.00"
String fmtRm(double value) {
  return 'RM ${value.toStringAsFixed(2)}';
}

// ============================================================
//  APP
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.colorPrimary,
        ).copyWith(
          primary: AppColors.colorPrimary,
          onPrimary: AppColors.colorOnPrimary,
          secondary: AppColors.colorSecondary,
          onSecondary: AppColors.colorOnSecondary,
        ),
        scaffoldBackgroundColor: AppColors.colorBackground,
      ),
      home: const MainShell(),
    );
  }
}

// ============================================================
//  MAIN SHELL: AppBar + navigation menu (Drawer) + pages
// ============================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0; // 0 = Home, 1 = About

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppInfo.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.colorOnPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appGradient),
        ),
        // Lab 5: status bar icon colour (white icons on pink/blue)
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // Android
          statusBarBrightness: Brightness.dark, // iOS
        ),
      ),
      drawer: _buildDrawer(context),
      // IndexedStack keeps the Home inputs when you switch to About and back
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomePage(),
          AboutPage(),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.colorBackground,
      child: Column(
        children: [
          // Drawer header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 24,
              20,
              24,
            ),
            decoration: const BoxDecoration(gradient: appGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 64,
                    height: 64,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  AppInfo.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Navigation Menu',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _drawerItem(icon: Icons.home_rounded, label: 'Home', index: 0),
          _drawerItem(icon: Icons.info_rounded, label: 'About', index: 1),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        selected: selected,
        selectedColor: AppColors.colorPrimary,
        selectedTileColor: AppColors.colorPrimary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () => _selectPage(index),
      ),
    );
  }
}

// ============================================================
//  HOME PAGE: inputs + calculate + output
// ============================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  String? selectedClass; // null = nothing selected yet
  BaggageResult? result; // null = nothing to show yet

  @override
  void dispose() {
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  // Show a SnackBar message and clear the old output (Lab 4 style)
  void showMessage(String text) {
    setState(() => result = null);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void calculate() {
    FocusScope.of(context).unfocus(); // hide the keyboard

    final String weightText = weightController.text.trim().replaceAll(',', '.');
    final String rateText = rateController.text.trim().replaceAll(',', '.');

    // 1. Baggage weight: empty? not a number? negative?
    if (weightText.isEmpty) {
      showMessage('Please enter the baggage weight.');
      return;
    }
    final double? weight = double.tryParse(weightText);
    if (weight == null || !weight.isFinite) {
      debugPrint('Invalid weight input: $weightText');
      showMessage('Baggage weight must be a number.');
      return;
    }
    if (weight < 0) {
      showMessage('Baggage weight cannot be negative.');
      return;
    }

    // 2. Ticket class selected?
    if (selectedClass == null) {
      showMessage('Please select a ticket class.');
      return;
    }

    // 3. Rate per kg: empty? not a number? negative?
    if (rateText.isEmpty) {
      showMessage('Please enter the excess baggage rate per kg.');
      return;
    }
    final double? rate = double.tryParse(rateText);
    if (rate == null || !rate.isFinite) {
      debugPrint('Invalid rate input: $rateText');
      showMessage('Rate per kg must be a number.');
      return;
    }
    if (rate < 0) {
      showMessage('Rate per kg cannot be negative.');
      return;
    }

    // All values are valid: calculate and show the output
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      result = calculateBaggageFee(
        weight: weight,
        ticketClass: selectedClass!,
        ratePerKg: rate,
      );
    });
  }

  // Reset button clears everything
  void resetForm() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    weightController.clear();
    rateController.clear();
    setState(() {
      selectedClass = null;
      result = null;
    });
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.colorPrimary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.colorPrimary.withValues(alpha: 0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.colorPrimary.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.colorSecondary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBanner(),
          const SizedBox(height: 16),
          _buildInputCard(),
          if (result != null) ...[
            const SizedBox(height: 16),
            _buildResultCard(result!),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorPrimary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.luggage_rounded,
              size: 30,
              color: AppColors.colorPrimary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Excess Baggage Fee',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Fill in the details below to estimate the fee for your flight.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input 1: weight
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration(
                'Baggage weight (kg)',
                Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(height: 20),

            // Input 2: ticket class 
            const Text(
              'Ticket class',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioGroup<String>(
              groupValue: selectedClass,
              onChanged: (v) => setState(() => selectedClass = v),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Economy'),
                    subtitle: Text(
                      'Free allowance: ${fmtKg(BaggageRules.economyAllowanceKg)} kg',
                    ),
                    value: 'Economy',
                    activeColor: AppColors.colorPrimary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('Business'),
                    subtitle: Text(
                      'Free allowance: ${fmtKg(BaggageRules.businessAllowanceKg)} kg',
                    ),
                    value: 'Business',
                    activeColor: AppColors.colorPrimary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Input 3: rate per kg
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration(
                'Excess baggage rate per kg (RM)',
                Icons.payments_outlined,
              ),
            ),
            const SizedBox(height: 22),

            // Buttons
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    key: const Key('btnCalculate'),
                    onPressed: calculate,
                    icon: const Icon(Icons.calculate_rounded),
                    label: const Text('Calculate'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      foregroundColor: AppColors.colorOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    key: const Key('btnReset'),
                    onPressed: resetForm,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.colorSecondary,
                      side: const BorderSide(
                        color: AppColors.colorSecondary,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BaggageResult r) {
    final String taxPercent =
        (BaggageRules.serviceTaxRate * 100).toStringAsFixed(0);

    // the excess weight row
    String excessWorking =
        '${fmtKg(r.weight)} - ${fmtKg(r.allowance)} = ${fmtKg(r.rawDifference)}';
    if (r.rawDifference < 0) {
      excessWorking += '  (not more than ${fmtKg(r.allowance)} kg, so 0 kg)';
    }

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long_rounded, color: AppColors.colorSecondary),
                SizedBox(width: 8),
                Text(
                  'Result',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _resultRow(
              'Free baggage allowance',
              '${fmtKg(r.allowance)} kg',
            ),
            _resultRow(
              'Excess baggage weight',
              '${fmtKg(r.excessWeight)} kg',
              working: excessWorking,
            ),
            _resultRow(
              'Excess baggage charge',
              fmtRm(r.excessCharge),
              working: '${fmtKg(r.excessWeight)} x ${fmtRm(r.ratePerKg)}',
            ),
            _resultRow(
              'Service tax ($taxPercent%)',
              fmtRm(r.serviceTax),
              working: '$taxPercent% x ${fmtRm(r.excessCharge)}',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: appGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Total amount payable',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    fmtRm(r.total),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, {String? working}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 15)),
                if (working != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      working,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.colorSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  ABOUT PAGE: icon, author info, copyright, GitHub link
// ============================================================
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openGithub(BuildContext context) async {
   final Uri uri = Uri.parse(AppInfo.githubUrl);
    try {
       final bool opened =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
     if (!opened && context.mounted) {
       _showMessage(context, 'Could not open the GitHub link.');
    }
     } catch (e) {
       debugPrint('Cannot open URL: $e');
       if (context.mounted) {
         _showMessage(context, 'Could not open the GitHub link.');
       }
     }
   }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Application icon
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.colorSecondary.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppInfo.appName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.colorPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version ${AppInfo.version}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Author information
          Card(
            elevation: 2,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Author Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider(height: 24),
                  _InfoRow(
                    icon: Icons.person_rounded,
                    label: 'Name',
                    value: AppInfo.authorName,
                  ),
                  _InfoRow(
                    icon: Icons.badge_rounded,
                    label: 'Matric No',
                    value: AppInfo.matricNo,
                  ),
                  _InfoRow(
                    icon: Icons.school_rounded,
                    label: 'Course',
                    value: AppInfo.course,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // // Clickable GitHub repository URL
           Card(
           elevation: 2,
           color: Colors.white,
           shape:
           RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
           child: ListTile(
           key: const Key('githubLink'),
           contentPadding:
           const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
           shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(22),
           ),
           leading: const Icon(Icons.code_rounded,
           color: AppColors.colorSecondary),
           title: const Text(
           'GitHub Repository',
           style: TextStyle(fontWeight: FontWeight.bold),
           ),
           subtitle: const Text(
           AppInfo.githubUrl,
           style: TextStyle(
           color: AppColors.colorSecondary,
           decoration: TextDecoration.underline,
           decorationColor: AppColors.colorSecondary,
           ),
           ),
           trailing: const Icon(Icons.open_in_new_rounded,
           color: AppColors.colorSecondary),
           onTap: () => _openGithub(context),
           ),
           ),
           const SizedBox(height: 28),

          // Copyright notice
          Text(
            '© 2026 ${AppInfo.authorName}. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Mobile Technology - Individual Assignment',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.colorSoftBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.colorPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
