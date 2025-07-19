import 'package:flutter/material.dart';

// Define a StatefulWidget for the SubscriptionPage.
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

// Define the State class for SubscriptionPage.
class _SubscriptionPageState extends State<SubscriptionPage> {
  // A variable to hold the currently selected subscription plan.
  String _selectedTab = 'XTRA'; // Default selected tab based on images
  String? _selectedPlan; // Nullable to indicate no plan selected initially

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic visual structure for the material design app.
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        title: const Text(
          'Choose A Plan', // Title of the subscription page.
          style: TextStyle(color: Colors.white), // White text for app bar title
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white), // White close icon.
          onPressed: () {
            // This pop will go back to the MainBrowseScreen
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.black, // AppBar background to black
        elevation: 0, // Remove shadow
      ),
      // Body of the page, wrapped in a SingleChildScrollView to allow scrolling if content overflows.
      body: Stack(
        children: [
          // Background gradient to mimic the subtle dark background from images
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A1A), // Darker shade
                    Colors.black,      // Black
                  ],
                ),
              ),
            ),
          ),
          // Content of the page
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Padding around the content.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center children horizontally
              children: [
                // Segmented control for XTRA and UNLIMITED
                _buildSegmentedControl(),
                const SizedBox(height: 20),

                // Display content based on selected tab
                _selectedTab == 'XTRA'
                    ? _buildXtraContent()
                    : _buildUnlimitedContent(),
                const SizedBox(height: 20),

                // Subscription Plan Cards.
                // Wrapped in SingleChildScrollView for horizontal scrolling to accommodate multiple cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Align to start
                    children: [
                      const SizedBox(width: 0), // No initial padding, as SingleChildScrollView already has padding
                      SizedBox(
                        width: 100, // Fixed width for each card
                        height: 140, // Fixed height for each card
                        child: _buildSubscriptionCard(
                          context,
                          '1 WEEK',
                          _selectedTab == 'XTRA' ? '\$15.99' : '\$30.99',
                          '', // No sub-text for 1 WEEK in images
                          'weekly',
                          false, // Not popular
                        ),
                      ),
                      const SizedBox(width: 15), // Spacing between cards
                      SizedBox(
                        width: 100,
                        height: 140,
                        child: _buildSubscriptionCard(
                          context,
                          '1 MONTH',
                          _selectedTab == 'XTRA' ? '\$25.99' : '\$50.99',
                          _selectedTab == 'XTRA' ? 'Save 62%' : 'Save 61%',
                          'monthly',
                          true, // Popular
                        ),
                      ),
                      if (_selectedTab == 'XTRA') ...[ // Only show for XTRA tab
                        const SizedBox(width: 15),
                        SizedBox(
                          width: 100,
                          height: 140,
                          child: _buildSubscriptionCard(
                            context,
                            '3 MONTHS',
                            '\$49.99',
                            'Save 75%',
                            'quarterly',
                            false, // Not popular
                          ),
                        ),
                      ],
                      if (_selectedTab == 'XTRA') ...[ // Only show for XTRA tab
                        const SizedBox(width: 15),
                        SizedBox(
                          width: 100,
                          height: 140,
                          child: _buildSubscriptionCard(
                            context,
                            '12 MONTHS',
                            '\$124.99',
                            'Save 84%',
                            'annually',
                            false, // Not popular
                            isBestValue: true, // Mark as best value
                          ),
                        ),
                      ],
                      const SizedBox(width: 0), // No trailing padding
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Continue Button.
                SizedBox(
                  width: double.infinity, // Make the button take full width.
                  height: 55, // Fixed height for the button.
                  child: ElevatedButton(
                    onPressed: _selectedPlan == null
                        ? null // Disable button if no plan is selected.
                        : () {
                      // Action to perform when the button is pressed.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You selected the $_selectedPlan plan!'),
                          backgroundColor: Colors.yellow,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow, // Yellow button background
                      foregroundColor: Colors.black, // Black text on button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 20),

                // Terms and Conditions / Privacy Policy links.
                const Text(
                  'Subscription purchases will be charged to your iTunes account.\n'
                      'Subscriptions auto-renew unless cancelled at least 24\n'
                      'hours before the current period ends. You can manage or cancel auto-\n'
                      'renewal in your Account Settings after purchase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12), // Grey text
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Navigating to Terms & Conditions...'),
                        backgroundColor: Colors.grey,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: const Text(
                    'Terms & Conditions Apply',
                    style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline), // Grey text
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds the segmented control for XTRA and UNLIMITED tabs.
  Widget _buildSegmentedControl() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900], // Dark grey background for the control
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wrap content
        children: [
          _buildSegmentButton('XTRA'),
          _buildSegmentButton('UNLIMITED'),
        ],
      ),
    );
  }

  // Helper method to build individual segment buttons.
  Widget _buildSegmentButton(String text) {
    bool isSelected = _selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = text;
          _selectedPlan = null; // Reset selected plan when tab changes
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent, // White background if selected
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white, // Black text if selected, white otherwise
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Builds the content for the XTRA tab, including features.
  Widget _buildXtraContent() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Dark background for the content area
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'XTRA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.yellow, // Yellow text
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Cross Streams',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue, // White text
            ),
          ),
          const SizedBox(height: 6),
          _buildFeatureRow(Icons.person, '600 Profiles'), // Placeholder icon for 600 Profiles
          _buildFeatureRow(Icons.block, 'No more Ads'),
          _buildFeatureRow(Icons.timer, 'Expiring Albums'), // Placeholder icon for Expiring Albums
          _buildFeatureRow(Icons.filter_alt, 'Filter All Chats'),
          _buildFeatureRow(Icons.photo_album, 'Multiple Albums'),
          _buildFeatureRow(Icons.explore, 'Chat in Explore'),
          _buildFeatureRow(Icons.receipt_long, 'Read Receipts'),
          _buildFeatureRow(Icons.notes, 'Saved Phrases'),
          _buildFeatureRow(Icons.chat_bubble, 'Mark Chatted'),
          _buildFeatureRow(Icons.rss_feed, 'Right Now Feed 40 posts'), // Placeholder icon for Right Now Feed
          _buildFeatureRow(Icons.history, 'Tap History'), // Placeholder icon for Tap History
        ],
      ),
    );
  }

  // Builds the content for the UNLIMITED tab, including features.
  Widget _buildUnlimitedContent() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Dark background for the content area
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UNLIMITED',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.yellow, // Yellow text
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Blue Mountain',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange, // White text
            ),
          ),
          const SizedBox(height: 2),
          _buildFeatureRow(Icons.people_alt, 'Unlimited Profiles'), // Placeholder icon
          _buildFeatureRow(Icons.chat, 'For You Chats', isNew: true), // Placeholder icon
          _buildFeatureRow(Icons.visibility, 'Viewed Me'), // Placeholder icon
          _buildFeatureRow(Icons.timer_off, 'Expiring Photos & Albums'), // Placeholder icon
          _buildFeatureRow(Icons.visibility_off, 'Incognito'), // Placeholder icon
          _buildFeatureRow(Icons.undo, 'Unsend Messages'), // Placeholder icon
          _buildFeatureRow(Icons.rss_feed, 'Right Now Feed 100 posts'), // Placeholder icon
          _buildFeatureRow(Icons.history, 'Tap History'), // Placeholder icon
          const SizedBox(height: 12),
          const Text(
            'Includes All XTRA Features',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue, // White text
            ),
          ),
          const SizedBox(height: 10),
          _buildFeatureRow(Icons.block, 'No more Ads'),
          _buildFeatureRow(Icons.filter_alt, 'Filter All Chats'),
          _buildFeatureRow(Icons.photo_album, 'Multiple Albums'),
          _buildFeatureRow(Icons.explore, 'Chat in Explore'),
          _buildFeatureRow(Icons.receipt_long, 'Read Receipts'),
          // The image shows some XTRA features under "Includes All XTRA Features"
          // I will add the ones that are visible in the images.
        ],
      ),
    );
  }

  // Helper method to build a single feature row with an icon and text.
  Widget _buildFeatureRow(IconData icon, String text, {bool isNew = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellow, size: 24), // Yellow icons
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white), // White text
          ),
          if (isNew) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to build individual subscription plan cards.
  Widget _buildSubscriptionCard(
      BuildContext context,
      String title,
      String priceMain,
      String priceSub,
      String planId, // Unique ID for the plan.
      bool isPopular,
      {bool isBestValue = false}
      ) {
    bool isSelected = _selectedPlan == planId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planId; // Update the selected plan when tapped.
        });
      },
      child: Stack(
        clipBehavior: Clip.none, // Allow children to overflow
        children: [
          Card(
            color: Colors.grey[900], // Default dark grey background for cards
            elevation: 0, // No elevation for the cards
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Rounded corners for the card.
              side: BorderSide(
                color: isSelected ? Colors.yellow : Colors.grey[800]!, // Yellow border if selected
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Reduced padding inside the card
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center, // Center align title
                    style: TextStyle(
                      fontSize: 14, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.yellow : Colors.white70, // Yellow for selected, white for unselected
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  FittedBox( // Ensures text fits within the available space
                    fit: BoxFit.scaleDown,
                    child: Text(
                      priceMain,
                      textAlign: TextAlign.center, // Center align price
                      style: TextStyle(
                        fontSize: 24, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.yellow : Colors.white, // Yellow for selected, white for unselected
                      ),
                    ),
                  ),
                  if (priceSub.isNotEmpty) ...[
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      priceSub,
                      textAlign: TextAlign.center, // Center align sub-text
                      style: TextStyle(
                        fontSize: 12, // Reduced font size
                        color: isSelected ? Colors.yellow.shade700 : Colors.grey, // Yellow for selected, grey for unselected
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // "POPULAR" badge
          if (isPopular)
            Positioned(
              top: 5,
              right: -10,
              child: Transform.rotate(
                angle: 0.2, // Slightly rotate the badge
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          // "BEST VALUE" badge
          if (isBestValue)
            Positioned(
              top: 5,
              right: -3,
              child: Transform.rotate(
                angle: 0.3, // Slightly rotate the badge
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
          // Custom Radio Button (mimicking Grindr's selection indicator)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.yellow : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.yellow : Colors.grey[600]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
