import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class ApplyRewardsWidget extends StatefulWidget {
  final VoidCallback onRewardApplied;

  ApplyRewardsWidget({required this.onRewardApplied});

  @override
  _ApplyRewardsWidgetState createState() => _ApplyRewardsWidgetState();
}

class _ApplyRewardsWidgetState extends State<ApplyRewardsWidget> {
  bool _isLoading = false;
  Map<String, dynamic>? _appliedReward;
  double? _savedSubtotal;
  bool _isRewardApplied = false; // Track whether the reward is applied

  @override
  void initState() {
    super.initState();
    _loadAppliedReward();
    _retrieveSubtotal();
  }

  Future<void> _loadAppliedReward() async {
    final prefs = await SharedPreferences.getInstance();
    final rewardAmount = prefs.getString('reward_amount');
    final isRewardApplied = prefs.getBool('reward_applied') ?? false;

    setState(() {
      _appliedReward =
          rewardAmount != null ? {'reward_amount': rewardAmount} : null;
      _isRewardApplied = isRewardApplied;
    });
  }

  Future<void> _removeAppliedReward() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove individual reward-related entries
    await prefs.remove('reward_id');
    await prefs.remove('reward_amount');
    await prefs.remove('reward_applied');
    await prefs.remove('discount_amount_rewards');

    // Remove the combined reward details JSON entry
    await prefs.remove('reward_details');

    setState(() {
      _appliedReward = null;
      _isRewardApplied = false; // Update flag when reward is removed
    });

    widget.onRewardApplied();
  }

  Future<void> _retrieveSubtotal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedSubtotal = prefs.getDouble('subtotal');
    });
    print(_savedSubtotal);
  }

  Future<void> _applyReward() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check for selected service data
      final String? selectedServiceData =
          prefs.getString('selected_service_data');
      print('Selected Service Data from prefs: $selectedServiceData');

      // If there's any selected service data, do not apply the reward
      if (selectedServiceData != null && selectedServiceData.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Cannot apply the reward as a package is already selected.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final bool? isCouponApplied = prefs.getBool('coupon_applied');
      final bool? isOfferApplied = prefs.getBool('offer_applied');
      final bool? isGiftCardApplied = prefs.getBool('giftcard_applied');
//comment this below 3 snippets for removing the reward dependency
      if (isCouponApplied == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A coupon has already been applied.'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (isOfferApplied == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An offer has already been applied.'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (isGiftCardApplied == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A gift card has been applied'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      final String customerId1 = prefs.getString('customer_id') ?? '';
      final String customerId2 = prefs.getString('customer_id2') ?? '';
      final String customerId =
          customerId1.isNotEmpty ? customerId1 : customerId2;

      // Fetch profile details
      final profileResponse = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/profile-details/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_id': customerId,
          'branch_id': branchID,
          'salon_id': salonID,
        }),
      );

      print('Profile Details Response Status: ${profileResponse.statusCode}');
      print('Profile Details Response Body: ${profileResponse.body}');

      if (profileResponse.statusCode == 200) {
        final profileMap = jsonDecode(profileResponse.body);
        print('Parsed Profile Map: $profileMap'); // Debugging parsed data

        if (profileMap['status'] == 'true') {
          final profileData = profileMap['data'][0]; // Assuming data is a list
          final rewardsBalance = profileData['rewards_balance'];
          final customerName = profileData['full_name'];

          // Print the subtotal
          print('Subtotal: ${_savedSubtotal ?? "No subtotal available"}');

          // Show dialog with rewards balance
          _showApplyRewardDialog(
              rewardsBalance: rewardsBalance, customerName: customerName);
        } else {
          print('Failed to fetch profile details: ${profileMap['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to fetch profile details: ${profileMap['message']}'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('Failed to fetch profile details: ${profileResponse.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch profile details.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error applying reward: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying reward: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showApplyRewardDialog({
    required String rewardsBalance,
    required String customerName,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Apply Reward',
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.w500, // Change to 500
              color: CustomColors.backgroundtext,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: CustomColors.backgroundtext,
                child: Icon(
                  Icons.card_giftcard,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Rewards Balance:',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w500, // Change to 500
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200, width: 2),
                ),
                child: Text(
                  '\₹$rewardsBalance',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.w500, // Change to 500
                    color: CustomColors.backgroundtext,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(
                  color: CustomColors.backgroundtext,
                  fontWeight: FontWeight.w500, // Change to 500
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _applyRewardInternal(); // Call internal method to apply reward
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: CustomColors.backgroundtext,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Apply',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w500, // Change to 500
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyRewardInternal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String branchID = prefs.getString('branch_id') ?? '';
      final String salonID = prefs.getString('salon_id') ?? '';
      final String customerId1 = prefs.getString('customer_id') ?? '';
      final String customerId2 = prefs.getString('customer_id2') ?? '';
      final String customerId =
          customerId1.isNotEmpty ? customerId1 : customerId2;

      // Check if subtotal is available
      if (_savedSubtotal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subtotal is not available.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Fetch reward details
      final response = await http.post(
        Uri.parse('${MyApp.apiUrl}customer/apply-rewards/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'salon_id': salonID,
          'branch_id': branchID,
          'customer_id': customerId,
          'payable_amount': _savedSubtotal.toString(),
        }),
      );

      print('Apply Reward Response Status: ${response.statusCode}');
      print('Apply Reward Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> rewardMap = jsonDecode(response.body);
        print('Parsed Reward Map: $rewardMap'); // Debugging parsed data

        if (rewardMap['status'] == 'true') {
          final rewardData = rewardMap['data'];
          final discountAmount = rewardData['discount_amount'];
          final usedRewardsMsg = rewardData['used_rewards_msg'];

          // Check if subtotal is sufficient for the reward discount
          if (_savedSubtotal! < discountAmount) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Subtotal is less than the reward discount.'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          // Extract numeric value from usedRewardsMsg
          final RegExp numberRegex =
              RegExp(r'\d+'); // Matches one or more digits
          final match = numberRegex.firstMatch(usedRewardsMsg);
          final usedRewards = match != null ? match.group(0) : '0';

          setState(() {
            _appliedReward = {
              'reward_amount': usedRewards, // Save only the numeric value
              'discount_amount': discountAmount.toString(),
            };
            _isRewardApplied = true; // Update flag when reward is applied
          });

          // Save reward details in SharedPreferences as JSON
          final rewardDetails = {
            'is_reward_applied': '1',
            'used_rewards': usedRewards, // Save only the numeric value
            'reward_discount': discountAmount.toString(),
          };

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('reward_details', jsonEncode(rewardDetails));
          await prefs.setString(
              'reward_amount', usedRewards!); // Save only the numeric value
          await prefs.setDouble(
              'discount_amount_rewards', discountAmount.toDouble());
          await prefs.setBool('reward_applied', true);

          // Print saved JSON for debugging
          print(
              'Saved Reward Details JSON: ${prefs.getString('reward_details')}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reward applied successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
          widget.onRewardApplied();
        } else {
          print('Reward application failed: ${rewardMap['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${rewardMap['message']}'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('Failed to apply reward: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply reward.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error applying reward: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying reward: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures the widget covers the full width
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_appliedReward != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Applied Reward: \₹${_appliedReward!['reward_amount']}',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w500, // Updated to 500
                        color: Colors.green,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: _removeAppliedReward,
                  ),
                ],
              ),
            ),
          if (!_isRewardApplied)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply rewards to enjoy discounts!',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double
                      .infinity, // Ensures the button covers the full width
                  child: OutlinedButton(
                    onPressed: _applyReward,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: CustomColors.backgroundtext,
                        width: 1,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Apply Reward',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w600, // Updated to 600
                        color: CustomColors.backgroundtext,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
