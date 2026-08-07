import 'package:flutter/material.dart';

import 'widgets/dashboard_drawer.dart';

import 'widgets/dashboard_admin_body.dart';

class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: isDesktop
          ? null
          : AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "SET'SI SA MBAAR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      drawer: isDesktop
          ? null
          : DashboardDrawer(selectedIndex: 0),

      body: SafeArea(
        child: Row(
          children: [

            if (isDesktop)
              SizedBox(
                width: 260,
                child: DashboardDrawer(selectedIndex: 0),
              ),

            Expanded(
              child: Column(
                children: [

                  if (isDesktop)
                    Container(
                      height: 75,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Row(
                        children: [

                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Rechercher...",
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_none),
                          ),

                          const SizedBox(width: 10),

                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFF0B6E4F),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "Administrateur",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                "En ligne",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: const DashboardAdminBody(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}