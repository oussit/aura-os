
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/glass_container.dart';
import '../../shared/effects/particle_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentTab = 0;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Background ambient particles
          const ParticleEngine(
            particleCount: 30,
            type: ParticleType.glow,
            colors: [AppColors.neonCyan, AppColors.neonPurple],
            speed: 0.3,
            size: 2,
          ),

          // Main content
          SafeArea(
            child: IndexedStack(
              index: _currentTab,
              children: const [
                _ExploreFeed(),
                _GenerateTab(),
                _SocialFeed(),
                _ProfileTab(),
              ],
            ),
          ),
        ],
      ),

      // Floating Generate FAB
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.3 + _fabController.value * 0.3),
                  blurRadius: 20 + _fabController.value * 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => setState(() => _currentTab = 1),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.auto_awesome, size: 28, color: AppColors.textOnNeon),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blackLight,
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.explore_outlined, Icons.explore, 'Explore', 0),
              _navItem(Icons.wallpaper_outlined, Icons.wallpaper, 'Library', 1),
              const SizedBox(width: 64), // FAB space
              _navItem(Icons.people_outline, Icons.people, 'Social', 2),
              _navItem(Icons.person_outline, Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData outline, IconData filled, String label, int index) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentTab = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive ? AppColors.neonCyan.withOpacity(0.1) : Colors.transparent,
            ),
            child: Icon(
              isActive ? filled : outline,
              color: isActive ? AppColors.neonCyan : AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.neonCyan : AppColors.textTertiary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== EXPLORE FEED (TikTok-style vertical scroll) =====
class _ExploreFeed extends StatelessWidget {
  const _ExploreFeed();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textOnNeon)),
                ),
              ),
              const SizedBox(width: 12),
              const Text('AURA OS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 2)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textSecondary),
              onPressed: () {},
            ),
          ],
        ),

        // Trending Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.fireGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text('TRENDING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 100.ms),

        // Horizontal Style Chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _styleChips.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StyleChip(
                    label: _styleChips[index]['label']!,
                    emoji: _styleChips[index]['emoji']!,
                    isActive: index == 0,
                  ),
                ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.3);
              },
            ),
          ),
        ),

        // Wallpaper Grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _WallpaperCard(index: index)
                  .animate(delay: (80 * index).ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1),
              childCount: 20,
            ),
          ),
        ),
      ],
    );
  }

  static const _styleChips = [
    {'label': 'All', 'emoji': '✨'},
    {'label': 'Cyberpunk', 'emoji': '🌆'},
    {'label': 'Anime', 'emoji': '🌸'},
    {'label': 'AMOLED', 'emoji': '🖤'},
    {'label': 'Sci-Fi', 'emoji': '🚀'},
    {'label': 'Gaming', 'emoji': '🎮'},
    {'label': 'Nature', 'emoji': '🌿'},
    {'label': 'Abstract', 'emoji': '🎨'},
    {'label': 'Cars', 'emoji': '🏎️'},
    {'label': 'Fantasy', 'emoji': '🐉'},
  ];
}

class _StyleChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isActive;

  const _StyleChip({required this.label, required this.emoji, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 24,
      borderColor: isActive ? AppColors.neonCyan : null,
      backgroundColor: isActive ? AppColors.neonCyan.withOpacity(0.1) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.neonCyan : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WallpaperCard extends StatelessWidget {
  final int index;
  const _WallpaperCard({required this.index});

  @override
  Widget build(BuildContext context) {
    // Placeholder gradient cards (would be cached network images)
    final gradients = [
      AppColors.cyberpunkGradient,
      AppColors.auroraGradient,
      AppColors.fireGradient,
      const LinearGradient(colors: [Color(0xFF0080FF), Color(0xFF00F5FF)]),
      const LinearGradient(colors: [Color(0xFFB24BF3), Color(0xFFFF2D95)]),
    ];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/wallpaper/detail'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradients[index % gradients.length],
        ),
        child: Stack(
          children: [
            // Image placeholder
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),

            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _samplePrompts[index % _samplePrompts.length],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 14, color: AppColors.neonPink),
                        const SizedBox(width: 4),
                        Text('${(index + 1) * 127}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.neonCyan, letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Live indicator dot
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonGreen,
                  boxShadow: [BoxShadow(color: AppColors.neonGreen.withOpacity(0.5), blurRadius: 6)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _samplePrompts = [
    'Cyberpunk samurai in neon rain',
    'AMOLED black dragon with glowing eyes',
    'Anime girl under moonlight',
    'Futuristic BMW drifting through Tokyo',
    'Minimal black hole with stars',
    'Liquid chrome wolf with smoke',
    'Neon cityscape at midnight',
    'Galaxy warrior with energy sword',
    'Dark phoenix rising from ashes',
    'Mech warrior in acid rain',
  ];
}

// ===== GENERATE TAB =====
class _GenerateTab extends StatelessWidget {
  const _GenerateTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Generate', style: TextStyle(color: AppColors.textPrimary, fontSize: 24)),
    );
  }
}

// ===== SOCIAL FEED TAB =====
class _SocialFeed extends StatelessWidget {
  const _SocialFeed();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Social', style: TextStyle(color: AppColors.textPrimary, fontSize: 24)),
    );
  }
}

// ===== PROFILE TAB =====
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile', style: TextStyle(color: AppColors.textPrimary, fontSize: 24)),
    );
  }
}
