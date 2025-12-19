import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../common/loading_card.dart';

/// Widget for displaying loading state of bookings
class BookingsLoadingWidget extends StatelessWidget {
  const BookingsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? ListView.builder(
            padding: Responsive.getPadding(context),
            itemCount: 5,
            itemBuilder: (context, index) {
              return LoadingCard(
                height: 150,
                margin: EdgeInsets.only(
                  bottom: Responsive.getSpacing(context,
                      mobile: 12, tablet: 16, desktop: 16),
                ),
              );
            },
          )
        : SingleChildScrollView(
            padding: Responsive.getPadding(context),
            child: ResponsiveLayout(
              child: ResponsiveGrid(
                mobileColumns: 1,
                tabletColumns: 2,
                desktopColumns: 3,
                spacing: Responsive.getSpacing(context,
                    mobile: 12, tablet: 16, desktop: 20),
                runSpacing: Responsive.getSpacing(context,
                    mobile: 12, tablet: 16, desktop: 20),
                children: List.generate(
                  6,
                  (index) => const LoadingGridItem(height: 200),
                ),
              ),
            ),
          );
  }
}
