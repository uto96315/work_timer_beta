import 'package:flutter/material.dart';

import '../../widgets/workplace_form.dart';

/// The final onboarding step: entering the workplace's pay/schedule info.
///
/// No explicit "next" navigation is needed here — once the workplace is
/// created, the root router (watching Firestore) swaps the whole app to the
/// home screen automatically.
class WorkplaceSetupScreen extends StatelessWidget {
  const WorkplaceSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('勤務先の登録')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('時給や勤務時間を入力してください。あとから設定タブでいつでも変更できます。'),
          ),
          const Expanded(child: WorkplaceForm(workplace: null, showNameField: false)),
        ],
      ),
    );
  }
}
