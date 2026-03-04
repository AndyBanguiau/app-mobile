import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MotDePasseWidget extends StatefulWidget {
  const MotDePasseWidget({super.key});

  static String routeName = 'Mot_de_Passe';
  static String routePath = '/motDePasse';

  @override
  State<MotDePasseWidget> createState() => _MotDePasseWidgetState();
}

class _MotDePasseWidgetState extends State<MotDePasseWidget> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ── Dialog ajouter / modifier ─────────────────────────
  void _afficherDialog({DocumentSnapshot? compte}) {
    final nomController = TextEditingController(text: compte?['nom_organisme'] ?? '');
    final emailController = TextEditingController(text: compte?['email'] ?? '');
    final mdpController = TextEditingController(text: compte?['mot_de_passe'] ?? '');
    bool mdpVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(compte == null ? 'Ajouter un compte' : 'Modifier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomController, decoration: _dialogInput("Nom de l'organisme")),
              const SizedBox(height: 12),
              TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: _dialogInput('Email')),
              const SizedBox(height: 12),
              TextField(
                controller: mdpController,
                obscureText: !mdpVisible,
                decoration: _dialogInput('Mot de passe').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(mdpVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setDialogState(() => mdpVisible = !mdpVisible),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (nomController.text.isEmpty || emailController.text.isEmpty) return;
                final userId = _auth.currentUser!.uid;
                final data = {
                  'nom_organisme': nomController.text,
                  'email': emailController.text,
                  'mot_de_passe': mdpController.text,
                  'user_id': userId,
                };
                if (compte == null) {
                  await _firestore.collection('users').doc(userId).collection('comptes').add(data);
                } else {
                  await compte.reference.update(data);
                }
                Navigator.pop(context);
              },
              child: Text(compte == null ? 'Ajouter' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Supprimer ─────────────────────────────────────────
  void _supprimerCompte(DocumentSnapshot compte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer le compte "${compte['nom_organisme']}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await compte.reference.delete();
              Navigator.pop(context);
            },
            child: Text('Supprimer', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInput(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 50, 0, 0),
                      child: Text('Mot de passe', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: cs.error)),
                    ),
                    // Sous-titre + bouton +
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 21),
                            child: Text('Tous les comptes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: IconButton(
                              onPressed: () => _afficherDialog(),
                              icon: Icon(Icons.add_rounded, color: cs.onSurface.withOpacity(0.6), size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Liste Firestore
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: userId == null
                          ? const Center(child: Text('Non connecté'))
                          : StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('users')
                                  .doc(userId)
                                  .collection('comptes')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator(color: cs.primary));
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 60),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.lock_outline, size: 64, color: cs.onSurface.withOpacity(0.3)),
                                          const SizedBox(height: 16),
                                          Text('Aucun compte enregistré', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                final comptes = snapshot.data!.docs;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: comptes.length,
                                  itemBuilder: (context, index) {
                                    final compte = comptes[index];
                                    return Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.9,
                                            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(compte['nom_organisme'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                                        const SizedBox(height: 4),
                                                        Text(compte['email'], style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(0.6))),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 8),
                                                        child: IconButton(
                                                          onPressed: () => _afficherDialog(compte: compte),
                                                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFF3E0), shape: const CircleBorder()),
                                                          icon: const Icon(Icons.edit_outlined, color: Color(0xFFFF6F00), size: 20),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () => _supprimerCompte(compte),
                                                        style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFEBEE), shape: const CircleBorder()),
                                                        icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // Navbar
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [BoxShadow(color: cs.onSurface.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: Icon(Icons.home_outlined, color: cs.onSurface.withOpacity(0.6)), onPressed: () => Navigator.pushNamed(context, '/accueil')),
                  IconButton(icon: Icon(Icons.lock_outlined, color: cs.primary), onPressed: () {}),
                  IconButton(icon: Icon(Icons.settings, color: cs.onSurface.withOpacity(0.6)), onPressed: () => Navigator.pushNamed(context, '/settings')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
