class PermissionGroup {
  const PermissionGroup({
    required this.label,
    required this.viewKey,
    this.editKey,
  });

  final String label;
  final String viewKey;
  final String? editKey;
}

const permissionGroups = <PermissionGroup>[
  PermissionGroup(label: "🐑 Moutons", viewKey: "moutons.view", editKey: "moutons.edit"),
  PermissionGroup(label: "🤰 Gestations", viewKey: "gestations.view", editKey: "gestations.edit"),
  PermissionGroup(label: "👶 Naissances", viewKey: "naissances.view", editKey: "naissances.edit"),
  PermissionGroup(label: "🩺 Carnet de santé", viewKey: "sante.view", editKey: "sante.edit"),
  PermissionGroup(label: "🧑‍⚕️ Carnet Véto", viewKey: "veto.view", editKey: "veto.edit"),
  PermissionGroup(label: "🌾 Alimentation", viewKey: "alimentation.view", editKey: "alimentation.edit"),
  PermissionGroup(label: "📋 Interventions", viewKey: "interventions.view", editKey: "interventions.edit"),
  PermissionGroup(label: "💰 Dépenses", viewKey: "depenses.view", editKey: "depenses.edit"),
  PermissionGroup(label: "💵 Ventes", viewKey: "ventes.view", editKey: "ventes.edit"),
  PermissionGroup(label: "📊 Rapports financiers", viewKey: "rapports_financiers.view"),
  PermissionGroup(label: "👥 Utilisateurs", viewKey: "utilisateurs.view", editKey: "utilisateurs.manage"),
  PermissionGroup(label: "⚙️ Paramètres", viewKey: "parametres.view", editKey: "parametres.edit"),
];

Map<String, bool> createDefaultPermissions() {
  return {
    for (final group in permissionGroups)
      group.viewKey: true,
    for (final group in permissionGroups)
      if (group.editKey != null) group.editKey!: true,
  };
}

Map<String, bool> normalizePermissions(Map<String, bool> source) {
  final defaults = createDefaultPermissions();
  if (source.isEmpty) return defaults;

  for (final key in defaults.keys) {
    defaults[key] = source[key] ?? false;
  }

  for (final entry in source.entries) {
    if (!defaults.containsKey(entry.key)) {
      defaults[entry.key] = entry.value;
    }
  }

  return defaults;
}
