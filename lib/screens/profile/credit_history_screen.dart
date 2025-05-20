import 'package:flutter/material.dart';
import 'package:fitsaga/models/auth_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

class CreditHistoryScreen extends StatelessWidget {
  final User user;
  
  const CreditHistoryScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit History'),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    // Demo credit transactions
    final List<CreditTransaction> transactions = [
      CreditTransaction(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'HIIT Session Booking',
        credits: -3,
        type: CreditTransactionType.session,
        creditType: CreditType.gym,
      ),
      CreditTransaction(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Purchase Credits',
        credits: 10,
        type: CreditTransactionType.purchase,
        creditType: CreditType.gym,
      ),
      CreditTransaction(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 7)),
        description: 'Yoga Session Booking',
        credits: -2,
        type: CreditTransactionType.session,
        creditType: CreditType.gym,
      ),
      CreditTransaction(
        id: '4',
        date: DateTime.now().subtract(const Duration(days: 7)),
        description: 'Personal Training Booking',
        credits: -1,
        type: CreditTransactionType.session,
        creditType: CreditType.interval,
      ),
      CreditTransaction(
        id: '5',
        date: DateTime.now().subtract(const Duration(days: 10)),
        description: 'Promotional Credits',
        credits: 5,
        type: CreditTransactionType.promotion,
        creditType: CreditType.gym,
      ),
      CreditTransaction(
        id: '6',
        date: DateTime.now().subtract(const Duration(days: 10)),
        description: 'Promotional Credits',
        credits: 2,
        type: CreditTransactionType.promotion,
        creditType: CreditType.interval,
      ),
    ];
    
    return Column(
      children: [
        // Summary cards
        _buildCreditSummary(),
        
        // Transaction list
        Expanded(
          child: transactions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionItem(transactions[index]);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildCreditSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gym credits
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${user.credits.gymCredits} gym',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Interval credits
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${user.credits.intervalCredits} interval',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No credit history yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your credit transactions will appear here',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionItem(CreditTransaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildTransactionIcon(transaction),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy').format(transaction.date),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          '${transaction.credits > 0 ? '+' : ''}${transaction.credits} ${transaction.creditType == CreditType.gym ? 'gym' : 'interval'}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction.credits > 0 ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTransactionIcon(CreditTransaction transaction) {
    IconData icon;
    Color color;
    
    switch (transaction.type) {
      case CreditTransactionType.purchase:
        icon = Icons.shopping_cart;
        color = Colors.green;
        break;
      case CreditTransactionType.session:
        icon = Icons.fitness_center;
        color = Colors.red;
        break;
      case CreditTransactionType.refund:
        icon = Icons.reply;
        color = Colors.green;
        break;
      case CreditTransactionType.promotion:
        icon = Icons.card_giftcard;
        color = Colors.purple;
        break;
      case CreditTransactionType.adjustment:
        icon = Icons.settings;
        color = Colors.blue;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}

// Model classes for credit transactions
enum CreditTransactionType {
  purchase,
  session,
  refund,
  promotion,
  adjustment,
}

enum CreditType {
  gym,
  interval,
}

class CreditTransaction {
  final String id;
  final DateTime date;
  final String description;
  final int credits;
  final CreditTransactionType type;
  final CreditType creditType;
  
  CreditTransaction({
    required this.id,
    required this.date,
    required this.description,
    required this.credits,
    required this.type,
    required this.creditType,
  });
}