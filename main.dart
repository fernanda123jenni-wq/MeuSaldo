import 'package:flutter/material.dart';

void main() {
  runApp(const MeuSaldoApp());
}

class MeuSaldoApp extends StatelessWidget {
  const MeuSaldoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeuSaldo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
      ),
      home: const HomePage(),
    );
  }
}

class Transaction {
  final String title;
  final String category;
  final double amount;
  final bool income;

  Transaction({
    required this.title,
    required this.category,
    required this.amount,
    required this.income,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Transaction> transactions = [
    Transaction(
      title: 'Salário',
      category: 'Receita',
      amount: 3500,
      income: true,
    ),
    Transaction(
      title: 'Supermercado',
      category: 'Alimentação',
      amount: 286.40,
      income: false,
    ),
    Transaction(
      title: 'Internet',
      category: 'Contas',
      amount: 119.90,
      income: false,
    ),
  ];

  double get totalIncome => transactions
      .where((t) => t.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => !t.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  String money(double value) {
    String text = value.toStringAsFixed(2);
    List<String> parts = text.split('.');

    String inteiro = parts[0];
    String decimal = parts[1];

    String resultado = '';
    int contador = 0;

    for (int i = inteiro.length - 1; i >= 0; i--) {
      resultado = inteiro[i] + resultado;
      contador++;

      if (contador == 3 && i != 0) {
        resultado = '.$resultado';
        contador = 0;
      }
    }

    return 'R\$ $resultado,$decimal';
  }

  void addTransaction() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    bool income = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 25,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Novo lançamento',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Ex: Mercado',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SwitchListTile(
                    value: income,
                    title: Text(
                      income ? 'Receita' : 'Despesa',
                    ),
                    subtitle: const Text(
                      'Ative para registrar uma entrada',
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        income = value;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        String valor = amountController.text
                            .replaceAll('.', '')
                            .replaceAll(',', '.');

                        final amount =
                            double.tryParse(valor);

                        if (titleController.text
                                .trim()
                                .isEmpty ||
                            amount == null ||
                            amount <= 0) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Digite uma descrição e um valor válido.',
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          transactions.insert(
                            0,
                            Transaction(
                              title:
                                  titleController.text.trim(),
                              category: income
                                  ? 'Receita'
                                  : 'Despesa',
                              amount: amount,
                              income: income,
                            ),
                          );
                        });

                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15),
                        child: Text('Salvar lançamento'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboard(),
      transactionsPage(),
      receiptPage(),
      profilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MeuSaldo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: pages[currentIndex],

      floatingActionButton:
          currentIndex == 0 || currentIndex == 1
              ? FloatingActionButton.extended(
                  onPressed: addTransaction,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                )
              : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Lançamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Nota fiscal',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6246EA),
                Color(0xFF7B61FF),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo disponível',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  money(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: summaryItem(
                      'Entradas',
                      totalIncome,
                      true,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: summaryItem(
                      'Saídas',
                      totalExpense,
                      false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'Movimentações recentes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...transactions.take(5).map(transactionTile),
      ],
    );
  }

  Widget summaryItem(
    String label,
    double value,
    bool income,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            income
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: Colors.white,
          ),

          const SizedBox(height: 5),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 3),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              money(value),
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionTile(Transaction t) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            t.income
                ? Icons.south_west
                : Icons.north_east,
          ),
        ),

        title: Text(
          t.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(t.category),

        trailing: SizedBox(
          width: 115,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '${t.income ? '+' : '-'} ${money(t.amount)}',
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    t.income ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget transactionsPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Todos os lançamentos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...transactions.map(transactionTile),
      ],
    );
  }

  Widget receiptPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.document_scanner,
              size: 85,
            ),

            const SizedBox(height: 20),

            const Text(
              'Ler nota fiscal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Fotografe sua nota fiscal para adicionar suas compras automaticamente aos seus gastos.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Vamos conectar a câmera na próxima etapa.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Abrir câmera'),
            ),
          ],
        ),
      ),
    );
  }

  Widget profilePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: const [
        CircleAvatar(
          radius: 42,
          child: Icon(
            Icons.person,
            size: 42,
          ),
        ),

        SizedBox(height: 16),

        Center(
          child: Text(
            'Meu Perfil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(height: 24),

        Card(
          elevation: 0,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Idioma'),
                subtitle: Text('Português (Brasil)'),
              ),

              Divider(height: 1),

              ListTile(
                leading:
                    Icon(Icons.notifications_outlined),
                title: Text('Lembretes'),
                subtitle:
                    Text('Controle de contas mensais'),
              ),

              Divider(height: 1),

              ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Privacidade'),
                subtitle: Text(
                  'Seus dados financeiros ficam protegidos',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}