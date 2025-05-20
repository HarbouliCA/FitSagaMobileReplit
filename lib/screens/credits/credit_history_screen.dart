import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/services/credit_service.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

class CreditHistoryScreen extends StatefulWidget {
  const CreditHistoryScreen({Key? key}) : super(key: key);

  @override
  _CreditHistoryScreenState createState() => _CreditHistoryScreenState();
}

class _CreditHistoryScreenState extends State<CreditHistoryScreen> with SingleTickerProviderStateMixin {
  final CreditService _creditService = CreditService();
  bool _isLoading = true;
  String? _errorMessage;
  List<CreditTransaction> _transactions = [];
  late TabController _tabController;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _currentFilter = 'all';
              break;
            case 1:
              _currentFilter = 'purchase';
              break;
            case 2:
              _currentFilter = 'booking';
              break;
            case 3:
              _currentFilter = 'refund';
              break;
          }
        });
      }
    });
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId == null) {
        setState(() {
          _errorMessage = 'You need to be logged in to view your credit history';
          _isLoading = false;
        });
        return;
      }

      // Create sample transactions for the demo
      _transactions = [
        CreditTransaction(
          id: '1',
          userId: userId,
          gymCredits: 10,
          intervalCredits: 0,
          type: 'purchase',
          description: 'Purchased Basic Package',
          timestamp: DateTime.now().subtract(const Duration(days: 30)),
          metadata: {
            'packageId': 'basic',
            'packageName': 'Basic Package',
            'price': 29.99,
          },
        ),
        CreditTransaction(
          id: '2',
          userId: userId,
          gymCredits: -2,
          intervalCredits: 0,
          type: 'booking',
          description: 'Booked HIIT session',
          relatedEntityId: 'session123',
          timestamp: DateTime.now().subtract(const Duration(days: 25)),
          metadata: {
            'sessionId': 'session123',
            'sessionName': 'HIIT Workout',
            'sessionDate': DateTime.now().subtract(const Duration(days: 20)),
          },
        ),
        CreditTransaction(
          id: '3',
          userId: userId,
          gymCredits: 0,
          intervalCredits: 3,
          type: 'admin',
          description: 'Compensation for canceled class',
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
        ),
        CreditTransaction(
          id: '4',
          userId: userId,
          gymCredits: -3,
          intervalCredits: 0,
          type: 'booking',
          description: 'Booked Yoga session',
          relatedEntityId: 'session456',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          metadata: {
            'sessionId': 'session456',
            'sessionName': 'Yoga Flow',
            'sessionDate': DateTime.now().subtract(const Duration(days: 8)),
          },
        ),
        CreditTransaction(
          id: '5',
          userId: userId,
          gymCredits: 1,
          intervalCredits: 0,
          type: 'refund',
          description: 'Partial refund for canceled booking',
          relatedEntityId: 'booking789',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          metadata: {
            'bookingId': 'booking789',
            'sessionName': 'Strength Training',
            'originalCredits': 2,
          },
        ),
        CreditTransaction(
          id: '6',
          userId: userId,
          gymCredits: 5,
          intervalCredits: 2,
          type: 'membership',
          description: 'Monthly membership credits',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          metadata: {
            'membershipPlan': 'Standard',
          },
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transaction history: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<CreditTransaction> _getFilteredTransactions() {
    if (_currentFilter == 'all') {
      return _transactions;
    }
    return _transactions.where((tx) => tx.type == _currentFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit History'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Purchases'),
            Tab(text: 'Bookings'),
            Tab(text: 'Refunds'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildTransactionsList(user),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTransactions,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionsList(UserModel? user) {
    return Column(
      children: [
        // Current balance
        if (user != null) _buildCreditBalanceCard(user),
        
        // Credit statistics
        if (user != null) _buildCreditStatisticsCard(),
        
        // Transactions list
        Expanded(
          child: _buildTransactionItems(),
        ),
      ],
    );
  }
  
  Widget _buildCreditBalanceCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.credits.gymCredits.toString(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Gym Credits',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.credits.intervalCredits.toString(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Interval Credits',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCreditStatisticsCard() {
    // Calculate statistics from transactions
    int gymCreditsUsed = 0;
    int intervalCreditsUsed = 0;
    int gymCreditsGained = 0;
    int intervalCreditsGained = 0;
    
    for (final tx in _transactions) {
      if (tx.gymCredits < 0) {
        gymCreditsUsed += -tx.gymCredits;
      } else {
        gymCreditsGained += tx.gymCredits;
      }
      
      if (tx.intervalCredits < 0) {
        intervalCreditsUsed += -tx.intervalCredits;
      } else {
        intervalCreditsGained += tx.intervalCredits;
      }
    }
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Credit History Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatisticItem(
                      'Gym Credits Used',
                      gymCreditsUsed.toString(),
                      Icons.remove_circle_outline,
                      Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildStatisticItem(
                      'Gym Credits Gained',
                      gymCreditsGained.toString(),
                      Icons.add_circle_outline,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatisticItem(
                      'Interval Used',
                      intervalCreditsUsed.toString(),
                      Icons.remove_circle_outline,
                      Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildStatisticItem(
                      'Interval Gained',
                      intervalCreditsGained.toString(),
                      Icons.add_circle_outline,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatisticItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildTransactionItems() {
    final filteredTransactions = _getFilteredTransactions();
    
    if (filteredTransactions.isEmpty) {
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
              'No transactions found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilter == 'all'
                  ? 'Your transaction history will appear here'
                  : 'No ${_currentFilter}s found in your history',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return _buildTransactionCard(transaction, index);
      },
    );
  }
  
  Widget _buildTransactionCard(CreditTransaction transaction, int index) {
    // Determine icon and color based on transaction type
    IconData icon;
    Color color;
    
    switch (transaction.type) {
      case 'purchase':
        icon = Icons.shopping_cart;
        color = Colors.blue;
        break;
      case 'booking':
        icon = Icons.event_available;
        color = Colors.red;
        break;
      case 'refund':
        icon = Icons.reply;
        color = Colors.green;
        break;
      case 'membership':
        icon = Icons.card_membership;
        color = Colors.purple;
        break;
      case 'admin':
        icon = Icons.admin_panel_settings;
        color = Colors.orange;
        break;
      case 'gift':
        icon = Icons.card_giftcard;
        color = Colors.pink;
        break;
      default:
        icon = Icons.swap_horiz;
        color = Colors.grey;
    }
    
    // Check if it's a positive or negative transaction
    final bool isPositive = transaction.gymCredits >= 0 && transaction.intervalCredits >= 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy • h:mm a').format(transaction.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            if (transaction.type == 'booking' && transaction.metadata != null)
              Text(
                'Session: ${transaction.metadata!['sessionName']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (transaction.gymCredits != 0)
              Text(
                '${isPositive ? '+' : ''}${transaction.gymCredits} Gym',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (transaction.intervalCredits != 0)
              Text(
                '${isPositive ? '+' : ''}${transaction.intervalCredits} Interval',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }
  
  void _showTransactionDetails(CreditTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getTransactionColor(transaction.type).withOpacity(0.2),
                    child: Icon(
                      _getTransactionIcon(transaction.type),
                      color: _getTransactionColor(transaction.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTransactionTypeLabel(transaction.type),
                          style: TextStyle(
                            color: _getTransactionColor(transaction.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Transaction details
              _buildDetailRow('Transaction ID', transaction.id),
              _buildDetailRow('Date', DateFormat('MMMM d, yyyy').format(transaction.timestamp)),
              _buildDetailRow('Time', DateFormat('h:mm a').format(transaction.timestamp)),
              
              if (transaction.gymCredits != 0)
                _buildDetailRow(
                  'Gym Credits',
                  '${transaction.gymCredits > 0 ? '+' : ''}${transaction.gymCredits}',
                  valueColor: transaction.gymCredits > 0 ? Colors.green : Colors.red,
                ),
              
              if (transaction.intervalCredits != 0)
                _buildDetailRow(
                  'Interval Credits',
                  '${transaction.intervalCredits > 0 ? '+' : ''}${transaction.intervalCredits}',
                  valueColor: transaction.intervalCredits > 0 ? Colors.green : Colors.red,
                ),
              
              const Divider(height: 32),
              
              // Additional details based on transaction type
              if (transaction.type == 'purchase' && transaction.metadata != null) ...[
                _buildDetailRow('Package', transaction.metadata!['packageName']),
                _buildDetailRow('Price', '\$${transaction.metadata!['price']}'),
              ],
              
              if (transaction.type == 'booking' && transaction.metadata != null) ...[
                _buildDetailRow('Session', transaction.metadata!['sessionName']),
                if (transaction.metadata!['sessionDate'] != null)
                  _buildDetailRow(
                    'Session Date',
                    DateFormat('MMMM d, yyyy').format(transaction.metadata!['sessionDate']),
                  ),
              ],
              
              if (transaction.type == 'refund' && transaction.metadata != null)
                _buildDetailRow('Original Amount', '${transaction.metadata!['originalCredits']} credits'),
              
              if (transaction.type == 'membership' && transaction.metadata != null)
                _buildDetailRow('Membership Plan', transaction.metadata!['membershipPlan']),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'purchase':
        return Icons.shopping_cart;
      case 'booking':
        return Icons.event_available;
      case 'refund':
        return Icons.reply;
      case 'membership':
        return Icons.card_membership;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.swap_horiz;
    }
  }
  
  Color _getTransactionColor(String type) {
    switch (type) {
      case 'purchase':
        return Colors.blue;
      case 'booking':
        return Colors.red;
      case 'refund':
        return Colors.green;
      case 'membership':
        return Colors.purple;
      case 'admin':
        return Colors.orange;
      case 'gift':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
  
  String _getTransactionTypeLabel(String type) {
    switch (type) {
      case 'purchase':
        return 'Credit Purchase';
      case 'booking':
        return 'Session Booking';
      case 'refund':
        return 'Refund';
      case 'membership':
        return 'Membership Benefit';
      case 'admin':
        return 'Admin Transaction';
      case 'gift':
        return 'Gift';
      default:
        return 'Transaction';
    }
  }
}