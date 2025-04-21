import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onScheduledTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onHistoryTap;
  final String activeScreen;
  final int unreadNotificationCount;

  const BottomNavBar({
    Key? key,
    this.onHomeTap = _defaultCallback,
    this.onScheduledTap = _defaultCallback,
    this.onNotificationTap = _defaultCallback,
    this.onHistoryTap = _defaultCallback,
    this.activeScreen = "home",
    this.unreadNotificationCount = 0,
  }) : super(key: key);

  static void _defaultCallback() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.transparent,
        child: Container(
          height: 50.h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffA558E0), Color(0xff5A307A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  children: [
                    _buildNavItem(
                      icon: 'assets/home_icon.png',
                      label: "Home",
                      iconColor: (activeScreen == "home")
                          ? Colors.amber
                          : Colors.white,
                      onTap: onHomeTap,
                    ),
                    SizedBox(width: 10.w),
                    _buildNavItem(
                      icon: 'assets/scheduled_icon.png',
                      label: "Scheduled Tasks",
                      iconColor: (activeScreen == "scheduled")
                          ? Colors.amber
                          : Colors.white,
                      onTap: onScheduledTap,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 50.w),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    _buildNotificationNavItem(
                      icon: 'assets/notification_icon.png',
                      label: "Notifications",
                      iconColor: (activeScreen == "notifications")
                          ? Colors.amber
                          : Colors.white,
                      onTap: onNotificationTap,
                      count: unreadNotificationCount,
                    ),
                    SizedBox(width: 10.w),
                    _buildNavItem(
                      icon: 'assets/history_icon.png',
                      label: "History",
                      iconColor: (activeScreen == "history")
                          ? Colors.amber
                          : Colors.white,
                      onTap: onHistoryTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
    double iconSize = 24,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            color: iconColor,
            width: iconSize.w,
            height: iconSize.h,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationNavItem({
    required String icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
    required int count,
  }) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                color: iconColor,
                width: 24.w,
                height: 24.h,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: -6,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
