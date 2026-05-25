
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/glass_container.dart';
import '../../shared/effects/particle_engine.dart';

class AIDirectorScreen extends StatefulWidget {
  const AIDirectorScreen({super.key});

  @override
  State<AIDirectorScreen> createState() => _AIDirectorScreenState();
}

class _AIDirectorScreenState extends State<AIDirectorScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Welcome message
    _messages.add(_ChatMessage(
      isAI: true,
      text: "Hey! I'm your Aura AI Director 🎨\n\nTell me the vibe you want for your phone and I'll craft the perfect wallpaper.\n\nTry something like:\n• \"Make my phone feel like a futuristic Tokyo night\"\n• \"I want something dark and mysterious with glowing eyes\"\n• \"Create an AMOLED space scene with floating particles\"",
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          const ParticleEngine(
            particleCount: 20,
            type: ParticleType.glow,
            colors: [AppColors.neonPurple, AppColors.neonCyan],
            speed: 0.3,
            size: 2,
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Chat
                Expanded(child: _buildChat()),

                // Input
                _buildInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // AI Avatar
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.auroraGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonPurple.withOpacity(0.3 + _pulseController.value * 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.psychology, color: Colors.white, size: 24),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aura AI Director', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: AppColors.neonGreen),
                    SizedBox(width: 4),
                    Text('Online • Ready to create', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.neonPurple),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChat() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessage(_messages[index])
            .animate(delay: 100.ms)
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1);
      },
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    final isAI = message.isAI;
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          borderColor: isAI ? AppColors.neonPurple.withOpacity(0.3) : AppColors.neonCyan.withOpacity(0.3),
          backgroundColor: isAI
              ? AppColors.neonPurple.withOpacity(0.05)
              : AppColors.neonCyan.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              ),
              if (message.previewUrl != null) ...[
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppColors.cyberpunkGradient,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonCyan,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Apply Wallpaper', style: TextStyle(color: AppColors.textOnNeon, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (message.actions != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: message.actions!.map((action) {
                    return GestureDetector(
                      onTap: () => _sendMessage(action),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.neonPurple.withOpacity(0.3)),
                          color: AppColors.neonPurple.withOpacity(0.1),
                        ),
                        child: Text(
                          action,
                          style: const TextStyle(fontSize: 12, color: AppColors.neonPurple, fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        borderRadius: 20,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final delay = i * 0.2;
                final value = (_pulseController.value + delay) % 1.0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonPurple.withOpacity(0.3 + value * 0.7),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blackLight,
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                borderRadius: 24,
                height: 48,
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Describe your vision...',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(_messageController.text),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(Icons.send, color: AppColors.textOnNeon, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _messages.add(_ChatMessage(
        isAI: false,
        text: text.trim(),
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          isAI: true,
          text: "I love that vision! Here's what I'm creating:\n\n🎨 Style: Cyberpunk Neon\n✨ Effects: Rain particles + fog + parallax depth\n🌈 Colors: Deep purple, electric cyan, neon pink\n🎬 Motion: Gentle drift with reactive lighting\n\nShall I generate it now?",
          timestamp: DateTime.now(),
          actions: ['Generate it!', 'Make it darker', 'Add more particles', 'Try anime style'],
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _ChatMessage {
  final bool isAI;
  final String text;
  final DateTime timestamp;
  final String? previewUrl;
  final List<String>? actions;

  _ChatMessage({
    required this.isAI,
    required this.text,
    required this.timestamp,
    this.previewUrl,
    this.actions,
  });
}
