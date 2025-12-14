import 'package:flutter/material.dart';
import '../../models/resource.dart';
import '../common/animated_card.dart';
import '../../core/animations/animation_utils.dart';

/// Resource card widget displaying resource information with animations
class ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback? onTap;
  final int? index; // For staggered animations
  
  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
    this.index,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget cardContent = AnimatedCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  resource.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StatusBadge(status: resource.status),
            ],
          ),
          const SizedBox(height: 8),
          if (resource.description != null && resource.description!.isNotEmpty) ...[
            Text(
              resource.description!,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      resource.type.value,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.layers, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Floor ${resource.floor}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Capacity: ${resource.capacity}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _AvailabilityIndicator(available: resource.isAvailable),
        ],
      ),
    );

    // Apply staggered animation if index is provided
    if (index != null) {
      return AnimationUtils.staggeredFadeIn(
        index: index!,
        child: cardContent,
      );
    }

    return AnimationUtils.fadeIn(child: cardContent);
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final ResourceStatus status;
  
  const _StatusBadge({required this.status});
  
  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (status) {
      case ResourceStatus.available:
        color = Colors.green;
        label = 'Available';
        break;
      case ResourceStatus.unavailable:
        color = Colors.red;
        label = 'Unavailable';
        break;
      case ResourceStatus.maintenance:
        color = Colors.grey;
        label = 'Maintenance';
        break;
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

/// Availability indicator widget
class _AvailabilityIndicator extends StatelessWidget {
  final bool available;
  
  const _AvailabilityIndicator({required this.available});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: available ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: available ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            available ? 'Available' : 'Unavailable',
            style: TextStyle(
              color: available ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

