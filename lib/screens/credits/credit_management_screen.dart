import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/screens/credits/credit_history_screen.dart';
import 'package:intl/intl.dart';

class CreditManagementScreen extends StatefulWidget {
  const CreditManagementScreen({Key? key}) : super(key: key);

  @override
  _CreditManagementScreenState createState() => _CreditManagementScreenState();
}

class _CreditManagementScreenState extends State<CreditManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Management'),
      ),
      body: user == null
          ? _buildLoginPrompt()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCreditBalanceCard(user),
                    const SizedBox(height: 24),
                    
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                    
                    _buildCreditMembershipInfo(user),
                    const SizedBox(height: 24),
                    
                    _buildRecentTransactions(user),
                    const SizedBox(height: 24),
                    
                    _buildCreditInfoSection(),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Please Log In',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You need to be logged in to view and manage your credits',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreditBalanceCard(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Credit Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreditHistoryScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'View History',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Gym Credits
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                
                // Divider
                Container(
                  height: 100,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                
                // Interval Credits
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.timer,
                        color: Colors.orange,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Credit Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'View History',
                Icons.history,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreditHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Credit Policy',
                Icons.policy,
                Colors.purple,
                () {
                  _showCreditPolicyDialog();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Help Guide',
                Icons.help_outline,
                Colors.teal,
                () {
                  _showHelpGuideDialog();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCreditMembershipInfo(UserModel user) {
    if (user.membership == null) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.card_membership,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'No Active Membership',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Subscribe to a membership plan to receive monthly credits and enjoy exclusive benefits.',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to membership plans page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Membership Plans'),
              ),
            ],
          ),
        ),
      );
    }
    
    final membership = user.membership!;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.card_membership,
                  color: Colors.purple,
                ),
                const SizedBox(width: 12),
                Text(
                  '${membership.plan} Membership',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: membership.isExpiringSoon ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    membership.isExpiringSoon ? 'Expiring Soon' : 'Active',
                    style: TextStyle(
                      color: membership.isExpiringSoon ? Colors.red[800] : Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMembershipDetailRow(
              'Expires On',
              DateFormat('MMMM d, yyyy').format(membership.expiryDate),
            ),
            _buildMembershipDetailRow(
              'Days Remaining',
              '${membership.daysRemaining} days',
            ),
            _buildMembershipDetailRow(
              'Auto Renew',
              membership.autoRenew ? 'Yes' : 'No',
            ),
            const Divider(height: 24),
            _buildMembershipDetailRow(
              'Monthly Gym Credits',
              '${membership.monthlyGymCredits}',
              valueColor: AppTheme.primaryColor,
            ),
            _buildMembershipDetailRow(
              'Monthly Interval Credits',
              '${membership.monthlyIntervalCredits}',
              valueColor: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Your next credit allocation will be on ${DateFormat('MMMM d, yyyy').format(DateTime.now().add(const Duration(days: 30)))}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMembershipDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
  
  Widget _buildRecentTransactions(UserModel user) {
    // For demo purposes, create some sample transactions
    final transactions = [
      {
        'id': '1',
        'type': 'booking',
        'description': 'Booked HIIT session',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'gymCredits': -2,
        'intervalCredits': 0,
      },
      {
        'id': '2',
        'type': 'membership',
        'description': 'Monthly membership credits',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'gymCredits': 10,
        'intervalCredits': 5,
      },
      {
        'id': '3',
        'type': 'refund',
        'description': 'Refund for canceled session',
        'date': DateTime.now().subtract(const Duration(days: 12)),
        'gymCredits': 1,
        'intervalCredits': 0,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreditHistoryScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return ListTile(
                leading: _getTransactionIcon(tx['type'] as String),
                title: Text(
                  tx['description'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM d, yyyy').format(tx['date'] as DateTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if ((tx['gymCredits'] as int) != 0)
                      Text(
                        '${(tx['gymCredits'] as int) > 0 ? '+' : ''}${tx['gymCredits']} Gym',
                        style: TextStyle(
                          color: (tx['gymCredits'] as int) > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    if ((tx['intervalCredits'] as int) != 0)
                      Text(
                        '${(tx['intervalCredits'] as int) > 0 ? '+' : ''}${tx['intervalCredits']} Int',
                        style: TextStyle(
                          color: (tx['intervalCredits'] as int) > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _getTransactionIcon(String type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'booking':
        icon = Icons.event_available;
        color = Colors.red;
        break;
      case 'membership':
        icon = Icons.card_membership;
        color = Colors.purple;
        break;
      case 'refund':
        icon = Icons.reply;
        color = Colors.green;
        break;
      default:
        icon = Icons.swap_horiz;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }
  
  Widget _buildCreditInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Credits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCreditInfoItem(
                  'How Credits Work',
                  'Credits are the currency used within FitSAGA to book sessions and access premium features. There are two types of credits: Gym Credits and Interval Credits.',
                  Icons.info_outline,
                  Colors.blue,
                ),
                const Divider(height: 24),
                _buildCreditInfoItem(
                  'Gym Credits',
                  'Used for booking regular training sessions, including yoga, strength training, and cardio workouts. Most sessions cost 1-3 gym credits.',
                  Icons.fitness_center,
                  AppTheme.primaryColor,
                ),
                const Divider(height: 24),
                _buildCreditInfoItem(
                  'Interval Credits',
                  'Specifically for high-intensity interval training (HIIT) and specialized interval-based workouts. These sessions typically cost 1-2 interval credits.',
                  Icons.timer,
                  Colors.orange,
                ),
                const Divider(height: 24),
                _buildCreditInfoItem(
                  'Credit Expiration',
                  'Credits are valid for 12 months from the date of purchase or allocation. Make sure to use them before they expire!',
                  Icons.access_time,
                  Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCreditInfoItem(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showCreditPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credit Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPolicySection(
                'Credit Types',
                'FitSAGA offers two types of credits:\n'
                '• Gym Credits: For regular sessions\n'
                '• Interval Credits: For specialized interval training',
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                'Credit Usage',
                'Credits are deducted when you book a session. The number of credits required varies by session type, duration, and instructor.',
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                'Expiration',
                'Credits expire 12 months after purchase or allocation date. Expired credits cannot be recovered.',
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                'Cancellation & Refunds',
                '• Full refund if cancelled 24+ hours before session\n'
                '• 50% refund if cancelled 12-24 hours before session\n'
                '• No refund if cancelled less than 12 hours before session',
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                'Membership Benefits',
                'Members receive monthly credit allocations based on their membership tier. These credits are automatically added to your account on your billing date.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  void _showHelpGuideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credit System Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                'What are credits?',
                'Credits are the in-app currency that allows you to book sessions and access premium features within FitSAGA.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'How do I get credits?',
                '• Sign up bonus: New users receive 5 gym credits and 2 interval credits\n'
                '• Membership: Automatically receive monthly credits\n'
                '• Admin allocation: For special events or promotions',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'How do I use credits?',
                'Credits are automatically deducted when you book a session. The booking screen will show how many credits are required for each session.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'How do I check my balance?',
                'Your credit balance is displayed on the home screen, profile page, and at the top of this Credit Management screen.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'What if I don\'t have enough credits?',
                'If you don\'t have enough credits for a session, you won\'t be able to complete the booking. You\'ll need to either wait for your next membership allocation or contact the gym administrator.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHelpSection(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}