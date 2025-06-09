import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/badge_service.dart' as badge_service;

class BadgeCollectionPage extends StatefulWidget {
  const BadgeCollectionPage({super.key});

  @override
  State<BadgeCollectionPage> createState() => _BadgeCollectionPageState();
}

class _BadgeCollectionPageState extends State<BadgeCollectionPage>
    with SingleTickerProviderStateMixin {
  badge_service.BadgeCollection? _badgeCollection;
  bool _isLoading = true;
  late TabController _tabController;
  String _selectedFilter = 'all'; // 'all', 'earned', 'unearned'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBadges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoading = true);
    try {
      final badgeCollection = await badge_service.BadgeService.getBadgeCollection();
      if (mounted) {
        setState(() {
          _badgeCollection = badgeCollection;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading badges: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Badge Collection',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _badgeCollection == null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading your badge collection...',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading badges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please try again later',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadBadges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final collection = _badgeCollection!;
    
    return Column(
      children: [
        _buildStatsHeader(collection),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllBadgesTab(collection),
              _buildEarnedBadgesTab(collection),
              _buildUnearnedBadgesTab(collection),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(BadgeCollection collection) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.emoji_events,
                label: 'Earned',
                value: '${collection.earnedCount}',
                color: Colors.white,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.lock_outline,
                label: 'Locked',
                value: '${collection.unearnedBadges.length}',
                color: Colors.white,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.collections_bookmark,
                label: 'Total',
                value: '${collection.totalBadges}',
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Collection Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${collection.completionPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: collection.completionPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'All Badges'),
          Tab(text: 'Earned'),
          Tab(text: 'Locked'),
        ],
      ),
    );
  }

  Widget _buildAllBadgesTab(BadgeCollection collection) {
    final allBadges = [...collection.earnedBadges, ...collection.unearnedBadges];
    final userBadgeIds = collection.earnedBadges.map((b) => b.id).toSet();
    
    return _buildBadgeGrid(allBadges, userBadgeIds);
  }

  Widget _buildEarnedBadgesTab(BadgeCollection collection) {
    final userBadgeIds = collection.earnedBadges.map((b) => b.id).toSet();
    
    if (collection.earnedBadges.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events,
        title: 'No badges earned yet',
        subtitle: 'Start exploring landmarks to earn your first badge!',
      );
    }
    
    return _buildBadgeGrid(collection.earnedBadges, userBadgeIds);
  }

  Widget _buildUnearnedBadgesTab(BadgeCollection collection) {
    if (collection.unearnedBadges.isEmpty) {
      return _buildEmptyState(
        icon: Icons.celebration,
        title: 'All badges earned!',
        subtitle: 'Congratulations! You\'ve collected all available badges.',
      );
    }
    
    return _buildBadgeGrid(collection.unearnedBadges, <String>{});
  }

  Widget _buildBadgeGrid(List<Badge> badges, Set<String> earnedBadgeIds) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          final isEarned = earnedBadgeIds.contains(badge.id);
          return _buildBadgeCard(badge, isEarned);
        },
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge, bool isEarned) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? Colors.orange.shade200 : Colors.grey.shade300,
          width: isEarned ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isEarned 
                ? Colors.orange.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isEarned
                  ? LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade600],
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    ),
            ),
            child: badge.iconUrl.isNotEmpty
                ? ClipOval(
                    child: ColorFiltered(
                      colorFilter: isEarned
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : ColorFilter.mode(
                              Colors.grey.shade400,
                              BlendMode.saturation,
                            ),
                      child: Image.network(
                        badge.iconUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.emoji_events,
                          color: isEarned ? Colors.white : Colors.grey.shade600,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    Icons.emoji_events,
                    color: isEarned ? Colors.white : Colors.grey.shade600,
                    size: 30,
                  ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              badge.name,
              style: TextStyle(
                color: isEarned ? Colors.black87 : Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isEarned) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.lock,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 