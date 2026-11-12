import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/selected_baby_provider.dart';
import '../controllers/checklist_controller.dart';
import 'checklist_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger initial checklist fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checklistControllerProvider);
    });
  }

  void _navigateToEvent(String route) {
    context.push(route);
  }

  void _navigateTo(String route) {
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(selectedBabyProvider);
    final babyName = baby?.name ?? 'Bebê';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Olá, $babyName',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.lilacDark,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Quick action buttons
          _buildQuickActions(),
          const Divider(height: 1),
          // Navigation row
          _buildNavigationBar(),
          const Divider(height: 1),
          // Checklist widget
          const Expanded(
            child: ChecklistWidget(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.breakfast_dining,
        label: 'Mamadeira',
        route: '/feeding',
      ),
      _QuickAction(
        icon: Icons.bedtime,
        label: 'Sono',
        route: '/sleep',
      ),
      _QuickAction(
        icon: Icons.baby_changing_station,
        label: 'Fralda',
        route: '/diaper',
      ),
      _QuickAction(
        icon: Icons.bathtub,
        label: 'Banho',
        route: '/bath',
      ),
      _QuickAction(
        icon: Icons.vaccines,
        label: 'Vacina',
        route: '/vaccination',
      ),
      _QuickAction(
        icon: Icons.medical_services,
        label: 'Consulta',
        route: '/appointment',
      ),
      _QuickAction(
        icon: Icons.medication,
        label: 'Medicação',
        route: '/medication',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: actions.map((action) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _QuickActionButton(
                action: action,
                onPressed: () => _navigateToEvent(action.route),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    final navItems = [
      _NavItem(
        icon: Icons.repeat,
        label: 'Rotinas',
        route: '/routines',
      ),
      _NavItem(
        icon: Icons.favorite,
        label: 'Histórico',
        route: '/health',
      ),
      _NavItem(
        icon: Icons.bar_chart,
        label: 'Relatórios',
        route: '/reports',
      ),
      _NavItem(
        icon: Icons.note_alt,
        label: 'Anotações',
        route: '/notes',
      ),
      _NavItem(
        icon: Icons.people,
        label: 'Cuidadores',
        route: '/caregivers',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: navItems.map((item) {
          return InkWell(
            onTap: () => _navigateTo(item.route),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: AppColors.lilacDark,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem(
                Icons.home,
                'Início',
                selected: true,
                onTap: () {},
              ),
              _buildBottomNavItem(
                Icons.repeat,
                'Rotinas',
                onTap: () => _navigateTo('/routines'),
              ),
              _buildBottomNavItem(
                Icons.bar_chart,
                'Relatórios',
                onTap: () => _navigateTo('/reports'),
              ),
              _buildBottomNavItem(
                Icons.people,
                'Cuidadores',
                onTap: () => _navigateTo('/caregivers'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label, {
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.lilacDark : AppColors.textGray,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.lilacDark : AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  final VoidCallback? onPressed;

  const _QuickActionButton({
    required this.action,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.lilac.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lilac.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action.icon,
              color: AppColors.lilacDark,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
