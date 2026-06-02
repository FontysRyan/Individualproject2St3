import 'package:flutter/material.dart';

import 'pill_button.dart';
import 'survey_section_header.dart';

import 'activity_summary_row.dart';

class SurveyStepReady extends StatelessWidget {
  final List<({String name, int hours, int minutes})>
  activities;

  final Future<void> Function(int index)
  onDeleteActivity;

  final VoidCallback onNotYet;

  final VoidCallback onConfirm;

  const SurveyStepReady({
    super.key,
    required this.activities,
    required this.onDeleteActivity,
    required this.onNotYet,
    required this.onConfirm,
  });

  String _durationLabel(
    int hours,
    int minutes,
  ) {
    if (hours == 0) return '${minutes}m';

    if (minutes == 0) return '${hours}h';

    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SurveySectionHeader(
          title: 'Ready?',
          subtitle:
              'Got more activities or are you ready to start?',
        ),

        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 8,
            ),
            child: Column(
              children: [
                for (
                  int i = 0;
                  i < activities.length;
                  i++
                )
                  ActivitySummaryRow(
                    name: activities[i].name,
                    durationLabel: _durationLabel(
                      activities[i].hours,
                      activities[i].minutes,
                    ),
                    onDelete: () {
                      onDeleteActivity(i);
                    },
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: PillButton(
                label: 'Not yet',
                icon: Icons.arrow_back_rounded,
                alignment:
                    MainAxisAlignment.center,
                onTap: onNotYet,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: PillButton(
                label: 'Ready',
                icon: Icons.check_rounded,
                alignment:
                    MainAxisAlignment.center,
                onTap: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}