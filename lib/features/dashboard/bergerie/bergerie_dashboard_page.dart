import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/bergerie_config.dart';
import '../../../core/config/current_bergerie_config.dart';
import '../../../core/session/current_user_service.dart';
import '../../gestation/models/gestation_model.dart';
import '../../gestation/repositories/firebase_gestation_repository.dart';
import '../../moutons/repository/firebase_mouton_repository.dart';

class BergerieDashboardPage extends StatelessWidget {
  const BergerieDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = CurrentBergerieConfig.instance.config;
    final user = CurrentUserService.instance.currentUser;
    final nom = user?.nomComplet.trim().isNotEmpty == true
        ? user!.nomComplet.trim()
        : 'Responsable';
    final photoUrl = user?.photoUrl?.trim();
    final desktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: config.couleurFond,
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
                photoUrl: photoUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BergerieLogo extends StatelessWidget {
  const _BergerieLogo({
    required this.logo,
    required this.color,
  });

  final String? logo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (logo == null || logo!.isEmpty) {
      return Icon(Icons.home_work_rounded, color: color, size: 44);
    }

    if (logo!.startsWith('http://') || logo!.startsWith('https://')) {
      return Image.network(
        logo!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.home_work_rounded, color: color, size: 44),
      );
    }

    return Image.asset(
      logo!,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.home_work_rounded, color: color, size: 44),
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
    final mobile = MediaQuery.of(context).size.width < 900;
    final session = CurrentUserService.instance;

    return Material(
      color: primary,
      child: SafeArea(
        child: Column(
          children: [
            if (mobile)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Fermer le menu',
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, mobile ? 0 : 16, 16, 14),
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
                    child: _BergerieLogo(
                      logo: config.logo,
                      color: primary,
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
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: orange,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _menu(context, Icons.home_rounded, 'Accueil', '/dashboard/bergerie', true),
                  _section('MON ÉLEVAGE'),
                  if (session.hasPermission('moutons.view'))
                    _menu(context, Icons.pets_rounded, 'Moutons', '/moutons'),
                  if (session.hasPermission('gestations.view'))
                    _menu(context, Icons.favorite_rounded, 'Gestations', '/gestations'),
                  if (session.hasPermission('naissances.view'))
                    _menu(context, Icons.child_friendly_rounded, 'Naissances', '/naissances'),
                  _section('SANTÉ'),
                  if (session.hasPermission('sante.view'))
                    _menu(context, Icons.health_and_safety_rounded, 'Carnet de santé', '/carnet-sante'),
                  if (session.hasPermission('veto.view'))
                    _menu(context, Icons.medical_services_rounded, 'Mon Carnet Véto', '/allo-veto'),
                  _section('ALIMENTATION'),
                  if (session.hasPermission('alimentation.view'))
                    _menu(context, Icons.grass_rounded, 'Alimentation', '/alimentation'),
                  _soon(context, Icons.inventory_2_rounded, 'Stocks'),
                  _section('ACTIVITÉS'),
                  if (session.hasPermission('interventions.view'))
                    _menu(context, Icons.assignment_rounded, 'Interventions', '/interventions'),
                  if (session.hasPermission('depenses.view') ||
                      session.hasPermission('depenses.edit') ||
                      session.hasPermission('ventes.view') ||
                      session.hasPermission('ventes.edit'))
                    _section('FINANCES'),
                  if (session.hasPermission('depenses.view') ||
                      session.hasPermission('depenses.edit') ||
                      session.hasPermission('ventes.view') ||
                      session.hasPermission('ventes.edit'))
                    _menu(context, Icons.account_balance_wallet_rounded, 'Finances', '/finances'),
                  if (session.hasPermission('rapports_financiers.view'))
                    _section('RAPPORTS'),
                  if (session.hasPermission('rapports_financiers.view'))
                    _menu(context, Icons.bar_chart_rounded, 'Rapports', '/rapports'),
                  const Divider(color: Colors.white24),
                  if (session.hasPermission('parametres.view'))
                    _menu(context, Icons.settings_rounded, 'Paramètres', '/parametres'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.white),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                CurrentUserService.instance.clear();
                CurrentBergerieConfig.instance.clear();
                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;
                Router.neglect(
                  context,
                  () => context.go('/login'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _menu(
    BuildContext context,
    IconData icon,
    String text,
    String route, [
    bool selected = false,
  ]) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.white, size: 21),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
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
  const _DashboardContent({
    required this.config,
    required this.nomUtilisateur,
    required this.photoUrl,
  });

  final BergerieConfig config;
  final String nomUtilisateur;
  final String? photoUrl;

  Future<List<int>> _chargerStatistiques() async {
    final moutonRepository = FirebaseMoutonRepository();
    final gestationRepository = FirebaseGestationRepository();
    final sessionBergerieId = CurrentUserService.instance.bergerieId?.trim();

    final moutonsFuture = sessionBergerieId != null && sessionBergerieId.isNotEmpty
        ? moutonRepository.getMoutonsByBergerie(sessionBergerieId)
        : moutonRepository.getMoutons();

    final gestationsFuture = gestationRepository.getGestationsEnCours();

    final results = await Future.wait([
      moutonsFuture,
      gestationsFuture,
    ]);

    final moutons = results[0] as List;
    final gestations = results[1] as List;

    return [moutons.length, gestations.length];
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 700;
    final primary = config.couleurPrimaire;
    final orange = config.couleurSecondaire;
    final imageAccueil = config.imageAccueil?.trim();
    final imageWidth = compact ? 92.0 : 175.0;
    final imageHeight = compact ? 82.0 : 120.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, Color.lerp(primary, Colors.white, .18)!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $nomUtilisateur 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Voici la situation de votre élevage aujourd’hui.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      if (config.slogan != null) ...[
                        const SizedBox(height: 7),
                        Text(
                          config.slogan!,
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                if (imageAccueil != null && imageAccueil.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageAccueil,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: imageWidth,
                        height: imageHeight,
                        color: Colors.white.withValues(alpha: .12),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.white70,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                      ? NetworkImage(photoUrl!)
                      : null,
                  child: photoUrl == null || photoUrl!.isEmpty
                      ? Icon(Icons.person_rounded, color: primary)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<int>>(
            future: _chargerStatistiques(),
            builder: (context, snapshot) {
              final moutonsCount = snapshot.hasData ? snapshot.data![0] : 0;
              final gestationsCount = snapshot.hasData ? snapshot.data![1] : 0;
              final loading = snapshot.connectionState == ConnectionState.waiting;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 1150
                      ? 4
                      : width >= 760
                          ? 2
                          : 1;

                  final height = columns == 4
                      ? 118.0
                      : columns == 2
                          ? 112.0
                          : 100.0;

                  final moutonsValue = loading ? '…' : '$moutonsCount';
                  final gestationsValue = loading ? '…' : '$gestationsCount';

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: height,
                    ),
                    itemBuilder: (_, index) {
                      final stats = [
                        _StatData(Icons.pets_rounded, 'Moutons', moutonsValue, 'Votre troupeau', primary),
                        _StatData(Icons.favorite_rounded, 'Gestations', gestationsValue, 'En cours', orange),
                        _StatData(Icons.health_and_safety_rounded, 'À surveiller', '0', 'Aucune alerte', primary),
                        _StatData(Icons.grass_rounded, 'Alimentation', 'OK', 'Stocks à vérifier', orange),
                      ];
                      final stat = stats[index];
                      return _Stat(
                        icon: stat.icon,
                        title: stat.title,
                        value: stat.value,
                        note: stat.note,
                        color: stat.color,
                      );
                    },
                  );
                },
              );
            },
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
                const Expanded(
                  child: Text(
                    'Vos dernières activités apparaîtront ici. Commencez par enregistrer votre premier mouton.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  const _StatData(this.icon, this.title, this.value, this.note, this.color);
  final IconData icon;
  final String title;
  final String value;
  final String note;
  final Color color;
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.title,
    required this.value,
    required this.note,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String note;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withValues(alpha: .12)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: .10),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
                  ),
                  Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Alerts extends StatelessWidget {
  const _Alerts({required this.primary});
  final Color primary;

  Future<List<GestationModel>> _chargerRappels() async {
    final gestations = await FirebaseGestationRepository().getGestationsEnCours();

    final rappels = gestations.where((g) {
      return !g.miseBasEffectuee && (g.procheDeLaMiseBas || g.estEnRetard);
    }).toList();

    rappels.sort((a, b) => a.dateProbableMiseBas.compareTo(b.dateProbableMiseBas));
    return rappels;
  }

  String _message(GestationModel g) {
    if (g.estEnRetard) {
      final joursRetard = DateTime.now().difference(g.dateProbableMiseBas).inDays;
      if (joursRetard <= 0) return 'Mise bas prévue aujourd’hui';
      return 'Mise bas en retard de $joursRetard jour${joursRetard > 1 ? 's' : ''}';
    }

    final jours = g.joursRestants;
    if (jours <= 0) return 'Mise bas prévue aujourd’hui';
    if (jours == 1) return 'Mise bas prévue demain';
    return 'Mise bas prévue dans $jours jours';
  }

  @override
  Widget build(BuildContext context) => _Panel(
        title: '🔔 Alertes & priorités',
        child: FutureBuilder<List<GestationModel>>(
          future: _chargerRappels(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _Row(
                icon: Icons.hourglass_top_rounded,
                color: Colors.orange,
                text: 'Chargement des rappels…',
              );
            }

            if (snapshot.hasError) {
              return _Row(
                icon: Icons.error_outline_rounded,
                color: Colors.red,
                text: 'Impossible de charger les rappels',
              );
            }

            final rappels = snapshot.data ?? const <GestationModel>[];

            if (rappels.isEmpty) {
              return Column(
                children: [
                  const _Row(
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    text: 'Aucune alerte urgente',
                  ),
                  _Row(
                    icon: Icons.info_rounded,
                    color: primary,
                    text: 'Aucun rappel de mise bas pour le moment',
                  ),
                ],
              );
            }

            return Column(
              children: [
                ...rappels.take(3).map((g) {
                  final urgent = g.estEnRetard || g.joursRestants <= 1;
                  final color = urgent ? Colors.red : Colors.orange;
                  final date = '${g.dateProbableMiseBas.day}/${g.dateProbableMiseBas.month}/${g.dateProbableMiseBas.year}';

                  return _Row(
                    icon: urgent ? Icons.warning_rounded : Icons.event_available_rounded,
                    color: color,
                    text: '${g.nomFemelle} — ${_message(g)} — $date',
                    onTap: () => context.go('/gestations'),
                  );
                }),
                if (rappels.length > 3)
                  _Row(
                    icon: Icons.more_horiz_rounded,
                    color: primary,
                    text: '${rappels.length - 3} autre${rappels.length - 3 > 1 ? 's' : ''} rappel${rappels.length - 3 > 1 ? 's' : ''}',
                    onTap: () => context.go('/gestations'),
                  ),
              ],
            );
          },
        ),
      );
}

class _Actions extends StatelessWidget {
  const _Actions({required this.primary, required this.orange});
  final Color primary;
  final Color orange;

  @override
  Widget build(BuildContext context) => _Panel(
        title: '⚡ Actions rapides',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 500 ? 3 : 2;
            final height = columns == 3 ? 78.0 : 72.0;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                mainAxisExtent: height,
              ),
              itemBuilder: (_, index) {
                final actions = [
                  _ActionData(Icons.pets_rounded, 'Ajouter un mouton', primary, '/moutons'),
                  _ActionData(Icons.favorite_rounded, 'Enregistrer une saillie', orange, '/gestations'),
                  _ActionData(Icons.medical_services_rounded, 'Enregistrer un soin', primary, '/carnet-sante'),
                  _ActionData(Icons.assignment_rounded, 'Enregistrer une intervention', primary, '/interventions'),
                  _ActionData(Icons.account_balance_wallet_rounded, 'Voir mes finances', orange, '/finances'),
                ];
                final action = actions[index];
                return _Action(
                  icon: action.icon,
                  text: action.text,
                  color: action.color,
                  route: action.route,
                );
              },
            );
          },
        ),
      );
}

class _ActionData {
  const _ActionData(this.icon, this.text, this.color, this.route);
  final IconData icon;
  final String text;
  final Color color;
  final String? route;
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
        onTap: route == null
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cette fonction sera disponible prochainement.')),
                )
            : () => context.go(route!),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 5),
              Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.color, required this.text, this.onTap});
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: content,
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}
