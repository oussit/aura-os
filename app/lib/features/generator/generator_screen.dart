
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glass_container.dart';
import '../../shared/widgets/aura_button.dart';
import '../../shared/effects/particle_engine.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen>
    with TickerProviderStateMixin {
  final _promptController = TextEditingController();
  String _selectedStyle = 'Cyberpunk';
  double _motionIntensity = 0.7;
  bool _isGenerating = false;
  double _generationProgress = 0;
  late AnimationController _progressController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 15));
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _progressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          if (_isGenerating)
            const ParticleEngine(
              particleCount: 80,
              type: ParticleType.glow,
              colors: [AppColors.neonCyan, AppColors.neonPurple],
              speed: 1.5,
              size: 3,
            ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 14, color: AppColors.textOnNeon),
                            SizedBox(width: 6),
                            Text('AI GENERATOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textOnNeon)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Preview area
                      _buildPreviewArea(),
                      const SizedBox(height: 24),

                      // Prompt input
                      _buildPromptInput(),
                      const SizedBox(height: 20),

                      // Style selector
                      _buildStyleSelector(),
                      const SizedBox(height: 20),

                      // Animation controls
                      _buildAnimationControls(),
                      const SizedBox(height: 20),

                      // Quick prompts
                      _buildQuickPrompts(),
                      const SizedBox(height: 24),

                      // Generate button
                      AuraButton(
                        text: _isGenerating ? 'Generating...' : 'Generate Wallpaper',
                        icon: _isGenerating ? null : Icons.bolt,
                        isLoading: _isGenerating,
                        onPressed: _isGenerating ? null : _generate,
                      ),

                      const SizedBox(height: 16),

                      // AI Director shortcut
                      GlassContainer(
                        onTap: () => Navigator.pushNamed(context, '/ai-director'),
                        padding: const EdgeInsets.all(16),
                        child: const Row(
                          children: [
                            Icon(Icons.psychology, color: AppColors.neonPurple, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Aura AI Director', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  SizedBox(height: 2),
                                  Text('Let AI craft your perfect wallpaper', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(gradient: AppColors.cyberpunkGradient),
              ),

              if (_isGenerating) ...[
                // Generation animation
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: _progressController.value,
                            strokeWidth: 3,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            color: AppColors.neonCyan,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${(_progressController.value * 100).toInt()}%',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getGenerationPhase(_progressController.value),
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    );
                  },
                ),
              ] else ...[
                // Empty state
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        size: 48,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your creation\nappears here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Phone frame overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptInput() {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: 20,
      child: Column(
        children: [
          TextField(
            controller: _promptController,
            maxLines: 3,
            minLines: 1,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Describe your dream wallpaper...',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: const Icon(Icons.auto_fix_high, color: AppColors.neonPurple),
                onPressed: _enhancePrompt,
                tooltip: 'AI Enhance',
              ),
            ),
          ),
          // Character count
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${_promptController.text.length}/${AppConstants.maxPromptLength}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Style', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.stylePresets.length,
            itemBuilder: (context, index) {
              final style = AppConstants.stylePresets[index];
              final isActive = _selectedStyle == style;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedStyle = style);
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: isActive ? AppColors.primaryGradient : null,
                    color: isActive ? null : AppColors.blackElevated,
                    border: Border.all(
                      color: isActive ? Colors.transparent : AppColors.glassBorder,
                      width: 0.5,
                    ),
                    boxShadow: isActive
                        ? [BoxShadow(color: AppColors.neonCyan.withOpacity(0.3), blurRadius: 12)]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _styleEmoji(style),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        style,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? AppColors.textOnNeon : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (50 * index).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationControls() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.animation, color: AppColors.neonCyan, size: 20),
              SizedBox(width: 8),
              Text('Motion & Effects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),

          // Motion intensity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Motion Intensity', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('${(_motionIntensity * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.neonCyan)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.neonCyan,
              inactiveTrackColor: AppColors.blackElevated,
              thumbColor: AppColors.neonCyan,
              overlayColor: AppColors.neonCyan.withOpacity(0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _motionIntensity,
              onChanged: (v) => setState(() => _motionIntensity = v),
            ),
          ),

          const SizedBox(height: 12),

          // Effect chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _effectChip('🌧️ Rain', true),
              _effectChip('✨ Particles', true),
              _effectChip('💨 Fog', false),
              _effectChip('⚡ Lightning', false),
              _effectChip('🔥 Fire', false),
              _effectChip('❄️ Snow', false),
              _effectChip('🌊 Flow', true),
              _effectChip('💫 Parallax', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _effectChip(String label, bool isActive) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive ? AppColors.neonCyan.withOpacity(0.15) : AppColors.blackElevated,
          border: Border.all(
            color: isActive ? AppColors.neonCyan.withOpacity(0.4) : AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.neonCyan : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Prompts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickPrompts.map((prompt) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _promptController.text = prompt;
              },
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                borderRadius: 20,
                child: Text(
                  prompt,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _enhancePrompt() async {
    if (_promptController.text.isEmpty) return;
    HapticFeedback.mediumImpact();
    // Would call AI service to enhance prompt
    final enhanced = '${_promptController.text}, masterpiece, best quality, ultra detailed, 8k, cinematic lighting, dramatic atmosphere, volumetric effects';
    _promptController.text = enhanced;
  }

  void _generate() async {
    if (_promptController.text.isEmpty) return;
    HapticFeedback.heavyImpact();

    setState(() => _isGenerating = true);
    _progressController.forward(from: 0);

    // Simulate generation progress
    await Future.delayed(const Duration(seconds: 3));
    _progressController.animateTo(0.3);
    await Future.delayed(const Duration(seconds: 4));
    _progressController.animateTo(0.6);
    await Future.delayed(const Duration(seconds: 4));
    _progressController.animateTo(0.9);
    await Future.delayed(const Duration(seconds: 2));
    _progressController.animateTo(1.0);

    setState(() => _isGenerating = false);
    HapticFeedback.heavyImpact();
  }

  String _getGenerationPhase(double progress) {
    if (progress < 0.2) return 'Analyzing prompt...';
    if (progress < 0.4) return 'Composing scene...';
    if (progress < 0.6) return 'Rendering details...';
    if (progress < 0.8) return 'Adding effects...';
    if (progress < 1.0) return 'Final touches...';
    return 'Complete!';
  }

  String _styleEmoji(String style) {
    const emojis = {
      'Cyberpunk': '🌆', 'Anime': '🌸', 'AMOLED Dark': '🖤',
      'Fantasy': '🐉', 'Sci-Fi': '🚀', 'Realistic': '📷',
      'Abstract': '🎨', 'Gaming': '🎮', 'Nature': '🌿',
      'Futuristic': '🔮', 'Liquid Chrome': '🪞', 'Neon Noir': '🌃',
    };
    return emojis[style] ?? '✨';
  }

  static const _quickPrompts = [
    'Cyberpunk samurai in neon rain',
    'AMOLED black dragon with glowing eyes',
    'Anime girl under moonlight with particles',
    'Minimal black hole with moving stars',
    'Liquid chrome wolf with smoke',
    'Futuristic BMW drifting through Tokyo',
  ];
}
