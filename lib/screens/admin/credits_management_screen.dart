import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class CreditsManagementScreen extends StatefulWidget {
  const CreditsManagementScreen({Key? key}) : super(key: key);

  @override
  State<CreditsManagementScreen> createState() => _CreditsManagementScreenState();
}

class _CreditsManagementScreenState extends State<CreditsManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  
  // Date range for transaction history
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCreditsData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCreditsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // In a real implementation, this would fetch credits data from Firebase
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _loadCreditsData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCreditsData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Packages'),
            Tab(text: 'Transactions'),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildPackagesTab(),
                    _buildTransactionsTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action depends on current tab
          switch (_tabController.index) {
            case 0:
              // Overview tab
              _showAddCreditsDialog();
              break;
            case 1:
              // Packages tab
              _showCreatePackageDialog();
              break;
            case 2:
              // Transactions tab
              _showFilterTransactionsDialog();
              break;
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: Icon(
          _getFloatingActionButtonIcon(),
        ),
      ),
    );
  }
  
  IconData _getFloatingActionButtonIcon() {
    switch (_tabController.index) {
      case 0:
        return Icons.add;
      case 1:
        return Icons.add_box;
      case 2:
        return Icons.filter_list;
      default:
        return Icons.add;
    }
  }
  
  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Row(
            children: [
              _buildStatCard(
                title: 'Total Credits Sold',
                value: '2,450',
                icon: Icons.shopping_cart,
                color: AppTheme.primaryColor,
                change: '+12%',
                isPositive: true,
              ),
              _buildStatCard(
                title: 'Credits in Circulation',
                value: '1,250',
                icon: Icons.account_balance_wallet,
                color: AppTheme.accentColor,
                change: '+5%',
                isPositive: true,
              ),
              _buildStatCard(
                title: 'Revenue This Month',
                value: '\$12,320',
                icon: Icons.attach_money,
                color: AppTheme.successColor,
                change: '+8%',
                isPositive: true,
              ),
              _buildStatCard(
                title: 'Avg. Credits per User',
                value: '12.5',
                icon: Icons.people,
                color: AppTheme.infoColor,
                change: '-2%',
                isPositive: false,
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Charts
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sales over time
                Expanded(
                  flex: 2,
                  child: _buildSalesChart(),
                ),
                
                const SizedBox(width: AppTheme.spacingMedium),
                
                // Package popularity
                Expanded(
                  child: _buildPopularPackagesChart(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Top clients
          Expanded(
            child: _buildTopClientsTable(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPackagesTab() {
    // Sample packages data
    final packages = [
      {
        'id': '1',
        'name': 'Starter Pack',
        'credits': 5,
        'price': 25.00,
        'description': 'Perfect for new members to try out our sessions.',
        'isActive': true,
        'salesCount': 48,
      },
      {
        'id': '2',
        'name': 'Basic Bundle',
        'credits': 10,
        'price': 45.00,
        'description': 'Our most popular package for regular gym goers.',
        'isActive': true,
        'salesCount': 124,
      },
      {
        'id': '3',
        'name': 'Premium Package',
        'credits': 20,
        'price': 85.00,
        'description': 'Best value for dedicated members with frequent sessions.',
        'isActive': true,
        'salesCount': 67,
      },
      {
        'id': '4',
        'name': 'Ultimate Pass',
        'credits': 50,
        'price': 199.00,
        'description': 'Maximum savings for our most dedicated clients.',
        'isActive': true,
        'salesCount': 31,
      },
      {
        'id': '5',
        'name': 'Holiday Special',
        'credits': 15,
        'price': 60.00,
        'description': 'Limited-time holiday promotion with extra value.',
        'isActive': false,
        'salesCount': 92,
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search
          Row(
            children: [
              const Text(
                'Credit Packages',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Search field
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search packages',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) {
                    // Search functionality would be implemented here
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Package cards
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return _buildPackageCard(package);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionsTab() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date range filter
          Row(
            children: [
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Date range picker
              Card(
                elevation: AppTheme.elevationSmall,
                child: InkWell(
                  onTap: _selectDateRange,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Export button
              ElevatedButton.icon(
                onPressed: () {
                  // Export transaction data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exporting transaction data'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Transactions table
          Expanded(
            child: _buildTransactionsTable(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
    required bool isPositive,
  }) {
    return Expanded(
      child: Card(
        elevation: AppTheme.elevationSmall,
        margin: const EdgeInsets.only(right: AppTheme.spacingMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    icon,
                    color: color.withOpacity(0.8),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeTitle,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$change from last month',
                    style: TextStyle(
                      color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                      fontSize: AppTheme.fontSizeSmall,
                      fontWeight: FontWeight.bold,
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
  
  Widget _buildSalesChart() {
    // This would be implemented with a chart library like fl_chart
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Credits Sales Over Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeMedium,
                  ),
                ),
                Spacer(),
                Text(
                  'Last 6 Months',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Expanded(
              child: Center(
                child: Text(
                  'Sales chart would be implemented here with a proper chart library',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPopularPackagesChart() {
    // This would be implemented with a chart library
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: AppTheme.accentColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Popular Packages',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Expanded(
              child: Center(
                child: Text(
                  'Package popularity chart would be implemented here',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopClientsTable() {
    // Sample top clients data
    final topClients = [
      {
        'id': '1',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'totalCredits': 120,
        'currentBalance': 15,
        'totalSpent': '\$750',
        'lastPurchase': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': '2',
        'name': 'Sarah Johnson',
        'email': 'sarah.johnson@example.com',
        'totalCredits': 95,
        'currentBalance': 8,
        'totalSpent': '\$590',
        'lastPurchase': DateTime.now().subtract(const Duration(days: 12)),
      },
      {
        'id': '3',
        'name': 'Michael Brown',
        'email': 'michael.brown@example.com',
        'totalCredits': 85,
        'currentBalance': 20,
        'totalSpent': '\$420',
        'lastPurchase': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': '4',
        'name': 'Lisa Williams',
        'email': 'lisa.williams@example.com',
        'totalCredits': 72,
        'currentBalance': 5,
        'totalSpent': '\$380',
        'lastPurchase': DateTime.now().subtract(const Duration(days: 8)),
      },
      {
        'id': '5',
        'name': 'Robert Taylor',
        'email': 'robert.taylor@example.com',
        'totalCredits': 65,
        'currentBalance': 10,
        'totalSpent': '\$320',
        'lastPurchase': DateTime.now().subtract(const Duration(days: 15)),
      },
    ];
    
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.people,
                  color: AppTheme.infoColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Top Clients by Credit Usage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Expanded(
              child: ListView.builder(
                itemCount: topClients.length,
                itemBuilder: (context, index) {
                  final client = topClients[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryLightColor,
                      child: Text(
                        (index + 1).toString(),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      client['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      client['email'] as String,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total: ${client['totalCredits']} credits',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Current: ${client['currentBalance']} credits',
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeSmall,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () {
                            _showAddCreditsToUserDialog(client);
                          },
                          tooltip: 'Add Credits',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.history,
                            color: AppTheme.accentColor,
                          ),
                          onPressed: () {
                            _showUserTransactionHistory(client);
                          },
                          tooltip: 'Transaction History',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPackageCard(Map<String, dynamic> package) {
    final isActive = package['isActive'] as bool;
    
    return Card(
      elevation: AppTheme.elevationSmall,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package name and stats
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryLightColor,
                      child: Text(
                        package['credits'].toString(),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppTheme.fontSizeMedium,
                            ),
                          ),
                          Text(
                            '${package['salesCount']} sold',
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: AppTheme.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${package['price']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontSizeLarge,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  package['description'] as String,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showEditPackageDialog(package);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _togglePackageStatus(package);
                      },
                      icon: Icon(
                        isActive ? Icons.cancel : Icons.check_circle,
                      ),
                      label: Text(
                        isActive ? 'Deactivate' : 'Activate',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Status indicator
          if (!isActive)
            Positioned(
              top: 12,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.borderRadiusSmall),
                    bottomLeft: Radius.circular(AppTheme.borderRadiusSmall),
                  ),
                ),
                child: const Text(
                  'Inactive',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeXSmall,
                  ),
                ),
              ),
            ),
          
          // Indicator of price per credit
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                '\$${(package['price'] as double / package['credits'] as int).toStringAsFixed(2)} per credit',
                style: const TextStyle(
                  color: AppTheme.infoColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.fontSizeXSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionsTable() {
    // Sample transactions data
    final transactions = [
      {
        'id': '1',
        'user': 'John Doe',
        'type': 'Purchase',
        'package': 'Premium Package',
        'credits': 20,
        'amount': '\$85.00',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'status': 'Completed',
      },
      {
        'id': '2',
        'user': 'Sarah Johnson',
        'type': 'Purchase',
        'package': 'Basic Bundle',
        'credits': 10,
        'amount': '\$45.00',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'status': 'Completed',
      },
      {
        'id': '3',
        'user': 'Michael Brown',
        'type': 'Usage',
        'package': 'Session Booking',
        'credits': -2,
        'amount': '-',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'status': 'Completed',
      },
      {
        'id': '4',
        'user': 'Lisa Williams',
        'type': 'Purchase',
        'package': 'Starter Pack',
        'credits': 5,
        'amount': '\$25.00',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'status': 'Completed',
      },
      {
        'id': '5',
        'user': 'John Doe',
        'type': 'Usage',
        'package': 'Session Booking',
        'credits': -1,
        'amount': '-',
        'date': DateTime.now().subtract(const Duration(days: 4)),
        'status': 'Completed',
      },
      {
        'id': '6',
        'user': 'Robert Taylor',
        'type': 'Manual Addition',
        'package': 'Promotional Credits',
        'credits': 5,
        'amount': '\$0.00',
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'status': 'Completed',
      },
      {
        'id': '7',
        'user': 'Sarah Johnson',
        'type': 'Refund',
        'package': 'Basic Bundle',
        'credits': -10,
        'amount': '-\$45.00',
        'date': DateTime.now().subtract(const Duration(days: 6)),
        'status': 'Completed',
      },
    ];
    
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Package/Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Credits',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Transaction rows
          Expanded(
            child: ListView.separated(
              itemCount: transactions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionRow(transaction);
              },
            ),
          ),
          
          // Pagination
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Showing 1-${transactions.length} of ${transactions.length}',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  onPressed: null,
                  disabledColor: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: null,
                  disabledColor: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionRow(Map<String, dynamic> transaction) {
    final isPositive = (transaction['credits'] as int) > 0;
    final type = transaction['type'] as String;
    final status = transaction['status'] as String;
    
    Color typeColor;
    switch (type) {
      case 'Purchase':
        typeColor = AppTheme.successColor;
        break;
      case 'Usage':
        typeColor = AppTheme.accentColor;
        break;
      case 'Refund':
        typeColor = AppTheme.errorColor;
        break;
      case 'Manual Addition':
        typeColor = AppTheme.infoColor;
        break;
      default:
        typeColor = AppTheme.textPrimaryColor;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      child: Row(
        children: [
          // User
          Expanded(
            flex: 2,
            child: Text(
              transaction['user'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Type
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: typeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.fontSizeXSmall,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Package/Description
          Expanded(
            flex: 2,
            child: Text(
              transaction['package'] as String,
            ),
          ),
          
          // Credits
          Expanded(
            flex: 1,
            child: Text(
              '${isPositive ? '+' : ''}${transaction['credits']}',
              style: TextStyle(
                color: isPositive ? AppTheme.successColor : AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Amount
          Expanded(
            flex: 1,
            child: Text(
              transaction['amount'] as String,
              textAlign: TextAlign.center,
            ),
          ),
          
          // Date
          Expanded(
            flex: 1,
            child: Text(
              DateFormat('MM/dd/yyyy').format(transaction['date'] as DateTime),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: status == 'Completed'
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status == 'Completed'
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.fontSizeXSmall,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    _showTransactionDetailsDialog(transaction);
                  },
                  tooltip: 'View Details',
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                ),
                if (type == 'Purchase' && status == 'Completed')
                  IconButton(
                    icon: const Icon(
                      Icons.replay,
                      color: AppTheme.errorColor,
                    ),
                    onPressed: () {
                      _showRefundDialog(transaction);
                    },
                    tooltip: 'Refund',
                    visualDensity: VisualDensity.compact,
                    iconSize: 20,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Credits to User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User selection
            const TextField(
              decoration: InputDecoration(
                labelText: 'Search User',
                hintText: 'Type name or email',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            
            // Credits amount
            const TextField(
              decoration: InputDecoration(
                labelText: 'Credits Amount',
                hintText: 'Enter number of credits',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Reason
            const TextField(
              decoration: InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter reason for adding credits',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Credits added successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              _loadCreditsData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Add Credits'),
          ),
        ],
      ),
    );
  }
  
  void _showAddCreditsToUserDialog(Map<String, dynamic> user) {
    final creditsController = TextEditingController();
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Credits to ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Text(
              'Current Balance: ${user['currentBalance']} credits',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Credits amount
            TextField(
              controller: creditsController,
              decoration: const InputDecoration(
                labelText: 'Credits Amount',
                hintText: 'Enter number of credits',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Reason
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter reason for adding credits',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              final credits = int.tryParse(creditsController.text) ?? 0;
              if (credits <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number of credits'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added $credits credits to ${user['name']}'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              _loadCreditsData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Add Credits'),
          ),
        ],
      ),
    ).then((_) {
      creditsController.dispose();
      reasonController.dispose();
    });
  }
  
  void _showUserTransactionHistory(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing transaction history for ${user['name']}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  void _showCreatePackageDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final creditsController = TextEditingController();
    final priceController = TextEditingController();
    
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Credit Package'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Package Name',
                  hintText: 'Enter package name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter package description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Credits and Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: creditsController,
                      decoration: const InputDecoration(
                        labelText: 'Credits',
                        hintText: 'Enter number of credits',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: 'Enter price',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null || double.parse(value) < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Package created successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                _loadCreditsData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Create Package'),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      descriptionController.dispose();
      creditsController.dispose();
      priceController.dispose();
    });
  }
  
  void _showEditPackageDialog(Map<String, dynamic> package) {
    final nameController = TextEditingController(text: package['name'] as String);
    final descriptionController = TextEditingController(text: package['description'] as String);
    final creditsController = TextEditingController(text: package['credits'].toString());
    final priceController = TextEditingController(text: (package['price'] as double).toString());
    
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Credit Package'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Package Name',
                  hintText: 'Enter package name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter package description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Credits and Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: creditsController,
                      decoration: const InputDecoration(
                        labelText: 'Credits',
                        hintText: 'Enter number of credits',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: 'Enter price',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null || double.parse(value) < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Package updated successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                _loadCreditsData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Update Package'),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      descriptionController.dispose();
      creditsController.dispose();
      priceController.dispose();
    });
  }
  
  void _togglePackageStatus(Map<String, dynamic> package) {
    final isActive = package['isActive'] as bool;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isActive ? 'Deactivate Package' : 'Activate Package',
        ),
        content: Text(
          isActive
              ? 'Are you sure you want to deactivate ${package['name']}? Deactivated packages will not be available for purchase.'
              : 'Are you sure you want to activate ${package['name']}? Activated packages will be available for purchase.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isActive
                        ? 'Package deactivated successfully'
                        : 'Package activated successfully',
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              _loadCreditsData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive
                  ? AppTheme.errorColor
                  : AppTheme.successColor,
            ),
            child: Text(
              isActive ? 'Deactivate' : 'Activate',
            ),
          ),
        ],
      ),
    );
  }
  
  void _showTransactionDetailsDialog(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Transaction Details',
          style: TextStyle(
            color: AppTheme.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionDetailItem(
              label: 'Transaction ID',
              value: transaction['id'] as String,
            ),
            const SizedBox(height: 12),
            _buildTransactionDetailItem(
              label: 'User',
              value: transaction['user'] as String,
            ),
            const SizedBox(height: 12),
            _buildTransactionDetailItem(
              label: 'Type',
              value: transaction['type'] as String,
            ),
            const SizedBox(height: 12),
            _buildTransactionDetailItem(
              label: 'Description',
              value: transaction['package'] as String,
            ),
            const SizedBox(height: 12),
            _buildTransactionDetailItem(
              label: 'Credits',
              value: '${transaction['credits']}',
            ),
            const SizedBox(height: 12),
            _buildTransactionDetailItem(
              label: 'Amount',
              value: transaction['amount'] as String,
            ),
            const SizedBox(height: 12),
            _buildTransactionDetailItem(
              label: 'Date',
              value: DateFormat('MMMM d, yyyy h:mm a').format(transaction['date'] as DateTime),
            ),
            const SizedBox(height: 12),
            _buildTransactionDetailItem(
              label: 'Status',
              value: transaction['status'] as String,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionDetailItem({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  void _showRefundDialog(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refund Credits'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to refund the following transaction?',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'User: ${transaction['user']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Package: ${transaction['package']}',
            ),
            const SizedBox(height: 8),
            Text(
              'Credits: ${transaction['credits']}',
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ${transaction['amount']}',
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: This will remove the credits from the user\'s account and refund the payment.',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction refunded successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              _loadCreditsData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Refund'),
          ),
        ],
      ),
    );
  }
  
  void _showFilterTransactionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transaction type
            const DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Transaction Type',
              ),
              items: [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All Types'),
                ),
                DropdownMenuItem(
                  value: 'Purchase',
                  child: Text('Purchases'),
                ),
                DropdownMenuItem(
                  value: 'Usage',
                  child: Text('Usage'),
                ),
                DropdownMenuItem(
                  value: 'Refund',
                  child: Text('Refunds'),
                ),
                DropdownMenuItem(
                  value: 'Manual Addition',
                  child: Text('Manual Additions'),
                ),
              ],
              value: 'All',
              onChanged: null,
            ),
            const SizedBox(height: 16),
            
            // Date range
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From Date',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text('Select date'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'To Date',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text('Select date'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Amount range
            const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Min Amount',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Max Amount',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadCreditsData();
            },
            child: const Text('Reset Filters'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadCreditsData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}