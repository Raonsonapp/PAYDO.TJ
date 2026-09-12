import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/notification_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../business/presentation/business_profile_screen.dart';
import '../../chat/presentation/chat_detail_screen.dart';
import '../../jobs/presentation/vacancy_details_screen.dart';
import '../../orders/presentation/order_history_screen.dart';
import 'notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder:
      case NotificationType.orderStatusChanged:
        return Icons.receipt_long_outlined;
      case NotificationType.newMessage:
        return Icons.chat_bubble_outline_rounded;
      case NotificationType.courierAssigned:
        return Icons.delivery_dining_outlined;
      case NotificationType.deliveryStarted:
        return Icons.directions_run_rounded;
      case NotificationType.deliveryArrived:
        return Icons.check_circle_outline_rounded;
      case NotificationType.jobApplication:
      case NotificationType.newVacancy:
        return Icons.work_outline_rounded;
      case NotificationType.review:
        return Icons.star_outline_rounded;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  void _onTap(BuildContext context, WidgetRef ref, NotificationModel n) {
    ref.read(notificationRepositoryProvider).markAsRead(n.id);

    switch (n.contextType) {
      case 'order':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        );
        break;
      case 'chat':
        if (n.contextId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ChatDetailScreen(chatId: n.contextId!)),
          );
        }
        break;
      case 'job':
        if (n.contextId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => VacancyDetailsScreen(vacancyId: n.contextId!)),
          );
        }
        break;
      case 'business':
        if (n.contextId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BusinessProfileScreen(businessId: n.contextId!)),
          );
        }
        break;
      default:
        // Notification-и системавӣ — ҳеҷ ҷо намебарад, танҳо mark-as-read.
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final uid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Огоҳиномаҳо'),
        actions: [
          TextButton(
            onPressed: uid == null
                ? null
                : () => ref.read(notificationRepositoryProvider).markAllAsRead(uid),
            child: const Text('Ҳама хондашуда'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(myNotificationsProvider)),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyView(
              message: 'Огоҳиномае нест.',
              icon: Icons.notifications_none_rounded,
            );
          }
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      n.isRead ? AppColors.borderLight : AppColors.primaryLight,
                  child: Icon(
                    _iconFor(n.type),
                    size: 18,
                    color: n.isRead ? AppColors.textSecondaryLight : AppColors.primary,
                  ),
                ),
                title: Text(
                  n.title,
                  style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold),
                ),
                subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: n.createdAt != null
                    ? Text(
                        DateFormat('dd.MM HH:mm').format(n.createdAt!),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                      )
                    : null,
                onTap: () => _onTap(context, ref, n),
              );
            },
          );
        },
      ),
    );
  }
}
