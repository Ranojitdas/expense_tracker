import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Terms of Service',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Last updated: January 1, 2024',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            '1. Introduction\n\nWelcome to Track My End. By using our app, you agree to these terms. Please read them carefully.\n\n2. Using our Services\n\nYou must follow any policies made available to you within the Services. You may use our Services only as permitted by law. We may suspend or stop providing our Services to you if you do not comply with our terms or policies or if we are investigating suspected misconduct.\n\n3. Your Track My End Account\n\nYou may need a Track My End Account in order to use some of our Services. You are responsible for maintaining the security of your account and the activities that occur under your account.\n\n4. Privacy and Copyright Protection\n\nTrack My End\'s privacy policies explain how we treat your personal data and protect your privacy when you use our Services. By using our Services, you agree that Track My End can use such data in accordance with our privacy policies.\n\n5. Your Content in our Services\n\nSome of our Services allow you to upload, submit, store, send or receive content. You retain ownership of any intellectual property rights that you hold in that content. When you upload, submit, store, send or receive content to or through our Services, you give Track My End a worldwide license to use, host, store, reproduce, modify, create derivative works, communicate, publish, publicly perform, publicly display and distribute such content.\n\n6. Modifying and Terminating our Services\n\nWe are constantly changing and improving our Services. We may add or remove functionalities or features, and we may suspend or stop a Service altogether. You can stop using our Services at any time, although we\'ll be sorry to see you go. Track My End may also stop providing Services to you, or add or create new limits to our Services at any time.\n\n7. Warranties and Disclaimers\n\nWe provide our Services using a commercially reasonable level of skill and care. But there are certain things that we don\'t promise about our Services. Other than as expressly set out in these terms or additional terms, neither Track My End nor its suppliers or distributors make any specific promises about the Services.\n\n8. Liability for our Services\n\nWhen permitted by law, Track My End, and Track My End\'s suppliers and distributors, will not be responsible for lost profits, revenues, or data, financial losses or indirect, special, consequential, exemplary, or punitive damages.\n\n9. Business uses of our Services\n\nIf you are using our Services on behalf of a business, that business accepts these terms. It will hold harmless and indemnify Track My End and its affiliates, officers, agents, and employees from any claim, suit or action arising from or related to the use of the Services or violation of these terms, including any liability or expense arising from claims, losses, damages, suits, judgments, litigation costs and attorneys\' fees.\n\n10. About these Terms\n\nWe may modify these terms or any additional terms that apply to a Service to, for example, reflect changes to the law or changes to our Services. You should look at the terms regularly. We\'ll post notice of modifications to these terms on this page. Changes will not apply retroactively and will become effective no sooner than fourteen days after they are posted. However, changes addressing new functions for a Service or changes made for legal reasons will be effective immediately. If you do not agree to the modified terms for a Service, you should discontinue your use of that Service.\n\n11. Contact Us\n\nIf you have any questions about these Terms of Service, please contact us at:\n\nEmail: ranojitdas362@gmail.com',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
