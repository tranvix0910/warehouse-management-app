import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/activity_log_service.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  final ActivityLogService _activityLogService = ActivityLogService();
  List<ActivityLog> _logs = [];
  bool _isLoading = true;
  ActivityType? _filterType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    
    try {
      _logs = await _activityLogService.getLogs(
        filterType: _filterType,
        startDate: _startDate,
        endDate: _endDate,
        limit: 100,
      );
    } catch (e) {
      debugPrint('Error loading logs: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Activity Log', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _filterType != null ? const Color(0xFF3B82F6) : Colors.white,
            ),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1E293B),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearConfirmation();
              } else if (value == 'export') {
                _exportLogs();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Export Logs', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Clear All Logs', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_filterType != null || _startDate != null)
            _buildActiveFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? _buildEmptyState()
                    : _buildLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1E293B),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, color: Color(0xFF3B82F6), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (_filterType != null)
                  Chip(
                    label: Text(
                      ActivityLog(
                        id: '',
                        type: _filterType!,
                        title: '',
                        description: '',
                        timestamp: DateTime.now(),
                      ).typeLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() => _filterType = null);
                      _loadLogs();
                    },
                    backgroundColor: const Color(0xFF3B82F6).withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                if (_startDate != null)
                  Chip(
                    label: Text(
                      '${DateFormat('MM/dd').format(_startDate!)} - ${_endDate != null ? DateFormat('MM/dd').format(_endDate!) : 'Now'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _loadLogs();
                    },
                    backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _filterType = null;
                _startDate = null;
                _endDate = null;
              });
              _loadLogs();
            },
            child: const Text('Clear All'),
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
            Icons.history,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No activity logs',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your activity will appear here',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    final groupedLogs = _groupLogsByDate();
    
    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedLogs.length,
        itemBuilder: (context, index) {
          final date = groupedLogs.keys.elementAt(index);
          final logs = groupedLogs[date]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _formatDateHeader(date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...logs.map((log) => _buildLogItem(log)),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<ActivityLog>> _groupLogsByDate() {
    final grouped = <String, List<ActivityLog>>{};
    
    for (final log in _logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.timestamp);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(log);
    }
    
    return grouped;
  }

  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(date.year, date.month, date.day);
    
    if (logDate == today) {
      return 'Today';
    } else if (logDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }

  Widget _buildLogItem(ActivityLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: log.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              log.icon,
              color: log.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      log.typeLabel,
                      style: TextStyle(
                        color: log.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('HH:mm').format(log.timestamp),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                if (log.userName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'by ${log.userName}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Filter Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Activity Type',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ActivityType.values.map((type) {
                final log = ActivityLog(
                  id: '',
                  type: type,
                  title: '',
                  description: '',
                  timestamp: DateTime.now(),
                );
                final isSelected = _filterType == type;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _filterType = isSelected ? null : type;
                    });
                    Navigator.pop(context);
                    _loadLogs();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? log.color.withOpacity(0.3) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? log.color : const Color(0xFF334155),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(log.icon, color: log.color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          log.typeLabel,
                          style: TextStyle(
                            color: isSelected ? log.color : Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Date Range',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateRangeButton(
                    'Today',
                    DateTime.now(),
                    DateTime.now(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDateRangeButton(
                    'Last 7 Days',
                    DateTime.now().subtract(const Duration(days: 7)),
                    DateTime.now(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateRangeButton(
                    'Last 30 Days',
                    DateTime.now().subtract(const Duration(days: 30)),
                    DateTime.now(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDateRangeButton(
                    'Custom',
                    null,
                    null,
                    isCustom: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeButton(
    String label,
    DateTime? start,
    DateTime? end, {
    bool isCustom = false,
  }) {
    final isSelected = !isCustom && 
        _startDate != null && 
        start != null &&
        _startDate!.day == start.day;

    return GestureDetector(
      onTap: () async {
        if (isCustom) {
          final range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF3B82F6),
                    surface: Color(0xFF1E293B),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (range != null) {
            setState(() {
              _startDate = range.start;
              _endDate = range.end;
            });
            Navigator.pop(context);
            _loadLogs();
          }
        } else {
          setState(() {
            _startDate = start;
            _endDate = end;
          });
          Navigator.pop(context);
          _loadLogs();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.2) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF334155),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Clear All Logs', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear all activity logs? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _activityLogService.clearLogs();
              Navigator.pop(context);
              _loadLogs();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }
}
