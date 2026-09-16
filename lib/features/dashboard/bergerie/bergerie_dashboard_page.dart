import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/bergerie_config.dart';
import '../../../core/config/current_bergerie_config.dart';
import '../../../core/session/current_user_service.dart';

class BergerieDashboardPage extends StatelessWidget {
  const BergerieDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = CurrentBergerieConfig.instance.config;
    final user = CurrentUserService.instance.currentUser;
    final nom = user?.nomComplet.trim().isNotEmpty == true
        ? user!.nomComplet.trim()
        : 'Responsable';
    final desktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: desktop
          ? null
          : AppBar(
              backgroundColor: config.couleurPrimaire,
              foregroundColor: Colors.white,
              title: Text(config.nomBergerie),
            ),
      drawer: desktop ? null : BergerieDrawer(config: config),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop)
              SizedBox(width: 245, child: BergerieDrawer(config: config)),
            Expanded(
              child: _DashboardContent(
                config: config,
                nomUtilisateur: nom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BergerieDrawer extends StatelessWidget {
  const BergerieDrawer({super.key, required this.config});

  final BergerieConfig config;

  @override
  Widget build(BuildContext context) {
    final primary = config.couleurPrimaire;
    final orange = config.couleurSecondaire;

    return Material(
      color: primary,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/images/bergerie_baraka_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.home_work_rounded,
                        color: primary,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    config.nomBergerie,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (config.slogan != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      config.slogan!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 16), color: orange),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _menu(context, Icons.home_rounded, 'Accueil', '/dashboard/bergerie', true),
                  _section('MON ÉLEVAGE'),
                  _menu(context, Icons.pets_rounded, 'Moutons', '/moutons'),
                  _menu(context, Icons.favorite_rounded, 'Gestations', '/gestations'),
                  _soon(context, Icons.child_friendly_rounded, 'Naissances'),
                  _section('SANTÉ'),
                  _menu(context, Icons.medical_services_rounded, 'Allô Véto', '/allo-veto'),
                  _soon(context, Icons.health_and_safety_rounded, 'Suivi sanitaire'),
                  _soon(context, Icons.vaccines_rounded, 'Traitements & vaccins'),
                  _section('ALIMENTATION'),
                  _soon(context, Icons.grass_rounded, 'Alimentation'),
                  _soon(context, Icons.inventory_2_rounded, 'Stocks'),
                  _section('ACTIVITÉS'),
                  _menu(context, Icons.assignment_rounded, 'Interventions', '/interventions'),
                  _section('RAPPORTS'),
                  _menu(context, Icons.bar_chart_rounded, 'Rapports', '/rapports-financiers'),
                  const Divider(color: Colors.white24),
                  _soon(context, Icons.person_rounded, 'Mon compte'),
                  _soon(context, Icons.settings_rounded, 'Paramètres'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.white),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w800)),
      );

  Widget _menu(BuildContext context, IconData icon, String text, String route, [bool selected = false]) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.white, size: 21),
      title: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      tileColor: selected ? config.couleurSecondaire : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      onTap: () => context.go(route),
    );
  }

  Widget _soon(BuildContext context, IconData icon, String text) => ListTile(
        dense: true,
        leading: Icon(icon, color: Colors.white54, size: 21),
        title: Text(text, style: const TextStyle(color: Colors.white70)),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$text sera disponible prochainement.')),
        ),
      );
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.config, required this.nomUtilisateur});

  final BergerieConfig config;
  final String nomUtilisateur;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 700;
    final primary = config.couleurPrimaire;
    final orange = config.couleurSecondaire;

    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primary, Color.lerp(primary, Colors.white, .18)!]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour, $nomUtilisateur 👋', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 5),
                      const Text('Voici la situation de votre élevage aujourd’hui.', style: TextStyle(color: Colors.white70)),
                      if (config.slogan != null) ...[
                        const SizedBox(height: 7),
                        Text(config.slogan!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                const CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.person_rounded, color: Colors.blue)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: compact ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: compact ? 1.45 : 1.75,
            children: [
              _Stat(icon: Icons.pets_rounded, title: 'Moutons', value: '0', note: 'Votre troupeau', color: primary),
              _Stat(icon: Icons.favorite_rounded, title: 'Gestations', value: '0', note: 'En cours', color: orange),
              _Stat(icon: Icons.health_and_safety_rounded, title: 'À surveiller', value: '0', note: 'Aucune alerte', color: primary),
              _Stat(icon: Icons.grass_rounded, title: 'Alimentation', value: 'OK', note: 'Stocks à vérifier', color: orange),
            ],
          ),
          const SizedBox(height: 16),
          if (compact) ...[
            _Alerts(primary: primary),
            const SizedBox(height: 14),
            _Actions(primary: primary, orange: orange),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Alerts(primary: primary)),
                const SizedBox(width: 16),
                Expanded(child: _Actions(primary: primary, orange: orange)),
              ],
            ),
          const SizedBox(height: 16),
          _Panel(
            title: '📋 Activité récente',
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: primary),
                const SizedBox(width: 10),
                const Expanded(child: Text('Vos dernières activités apparaîtront ici. Commencez par enregistrer votre premier mouton.', style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.title, required this.value, required this.note, required this.color});
  final IconData icon;
  final String title;
  final String value;
  final String note;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: color.withValues(alpha: .12))),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: color.withValues(alpha: .10), child: Icon(icon, color: color)),
            const SizedBox(width: 9),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)), Text(note, style: const TextStyle(fontSize: 10, color: Colors.black54))])),
          ],
        ),
      );
}

class _Alerts extends StatelessWidget {
  const _Alerts({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) => _Panel(
        title: '🔔 Alertes & priorités',
        child: Column(children: [
          _Row(icon: Icons.check_circle_rounded, color: Colors.green, text: 'Aucune alerte urgente'),
          _Row(icon: Icons.info_rounded, color: primary, text: 'Les rappels importants apparaîtront ici'),
        ]),
      );
}

class _Actions extends StatelessWidget {
  const _Actions({required this.primary, required this.orange});
  final Color primary;
  final Color orange;

  @override
  Widget build(BuildContext context) => _Panel(
        title: '⚡ Actions rapides',
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.35,
          children: [
            _Action(icon: Icons.pets_rounded, text: 'Ajouter un mouton', color: primary, route: '/moutons'),
            _Action(icon: Icons.favorite_rounded, text: 'Enregistrer une saillie', color: orange, route: '/gestations'),
            _Action(icon: Icons.medical_services_rounded, text: 'Enregistrer un soin', color: primary, route: '/allo-veto'),
            _Action(icon: Icons.grass_rounded, text: 'Ajouter alimentation', color: orange),
            _Action(icon: Icons.assignment_rounded, text: 'Enregistrer activité', color: primary, route: '/interventions'),
            _Action(icon: Icons.bar_chart_rounded, text: 'Voir mes rapports', color: orange, route: '/rapports-financiers'),
          ],
        ),
      );
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.text, required this.color, this.route});
  final IconData icon;
  final String text;
  final Color color;
  final String? route;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: route == null ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cette fonction sera disponible prochainement.'))) : () => context.go(route!),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withValues(alpha: .07), borderRadius: BorderRadius.circular(13)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 23), const SizedBox(height: 5), Text(text, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700))]),
        ),
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: color.withValues(alpha: .06), borderRadius: BorderRadius.circular(11)),
        child: Row(children: [Icon(icon, color: color, size: 21), const SizedBox(width: 9), Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))]),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 12), child]),
      );
}
