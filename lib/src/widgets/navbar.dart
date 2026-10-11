import 'package:flutter/material.dart';

/// 底部悬浮导航条目。
class NavItem {
  const NavItem({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  final String title;
}

/// 胶囊样式的悬浮导航栏。
class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.children});
  final List<NavItem> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          margin:
              const EdgeInsets.only(top: 25, right: 25, left: 25, bottom: 25),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withAlpha(10),
                    spreadRadius: 10)
              ]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children.map((item) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: item.onTap,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                              top: 0, bottom: 0, left: 20, right: 20),
                          child: Icon(item.icon, color: Colors.grey),
                        ),
                        Text(
                          item.title,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 10),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
