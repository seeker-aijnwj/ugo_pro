import 'package:flutter/material.dart';
import 'package:ugo_pro/core/themes/admin_light_theme.dart';
import 'package:ugo_pro/data/services/mock_data_service.dart';
import '../../../data/models/mocks/mock_transaction.dart';
// + Vos imports (models, service, theme...)

class FinanceView extends StatefulWidget {
  const FinanceView({super.key});

  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView> {
  // État local
  MockTransaction? _selectedTransaction;
  
  // Pour éviter de recharger la liste à chaque clic, on peut stocker le future
  late Future<List<MockTransaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _transactionsFuture = MockDataService.getTransactions();
    });
  }
  @override
  Widget build(BuildContext context) {
    // 1. DÉTECTION DE LA TAILLE DE L'ÉCRAN
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: Colors.white, // Fond propre
      // Le FloatingActionButton est idéal pour le mobile, mais ici on l'a mis dans le header liste pour Desktop
      // On peut l'ajouter ici pour le mobile si besoin.
      
      body: isDesktop 
          ? _buildDesktopLayout() 
          : _buildMobileLayout(),
    );
  }

  // --- LAYOUTS ---

  // VUE BUREAU (Split View : Liste + Détails)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // ZONE 2 : LA LISTE (30% de l'espace ou fixe)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildListHeader(isDesktop: true),
              Expanded(child: _buildTransactionList(isDesktop: true)),
            ],
          ),
        ),
        
        VerticalDivider(width: 1, color: Colors.grey.shade300),

        // ZONE 3 : LES DÉTAILS / WALLET (70% de l'espace)
        Expanded(
          flex: 7,
          child: Container(
            color: Colors.grey[50], // Fond légèrement grisé pour la zone de travail
            child: _selectedTransaction != null 
                ? _buildTransactionReceipt(isDialog: false) // Vue détail transaction
                : _buildGlobalWalletView(),                 // Vue par défaut (Wallet)
          ),
        ),
      ],
    );
  }

  // VUE MOBILE (Liste uniquement)
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildListHeader(isDesktop: false),
        Expanded(child: _buildTransactionList(isDesktop: false)),
      ],
    );
  }

  // --- WIDGETS COMMUNS ---

  Widget _buildListHeader({required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Text("TRANSACTIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: UGOAdminTheme.primaryBlue)),
          const Spacer(),
          // Bouton d'ajout
          IconButton(
            icon: const Icon(Icons.add_circle, color: UGOAdminTheme.accentOrange, size: 32),
            tooltip: "Nouvelle transaction",
            onPressed: () => _showAddTransactionDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList({required bool isDesktop}) {
    return FutureBuilder<List<MockTransaction>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucune transaction."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(0),
          itemCount: snapshot.data!.length,
          separatorBuilder: (c, i) => const Divider(height: 1, indent: 70),
          itemBuilder: (context, index) {
            final transactionX = snapshot.data![index];
            final isPositive = transactionX.montant > 0;
            final isPending = transactionX.statut == 'en_attente';

            return ListTile(
              // Si Desktop : on met en surbrillance l'élément sélectionné
              selected: isDesktop && _selectedTransaction?.id == transactionX.id,
              selectedTileColor: UGOAdminTheme.primaryBlue.withValues(alpha: .1),
              
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange.withValues(alpha: .1) : (isPositive ? Colors.green.withValues(alpha: .1) : Colors.red.withValues(alpha: .1)),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Icon(
                  isPending ? Icons.hourglass_empty : (isPositive ? Icons.arrow_downward : Icons.arrow_upward),
                  color: isPending ? Colors.orange : (isPositive ? Colors.green : Colors.red),
                  size: 20
                ),
              ),
              title: Text(transactionX.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text("${transactionX.date.hour}:${transactionX.date.minute} • ${transactionX.operateur}", style: const TextStyle(fontSize: 11)),
              trailing: Text(
                "${isPositive ? '+' : ''}${transactionX.montant.toInt()} F",
                style: TextStyle(fontWeight: FontWeight.bold, color: isPositive ? Colors.green[700] : Colors.red[700]),
              ),
              onTap: () {
                if (isDesktop) {
                  // Desktop : Mise à jour de la Zone 3
                  setState(() => _selectedTransaction = transactionX);
                } else {
                  // Mobile : Navigation vers une nouvelle page
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text("Détails Transaction")),
                      body: _buildTransactionReceipt(isDialog: false),
                    ))
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // --- VUES DE DÉTAILS (ZONE 3) ---

  Widget _buildGlobalWalletView() {
    return Column(
      children: [
        // Carte Wallet
        Container(
          padding: const EdgeInsets.all(30),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [UGOAdminTheme.primaryBlue, Color(0xFF1E88E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Solde Disponible", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 10),
              const Text("2 450 000 FCFA", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              Wrap( // Wrap gère mieux les petits écrans que Row
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildWalletBadge(Icons.call_made, "Entrées: +3.2M", Colors.greenAccent),
                  _buildWalletBadge(Icons.call_received, "Sorties: -750k", Colors.orangeAccent),
                ],
              )
            ],
          ),
        ),
        // Actions
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
               _buildActionCard(Icons.account_balance, "Virement Bancaire", "Vers NSIA Banque"),
               const SizedBox(height: 10),
               _buildActionCard(Icons.payments, "Commissions", "Payer les partenaires"),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWalletBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, color: color, size: 14), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))]
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String sub) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: UGOAdminTheme.primaryBlue.withValues(alpha: .1), borderRadius: BorderRadius.circular(4)), child: Icon(icon, color: UGOAdminTheme.primaryBlue)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildTransactionReceipt({required bool isDialog}) {
    // Si on appelle cette méthode depuis le buildMobile, _selectedTransaction peut être null si on ne passe pas par l'état global
    // Pour simplifier ici, on assume qu'on utilise _selectedTransaction
    final transactionX = _selectedTransaction!;
    final isPending = transactionX.statut == 'en_attente';

    Widget content = Column(
      mainAxisSize: MainAxisSize.min, // Important pour centrer
      children: [
        Icon(Icons.receipt_long, size: 50, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text(transactionX.montant > 0 ? "+${transactionX.montant} FCFA" : "${transactionX.montant} FCFA", 
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: transactionX.montant > 0 ? Colors.green : Colors.black)),
        Text(transactionX.statut.toUpperCase(), style: TextStyle(color: isPending ? Colors.orange : Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 30),
        const Divider(),
        _rowDetail("Référence", transactionX.id),
        _rowDetail("Opérateur", transactionX.operateur),
        _rowDetail("Date", "${transactionX.date.day}/${transactionX.date.month} à ${transactionX.date.hour}:${transactionX.date.minute}"),
        _rowDetail("Motif", transactionX.description),
        const Divider(),
        const SizedBox(height: 20),
        
        if (isPending && transactionX.type == 'payout_out')
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                await MockDataService.approvePayout(transactionX.id);
                setState(() {}); // Update local
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paiement validé !")));
              },
              child: const Text("VALIDER LE VIREMENT", style: TextStyle(color: Colors.white)),
            ),
          ),
          
        if (!isDialog && !isPending) // Bouton fermer si on est sur Desktop zone 3
           TextButton.icon(
            onPressed: () => setState(() => _selectedTransaction = null), 
            icon: const Icon(Icons.close), 
            label: const Text("Fermer le reçu")
          )
      ],
    );

    // Si c'est mobile, on veut scroller si c'est petit. Si c'est desktop, c'est centré.
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: isDialog ? double.infinity : 350,
          padding: const EdgeInsets.all(24),
          decoration: isDialog ? null : BoxDecoration( // Carte blanche sur Desktop
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .1), blurRadius: 20, offset: const Offset(0, 10))]
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _rowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- DIALOGUE D'AJOUT (Le "Wow Effect") ---

  void _showAddTransactionDialog(BuildContext context) {
    String selectedOperator = "Espèces";
    bool isExpense = false; 
    bool isProcessing = false;
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    
    final operators = [
      {'name': 'Espèces', 'color': Colors.green, 'icon': Icons.money},
      {'name': 'Wave', 'color': const Color(0xFF1DC4FF), 'icon': Icons.waves},
      {'name': 'Orange Money', 'color': const Color(0xFFFF7900), 'icon': Icons.circle},
      {'name': 'MTN MoMo', 'color': const Color(0xFFFFCC00), 'icon': Icons.mobile_friendly},
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final themeColor = isExpense ? Colors.red : Colors.green;
            
            // CONTENU PROCESSING
            if (isProcessing) {
               return AlertDialog(
                 content: SizedBox(
                   height: 200,
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const CircularProgressIndicator(),
                       const SizedBox(height: 20),
                       Text("Connexion à $selectedOperator...", style: const TextStyle(fontWeight: FontWeight.bold)),
                       const Text("Traitement USSD en cours...", style: TextStyle(fontSize: 12, color: Colors.grey)),
                     ],
                   ),
                 ),
               );
            }

            // CONTENU FORMULAIRE
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Row(children: [
                Icon(isExpense ? Icons.output : Icons.input, color: themeColor),
                const SizedBox(width: 10),
                Text(isExpense ? "Payer" : "Encaisser", style: TextStyle(color: themeColor))
              ]),
              content: SizedBox(
                width: 450, // Largeur fixe confortable
                child: SingleChildScrollView( // Important pour mobile paysage ou petits écrans
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Switch Entrée/Sortie
                      Row(children: [
                        Expanded(child: _buildTabButton("ENTRÉE", !isExpense, Colors.green, () => setModalState(() => isExpense = false))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildTabButton("SORTIE", isExpense, Colors.red, () => setModalState(() => isExpense = true))),
                      ]),
                      const SizedBox(height: 20),
                      
                      // Opérateurs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: operators.map((op) {
                            final isSelected = selectedOperator == op['name'];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: GestureDetector(
                                onTap: () => setModalState(() => selectedOperator = op['name'] as String),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 45, height: 45,
                                      decoration: BoxDecoration(
                                        color: (op['name'] == 'Espèces') ? Colors.green.shade100 : (op['color'] as Color).withValues(alpha: .2),
                                        shape: BoxShape.circle,
                                        border: isSelected ? Border.all(color: op['color'] as Color, width: 3) : null,
                                      ),
                                      child: Icon(op['icon'] as IconData, color: op['color'] as Color, size: 20),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(op['name'] as String, style: const TextStyle(fontSize: 10))
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Champs
                      TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Montant", border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      if (selectedOperator != 'Espèces') ...[
                         TextField(keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Numéro $selectedOperator", border: const OutlineInputBorder())),
                         const SizedBox(height: 10),
                      ],
                      TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Motif", border: OutlineInputBorder())),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                  onPressed: () async {
                    if (amountCtrl.text.isEmpty) return;
                    setModalState(() => isProcessing = true);
                    await Future.delayed(const Duration(seconds: 2)); // Simu API
                    
                    // Ajout Mock
                    double amount = double.parse(amountCtrl.text);
                    if (isExpense) amount = -amount;
                    final transactionX = MockTransaction("NEW-${DateTime.now().millisecondsSinceEpoch}", 
                        isExpense ? 'manual_out' : 'manual_in', 
                        descCtrl.text.isEmpty ? "Transaction $selectedOperator" : descCtrl.text, 
                        amount, selectedOperator, DateTime.now(), 'succès');
                    
                    await MockDataService.addTransaction(transactionX);
                    
                    if (mounted) {
                      Navigator.pop(context);
                      _refreshData(); // Rafraichir la vue principale
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Opération $selectedOperator réussie !"), backgroundColor: Colors.green));
                    }
                  },
                  child: Text(isExpense ? "PAYER" : "ENCAISSER", style: const TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTabButton(String label, bool isActive, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: isActive ? color.withValues(alpha: .1) : Colors.grey[100], borderRadius: BorderRadius.circular(5), border: Border.all(color: isActive ? color : Colors.transparent)),
        child: Center(child: Text(label, style: TextStyle(color: isActive ? color : Colors.grey, fontWeight: FontWeight.bold))),
      ),
    );
  }
}