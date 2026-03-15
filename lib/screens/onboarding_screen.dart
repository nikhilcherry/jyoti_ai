import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jyoti_ai/models/models.dart';
import 'package:jyoti_ai/providers/jyoti_provider.dart';
import 'package:jyoti_ai/theme/app_theme.dart';
import 'package:jyoti_ai/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Birth details
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedTime = '';
  final _placeController = TextEditingController();
  Rashi _selectedRashi = Rashi.mesha;
  
  final List<String> _languages = [
    'English',
    'Hinglish',
    'Hindi',
    'Telugu (Eng script)',
    'Kannada (Eng script)',
  ];
  String _selectedLanguage = 'English';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submitAndNavigate();
    }
  }

  void _submitAndNavigate() {
    final provider = context.read<JyotiProvider>();
    if (_nameController.text.isNotEmpty && _selectedDate != null) {
      provider.completeOnboarding(
        name: _nameController.text,
        dob: _selectedDate!,
        timeOfBirth: _selectedTime.isEmpty ? 'Unknown' : _selectedTime,
        placeOfBirth: _placeController.text.isEmpty
            ? 'India'
            : _placeController.text,
        rashi: _selectedRashi,
        language: _selectedLanguage,
      );
    } else {
      provider.skipOnboarding();
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const HomeScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JyotiTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(JyotiTheme.spacingMd),
                child: TextButton(
                  onPressed: _submitAndNavigate,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: JyotiTheme.textMuted),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(),
                  _buildLanguagePage(),
                  _buildBirthDetailsPage(),
                  _buildRashiPage(),
                ],
              ),
            ),

            // Indicators + Button
            Padding(
              padding: const EdgeInsets.all(JyotiTheme.spacingLg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            JyotiTheme.radiusFull,
                          ),
                          color: _currentPage == i
                              ? JyotiTheme.gold
                              : JyotiTheme.border,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: JyotiTheme.spacingLg),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 3 ? 'Start My Journey ✨' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: JyotiTheme.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  JyotiTheme.gold.withValues(alpha: 0.2),
                  JyotiTheme.cosmic.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: JyotiTheme.gold.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: JyotiTheme.gold.withValues(alpha: 0.15),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text('🔮', style: TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(height: JyotiTheme.spacing2xl),
          ShaderMask(
            shaderCallback: (b) => JyotiTheme.goldGradient.createShader(b),
            child: const Text(
              'Namaste 🙏',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: JyotiTheme.spacingMd),
          const Text(
            'I am Jyoti — your AI Vedic astrologer.\n\nI read the stars every day with real planetary data to give you personal, actionable guidance.',
            style: TextStyle(
              fontSize: 16,
              color: JyotiTheme.textSecondary,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: JyotiTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: JyotiTheme.spacingXl),
          const Center(child: Text('🗣️', style: TextStyle(fontSize: 50))),
          const SizedBox(height: JyotiTheme.spacingLg),
          const Center(
            child: Text(
              'Preferred Language',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: JyotiTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: JyotiTheme.spacingSm),
          const Center(
            child: Text(
              'How should Jyoti speak with you?',
              style: TextStyle(color: JyotiTheme.textMuted, fontSize: 14),
            ),
          ),
          const SizedBox(height: JyotiTheme.spacingXl),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = _selectedLanguage == lang;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedLanguage = lang);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: JyotiTheme.spacingMd),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
                      color: isSelected
                          ? JyotiTheme.gold.withValues(alpha: 0.15)
                          : JyotiTheme.surfaceVariant,
                      border: Border.all(
                        color: isSelected
                            ? JyotiTheme.gold.withValues(alpha: 0.5)
                            : JyotiTheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: JyotiTheme.gold.withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? JyotiTheme.goldLight
                                : JyotiTheme.textPrimary,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: JyotiTheme.gold,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: JyotiTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: JyotiTheme.spacingXl),
          const Center(child: Text('🪷', style: TextStyle(fontSize: 50))),
          const SizedBox(height: JyotiTheme.spacingLg),
          const Center(
            child: Text(
              'Your Birth Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: JyotiTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: JyotiTheme.spacingSm),
          const Center(
            child: Text(
              'For accurate kundli & personalized readings',
              style: TextStyle(color: JyotiTheme.textMuted, fontSize: 14),
            ),
          ),
          const SizedBox(height: JyotiTheme.spacingXl),

          // Name
          const Text(
            'Name',
            style: TextStyle(
              color: JyotiTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: JyotiTheme.spacingSm),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: JyotiTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: Icon(
                Icons.person_outline,
                color: JyotiTheme.textSubtle,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: JyotiTheme.spacingMd),

          // Date of Birth
          const Text(
            'Date of Birth',
            style: TextStyle(
              color: JyotiTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: JyotiTheme.spacingSm),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(1998, 1, 1),
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: JyotiTheme.gold,
                        surface: JyotiTheme.surface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: Container(
              padding: const EdgeInsets.all(JyotiTheme.spacingMd),
              decoration: BoxDecoration(
                color: JyotiTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
                border: Border.all(color: JyotiTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: JyotiTheme.textSubtle,
                    size: 20,
                  ),
                  const SizedBox(width: JyotiTheme.spacingSm),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select date of birth',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? JyotiTheme.textPrimary
                          : JyotiTheme.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: JyotiTheme.spacingMd),

          // Time & Place row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time of Birth',
                      style: TextStyle(
                        color: JyotiTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: JyotiTheme.spacingSm),
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 6, minute: 0),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: JyotiTheme.gold,
                                  surface: JyotiTheme.surface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          setState(() => _selectedTime = time.format(context));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(JyotiTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: JyotiTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            JyotiTheme.radiusMd,
                          ),
                          border: Border.all(color: JyotiTheme.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: JyotiTheme.textSubtle,
                              size: 20,
                            ),
                            const SizedBox(width: JyotiTheme.spacingSm),
                            Expanded(
                              child: Text(
                                _selectedTime.isNotEmpty
                                    ? _selectedTime
                                    : 'Time',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _selectedTime.isNotEmpty
                                      ? JyotiTheme.textPrimary
                                      : JyotiTheme.textSubtle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: JyotiTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Place',
                      style: TextStyle(
                        color: JyotiTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: JyotiTheme.spacingSm),
                    TextField(
                      controller: _placeController,
                      style: const TextStyle(color: JyotiTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'City',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: JyotiTheme.textSubtle,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRashiPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: JyotiTheme.spacingMd),
      child: Column(
        children: [
          const SizedBox(height: JyotiTheme.spacingXl),
          const Text('☀️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: JyotiTheme.spacingMd),
          const Text(
            'Select Your Rashi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: JyotiTheme.textPrimary,
            ),
          ),
          const SizedBox(height: JyotiTheme.spacingSm),
          const Text(
            'Moon sign (Chandra Rashi)',
            style: TextStyle(color: JyotiTheme.textMuted, fontSize: 14),
          ),
          const SizedBox(height: JyotiTheme.spacingLg),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: Rashi.values.length,
              itemBuilder: (context, index) {
                final rashi = Rashi.values[index];
                final isSelected = _selectedRashi == rashi;
                final color = Color(rashi.color);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedRashi = rashi);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : JyotiTheme.cardBg,
                      border: Border.all(
                        color: isSelected
                            ? color.withValues(alpha: 0.5)
                            : JyotiTheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.15),
                                blurRadius: 20,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          rashi.symbol,
                          style: TextStyle(
                            fontSize: 24,
                            color: isSelected ? color : JyotiTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rashi.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? color
                                : JyotiTheme.textSecondary,
                          ),
                        ),
                        Text(
                          rashi.english,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? color.withValues(alpha: 0.7)
                                : JyotiTheme.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
