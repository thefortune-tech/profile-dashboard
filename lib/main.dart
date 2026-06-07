import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProfileEvent{}
class ToggleProfile extends ProfileEvent{}
class SwitchTab extends ProfileEvent{
  final int index;
  SwitchTab(this.index);
}

 class ProfileState{
  final bool isExpanded;
  final int activeTab;

  ProfileState({
    required this.activeTab,
    required this.isExpanded
  });
  ProfileState copyWith({bool ? isExpanded, int ? activeTab}){
    return ProfileState(
      activeTab: activeTab?? this.activeTab, 
      isExpanded: isExpanded ?? this.isExpanded
      );
  }
 }

class ProfileBloc extends Bloc<ProfileEvent, ProfileState>{
  ProfileBloc():super(ProfileState(activeTab: 0, isExpanded:false)){
    on<ToggleProfile>((event,emit){
      emit(state.copyWith(isExpanded: !state.isExpanded));
    });

    on<SwitchTab>((event , emit){
      emit(state.copyWith(activeTab: event.index));
    });
  }
}

void main() {
  runApp(
    BlocProvider(
      create: (_) => ProfileBloc(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<String> _tabs = ['Posts', 'Followers', 'Following'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Card
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () =>
                        context.read<ProfileBloc>().add(ToggleProfile()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: state.isExpanded
                              ? const Color(0xFF378ADD)
                              : Colors.white12,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF378ADD)
                                      .withOpacity(0.2),
                                  border: Border.all(
                                    color: const Color(0xFF378ADD),
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'AD',
                                    style: TextStyle(
                                      color: Color(0xFF378ADD),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Adeyemi Fortune',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '@Fortune_Dev',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                state.isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white54,
                              ),
                            ],
                          ),

                          // Expanded content
                          if (state.isExpanded) ...[
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 12),
                            Text(
                              'Flutter Developer | YouTube @Fortune_Dev\nBuilding career-level Flutter apps 🚀',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _statItem('42', 'Days'),
                                _statItem('7', 'Videos'),
                                _statItem('Week 3', 'Progress'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Stats Row
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Row(
                    children: [
                      Expanded(
                          child: _metricCard('Posts', '128', Icons.grid_on)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _metricCard(
                              'Followers', '2.4K', Icons.people)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _metricCard(
                              'Following', '312', Icons.person_add)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tabs
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      // Tab bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: List.generate(
                            _tabs.length,
                            (index) => Expanded(
                              child: GestureDetector(
                                onTap: () => context
                                    .read<ProfileBloc>()
                                    .add(SwitchTab(index)),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: state.activeTab == index
                                        ? const Color(0xFF378ADD)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _tabs[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: state.activeTab == index
                                          ? Colors.white
                                          : Colors.white38,
                                      fontWeight: state.activeTab == index
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tab content
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildTabContent(state.activeTab),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int tab) {
    switch (tab) {
      case 0:
        return GridView.builder(
          key: const ValueKey(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF378ADD).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '📱',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      case 1:
        return ListView.builder(
          key: const ValueKey(1),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      const Color(0xFF378ADD).withOpacity(0.2),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Color(0xFF378ADD)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Follower ${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      case 2:
        return ListView.builder(
          key: const ValueKey(2),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      const Color(0xFF378ADD).withOpacity(0.2),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Color(0xFF378ADD)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Following ${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF378ADD), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}