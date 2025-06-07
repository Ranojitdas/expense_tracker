import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Privacy Policy',
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
            '1. Introduction\n\nWelcome to Track My End. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our app and tell you about your privacy rights and how the law protects you.\n\n2. The Data We Collect\n\nWe may collect, use, store and transfer different kinds of personal data about you which we have grouped together as follows:\n\n- Identity Data includes first name, last name, username or similar identifier.\n- Contact Data includes email address and telephone numbers.\n- Transaction Data includes details about payments to and from you and other details of products and services you have purchased from us.\n- Technical Data includes internet protocol (IP) address, your login data, browser type and version, time zone setting and location, browser plug-in types and versions, operating system and platform, and other technology on the devices you use to access this app.\n\n3. How We Use Your Data\n\nWe will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:\n\n- Where we need to perform the contract we are about to enter into or have entered into with you.\n- Where it is necessary for our legitimate interests (or those of a third party) and your interests and fundamental rights do not override those interests.\n- Where we need to comply with a legal obligation.\n\n4. Data Security\n\nWe have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorized way, altered or disclosed. In addition, we limit access to your personal data to those employees, agents, contractors and other third parties who have a business need to know.\n\n5. Your Legal Rights\n\nUnder certain circumstances, you have rights under data protection laws in relation to your personal data, including the right to:\n\n- Request access to your personal data.\n- Request correction of your personal data.\n- Request erasure of your personal data.\n- Object to processing of your personal data.\n- Request restriction of processing your personal data.\n- Request transfer of your personal data.\n- Right to withdraw consent.\n\n6. Contact Us\n\nIf you have any questions about this privacy policy or our privacy practices, please contact us at:\n\nEmail: ranojitdas362@gmail.com',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
