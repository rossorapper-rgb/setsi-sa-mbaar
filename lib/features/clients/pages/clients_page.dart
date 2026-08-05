import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/client_model.dart';
import '../providers/client_provider.dart';
import '../widgets/client_actions_bar.dart';
import '../widgets/client_card.dart';
import '../widgets/client_search_bar.dart';
import '../widgets/client_stats.dart';
import 'client_details_page.dart';
import 'edit_client_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() =>
      _ClientsPageState();
}

class _ClientsPageState
    extends ConsumerState<ClientsPage> {
bool _isRefreshing = false;

Future<void> _refreshClients() async {
if (_isRefreshing) return;

setState(() {
_isRefreshing = true;
});

try {
ref.invalidate(clientsProvider);

await ref.read(clientsProvider.future);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Liste des clients actualisée",
),
duration: Duration(seconds: 2),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
backgroundColor: Colors.red,
content: Text(
"Erreur lors de l'actualisation : $e",
),
),
);
} finally {
if (mounted) {
setState(() {
_isRefreshing = false;
});
}
}
}

@override
Widget build(BuildContext context) {
final clientsAsync = ref.watch(clientsProvider);
return Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),

    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.go('/dashboard/admin');
        },
      ),
      title: const Text(
        "Gestion des clients",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    ),

    body: SafeArea(
      child: clientsAsync.when(
loading: () => const Center(
child: CircularProgressIndicator(),
),

error: (error, stackTrace) => Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.error_outline,
size: 70,
color: Colors.red,
),
const SizedBox(height: 20),
const Text(
"Impossible de charger les clients",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
Text(
error.toString(),
textAlign: TextAlign.center,
),
const SizedBox(height: 20),
FilledButton.icon(
onPressed: () {
ref.invalidate(clientsProvider);
},
icon: const Icon(Icons.refresh),
label: const Text("Réessayer"),
),
],
),
),
),

data: (clients) {
final totalClients = clients.length;

final totalMoutons = clients.fold<int>(
0,
(total, client) =>
total + client.nombreMoutons,
);

final totalTroupeaux = clients.fold<int>(
0,
(total, client) =>
total + client.nombreTroupeaux,
);

return Padding(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [


ClientStats(
totalClients: totalClients,
totalMoutons: totalMoutons,
totalTroupeaux: totalTroupeaux,
),

const SizedBox(height: 24),
  ClientActionsBar(
    totalClients: totalClients,
    isRefreshing: _isRefreshing,

    onAdd: () {
      context.push('/clients/add');
    },

    onRefresh: _isRefreshing
        ? null
        : () async {
      await _refreshClients();
    },

    onExportPdf: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Export PDF bientôt disponible",
          ),
        ),
      );
    },

    onExportExcel: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Export Excel bientôt disponible",
          ),
        ),
      );
    },
  ),

const SizedBox(height: 24),

ClientSearchBar(
hintText: "Rechercher un client...",
onChanged: (value) {
ref
.read(
rechercheClientTexteProvider.notifier,
)
.state = value;
},
),

const SizedBox(height: 24),

Expanded(
child: Consumer(
builder: (context, ref, _) {
final clientsFiltres =
ref.watch(clientsFiltresProvider);

return clientsFiltres.when(
loading: () => const Center(
child:
CircularProgressIndicator(),
),

error: (error, stack) => Center(
child: Text(
error.toString(),
),
),

data: (liste) {
if (liste.isEmpty) {
return const Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment
.center,
children: [
Icon(
Icons.people_outline,
size: 80,
color: Colors.grey,
),
SizedBox(height: 16),
Text(
"Aucun client trouvé",
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
],
),
);
}

return ListView.builder(
itemCount: liste.length,
itemBuilder:
(context, index) {
final ClientModel client =
liste[index];
return ClientCard(
  client: client,

  onView: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientDetailsPage(
          client: client,
        ),
      ),
    );
  },

  onEdit: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditClientPage(
          client: client,
        ),
      ),
    );
  },

  onCall: () async {
    final uri = Uri(
      scheme: 'tel',
      path: client.telephone,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  },

  onWhatsapp: () async {
    final numero = client.telephone.replaceAll(' ', '');

    final uri = Uri.parse(
      'https://wa.me/$numero',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  },
);
},
);
},
);
},
),
),
],
),
);
},
),
),
);
}
}