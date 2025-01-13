import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/Payment/review_api_controller.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure you have shimmer package
import 'package:http/http.dart' as http;

import '../main.dart';

class EReciept extends StatefulWidget {
  @override
  _ERecieptPageState createState() => _ERecieptPageState();
}

class _ERecieptPageState extends State<EReciept> {
  Map<String, dynamic>? selectedServiceData1;
  Map<String, dynamic>? selectedServiceData2;
  final ApiController _apiController = ApiController();
  double serviceDiscountPercentage = 0.0;
  double productDiscountPercentage = 0.0;
  bool _isMember = false;
  double grandTotal = 0.0;
  int discountType = 0;
  double serviceDiscount = 0.0;
  String isGstApplicable = '';
  String gstRate = '';
  String gstNo = '';
  String globalDiscountType = '';
  List<Map<String, String?>> selectedData = [];
  double gstPercent = 0;
  Map<int, List<String>>? _stylistsData;
  List<String> _checkedProductIds = []; // Store selected product IDs
  List<String> _products = [];
  double productDiscount = 0.0;
  bool _isLoading = true;
  String bookingDate = '';
  String bookingTime = '';
  String _fullName = '';

  String globalOfferDetails = '';
  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadStoreName();
    _loadStoredData();
    fetchGstRate();
    _loadProducts();
    _fetchMembershipData();
  }

  Future<void> fetchGstRate() async {
    // Fetch customer ID, branch ID, and salon ID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? customerId1 = prefs.getString('customer_id');
    final String? customerId2 = prefs.getString('customer_id2');
    final String branchID = prefs.getString('branch_id') ?? '';
    final String salonID = prefs.getString('salon_id') ?? '';

    // Determine the valid customer ID
    final String customerId = customerId1?.isNotEmpty == true
        ? customerId1!
        : customerId2?.isNotEmpty == true
            ? customerId2!
            : '';

    if (customerId.isEmpty) {
      throw Exception('No valid customer ID found');
    }

    // Prepare request body
    final url = Uri.parse('${MyApp.apiUrl}customer/store-gst');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      'salon_id': salonID,
      'branch_id': branchID,
      'customer_id': customerId,
    });

    try {
      // Make the API request
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Parse the response
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'true') {
          // Store values in global variables
          isGstApplicable = responseData['data']['is_gst_applicable'];
          gstRate = responseData['data']['gst_rate'];
          gstNo = responseData['data']['gst_no'];
          gstPercent = double.parse(
              gstRate); // Convert gstRate to double for calculations

          // Print the values for debugging
          print('GST Applicable: $isGstApplicable');
          print('GST Rate: $gstRate');
          print('GST No: $gstNo');

          // Call setState to rebuild UI if you're using a StatefulWidget
          // setState(() {}); // Uncomment this if you're inside a StatefulWidget
        } else {
          print('Error: ${responseData['message']}');
        }
      } else {
        print('Failed to load GST rate');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void _processOffersResponse(String offersResponse) {
    // Parse the response
    final Map<String, dynamic> responseMap = jsonDecode(offersResponse);

    // Check if 'data' key exists and is a list
    if (responseMap.containsKey('data') && responseMap['data'] is List) {
      final List<dynamic> offersData = responseMap['data'];

      for (var offer in offersData) {
        _processOffer(offer);
      }
    } else {
      // Handle single offer format
      final offer = responseMap;
      _processOffer(offer);
    }
  }

  void _processOffer(Map<String, dynamic> offer) {
    final offerName = offer['offer_name'] as String? ?? 'Unknown Offer';
    final discountType = offer['discount_type'] as String? ?? 'not there';
    globalDiscountType = discountType; // Store discount_type globally

    // Get the discount amount
    final discount = double.tryParse(offer['discount'].toString()) ?? 0.0;

    // Store the offer details including the discount type and amount
    globalOfferDetails =
        '$offerName ${discountType == '1' ? 'Flat ₹${discount.toStringAsFixed(2)}' : '${discount.toStringAsFixed(2)}%'}';

    // Print the stored offer details
    print('Offer details: $globalOfferDetails');

    final services = offer['services'] as List<dynamic>? ?? [];

    final Map<String, double> offerDiscounts = {};
    final Map<String, String> offerDescriptions = {};
    bool discountApplied = false;

    for (var service in services) {
      final serviceId = service['service_id'] as String? ?? '';
      offerDiscounts[serviceId] = discount;
      offerDescriptions[serviceId] = offerName;
    }

    final Map<String, dynamic> mergedServices = _mergeServiceData();

    mergedServices.forEach((key, service) {
      final serviceId = (service['serviceId'] as String?)?.trim() ?? '';
      final discount = offerDiscounts[serviceId] ?? 0.0;

      if (discount > 0) {
        service['discount'] = discount;
        service['offer_description'] = offerDescriptions[serviceId];
        discountApplied = true;

        // Debugging information
        print(
            'Applied offer "$offerName" with discount ₹${discount.toStringAsFixed(2)} and discount type $discountType to service ID $serviceId');
      } else {
        service.remove('discount');
        service.remove('offer_description');
      }
    });
  }

  Future<void> _loadStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('stylist_service_data_stored');

    if (storedData != null) {
      List<dynamic> stylistServiceList = jsonDecode(storedData);
      print(
          'Loaded Data of stylist: $stylistServiceList'); // Print the loaded data to the console

      setState(() {
        selectedData = stylistServiceList
            .map((item) => Map<String, String?>.from(item))
            .toList();
      });
    } else {
      print('No data found in SharedPreferences.');
    }
  }

  Future<void> _loadStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('full_name') ?? 'Apple Saloon';

    setState(() {
      _fullName = fullName;
    });
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? productsFetch =
        prefs.getStringList('selected_product_ids');

    // Print the stored product IDs for debugging
    print('Stored Product IDs: $productsFetch');

    // Check if the productsFetch is not null and has items
    if (productsFetch != null && productsFetch.isNotEmpty) {
      setState(() {
        _products = productsFetch; // Store the product IDs
      });
    } else {
      // Handle the case where no products are found
      print('No products found in SharedPreferences.');
      setState(() {
        _products = []; // Optionally clear the products state
      });
    }

    print('Current Products: $_products'); // Use clearer print statement
  }

  Future<void> _fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch and decode selected service data
    final String? selectedServiceDataJson1 =
        prefs.getString('selected_service_data');
    final String? selectedServiceDataJson2 =
        prefs.getString('selected_service_data1');

    if (selectedServiceDataJson1 != null) {
      setState(() {
        selectedServiceData1 = jsonDecode(selectedServiceDataJson1);
      });
    }

    if (selectedServiceDataJson2 != null) {
      setState(() {
        selectedServiceData2 = jsonDecode(selectedServiceDataJson2);
      });
    }

    // Retrieve and print the selected stylists data
    final String? selectedStylistsJson = prefs.getString('selected_stylists');

    if (selectedStylistsJson != null) {
      final stylistsMap =
          jsonDecode(selectedStylistsJson) as Map<String, dynamic>;
      setState(() {
        _stylistsData = stylistsMap.map((key, value) {
          return MapEntry(int.parse(key), List<String>.from(value));
        });
      });
    }

    // Retrieve booking date and time
    setState(() {
      bookingDate = prefs.getString('selected_date') ?? 'Unknown Date';
      bookingTime = prefs.getString('book_time') ?? 'Unknown Time';
    });

    // Fetch membership data
    await _fetchMembershipData();
    final String? offersResponse = prefs.getString('offers_response');
    if (offersResponse != null) {
      print('Offers Response: $offersResponse');
      // Process the offers response
      _processOffersResponse(offersResponse);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_stylist_id');
    await prefs.remove('gift_card_code');
    await prefs.remove('selected_date');
    await prefs.remove('selected_time_slot');
    await prefs.remove('offer_applied');
    await prefs.remove('selected_service_data1');
    await prefs.remove('selected_service_data2');
    await prefs.remove('selected_package_data_add_package');
    await prefs.remove('offers_response');
    await prefs.remove('stylist_service_data_stored');
    await prefs.remove('reward_id');
    await prefs.remove('reward_amount');
    await prefs.remove('reward_applied');
    await prefs.remove('discount_amount_rewards');
    await prefs.remove('coupons_response');
    await prefs.remove('minimum_amount');
    await prefs.remove('offered_price');
    await prefs.remove('offer_details');
    await prefs.remove('selected_product_ids');
    await prefs.remove('coupon_applied');
    await prefs.remove('coupon_details');
    await prefs.remove('giftcard_id');
    await prefs.remove('giftcard_min_amount');
    await prefs.remove('giftcard_discount_amount');
    await prefs.remove('giftcard_applied');

    // Remove the combined gift card details JSON entry
    await prefs.remove('giftcard_details');
    // Remove the combined reward details JSON entry
    await prefs.remove('reward_details');
  }

  Future<void> _fetchMembershipData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customerId1 = prefs.getString('customer_id');
      final String? customerId2 = prefs.getString('customer_id2');
      final String branchId = prefs.getString('branch_id') ?? '';
      final String salonId = prefs.getString('salon_id') ?? '';

      final String customerId = customerId1?.isNotEmpty == true
          ? customerId1!
          : customerId2?.isNotEmpty == true
              ? customerId2!
              : '';

      if (customerId.isEmpty) {
        return;
      }

      final membershipResponse = await _apiController.fetchMembershipData(
          salonId, branchId, customerId);

      if (membershipResponse is Map<String, dynamic>) {
        final data = membershipResponse['data'];

        if (data is Map<String, dynamic>) {
          final isMember = int.tryParse(data['is_member'].toString()) ?? 0;
          _isMember = isMember == 1;

          final membershipDetails = data['membership_details'];

          // Define discountType and initialize it
          discountType =
              int.tryParse(membershipDetails['discount_type'].toString()) ?? 0;

          // Check if there is any selected service data in SharedPreferences
          final String? selectedServiceData =
              prefs.getString('selected_service_data');
          final String totalServiceProducts =
              prefs.getString('selected_service_data1') ?? '';

          // Only apply discounts if there is no selected service data
          if (selectedServiceData == null || selectedServiceData.isEmpty) {
            if (membershipDetails is Map<String, dynamic>) {
              final serviceDiscount = double.tryParse(
                      membershipDetails['service_discount'].toString()) ??
                  0.0;
              final productDiscount = double.tryParse(
                      membershipDetails['product_discount'].toString()) ??
                  0.0;

              double totalServicePrice = 0.0;
              double totalProductPrice = 0.0;

              // Calculate total service and product prices
              final selectedServices = jsonDecode(totalServiceProducts);
              selectedServices.forEach((serviceId, service) {
                totalServicePrice += double.tryParse(service['price']) ?? 0.0;

                // Calculate product price for each service
                final products = service['products'];
                if (products != null) {
                  products.forEach((product) {
                    totalProductPrice +=
                        double.tryParse(product['productPrice']) ?? 0.0;
                  });
                }
              });

              // Apply service and product discounts separately
              setState(() {
                if (discountType == 0) {
                  // Percentage based discount
                  this.serviceDiscount =
                      totalServicePrice * (serviceDiscount / 100);
                  this.productDiscount =
                      totalProductPrice * (productDiscount / 100);
                } else if (discountType == 1) {
                  // Flat amount discount
                  this.serviceDiscount = serviceDiscount;
                  this.productDiscount = productDiscount;
                }

                this.serviceDiscountPercentage = serviceDiscount;
                this.productDiscountPercentage = productDiscount;
              });

              final membershipDataToSave = {
                'is_member': isMember,
                'membership_details': membershipDetails
              };
              final membershipDataJson = jsonEncode(membershipDataToSave);
              await prefs.setString('membership_details', membershipDataJson);
              print('membershipDataJson: $membershipDataJson');
            }
          } else {
            // Clear discounts if there is selected service data
            setState(() {
              this.serviceDiscount = 0.0;
              this.productDiscount = 0.0;
              this.serviceDiscountPercentage = 0.0;
              this.productDiscountPercentage = 0.0;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching membership data: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchData();
  }

  String _formatStylistsData(Map<int, List<String>> stylistsData) {
    // Use a Set to store unique stylist names
    Set<String> stylistSet = {};

    // Populate the stylistSet with names
    stylistsData.forEach((key, names) {
      stylistSet.addAll(names);
    });

    // Convert the Set back to a List for formatting
    List<String> stylists = stylistSet.toList();

    return stylists.isEmpty ? 'No stylists assigned' : stylists.join(', ');
  }

  Map<String, dynamic> _mergeServiceData() {
    final Map<String, dynamic> combinedServices = {};

    if (selectedServiceData1 != null) {
      combinedServices.addAll(selectedServiceData1!);
    }
    if (selectedServiceData2 != null) {
      combinedServices.addAll(selectedServiceData2!);
    }

    return combinedServices;
  }

  double _calculateSubtotal() {
    double subtotal = 0.0;
    double totalServiceDiscount = 0.0;
    double totalProductDiscount = 0.0;

    print('Global discount type is $globalDiscountType');
    final Map<String, dynamic> mergedServices = _mergeServiceData();

    for (var service in mergedServices.values) {
      if (service != null) {
        // Calculate the price of the service
        final price = double.tryParse(service['price'].toString()) ?? 0.0;
        subtotal += price;

        // Debugging: Print service price
        print('Service Price: $price');

        // Check for products within the service
        if (service['products'] != null) {
          for (var product in service['products']) {
            if (product != null) {
              final productPrice =
                  double.tryParse(product['productPrice'].toString()) ?? 0.0;
              subtotal += productPrice;

              // Debugging: Print product details
              print('Product: ${product['productName']}, Price: $productPrice');
            }
          }
        }

        // Get the discount
        final discount =
            double.tryParse(service['discount']?.toString() ?? '0.0') ?? 0.0;

        // Parsing globalDiscountType as an int
        final int globalDiscount = int.tryParse(globalDiscountType) ?? 0;

        // Apply global discount logic
        if (globalDiscount == 1) {
          // If globalDiscountType is 1, subtract the discount value directly from the service price
          totalServiceDiscount += discount;
        } else if (globalDiscount == 0) {
          // If globalDiscountType is 0, apply the discount as a percentage of the price
          final percentageDiscount = price * (discount / 100);
          totalServiceDiscount += percentageDiscount;

          // Debugging: Print percentage discount applied
          print('Percentage Discount Applied: $percentageDiscount');
        }

        // Debugging information for each service
        print(
            'Service after discount: ${service['serviceId']}, Price: $price, Discount: $discount, Global Discount Type: $globalDiscount');
      }
    }

    // Calculate total discount amount before applying it to subtotal
    double totalDiscount = totalServiceDiscount + totalProductDiscount;

    // Debugging: Print total discount before applying to subtotal
    print('Total Discount (service + product): $totalDiscount');

    // Apply total service discount to subtotal
    subtotal -= totalServiceDiscount;

    // Print total service discount
    print('Total service discount applied: $totalServiceDiscount');

    // Calculate and apply total product discount
    mergedServices.values.forEach((service) {
      if (service != null && service['products'] != null) {
        for (var product in service['products']) {
          if (product != null) {
            final productPrice =
                double.tryParse(product['productPrice'].toString()) ?? 0.0;
            final productDiscount = double.tryParse(
                    product['productDiscount']?.toString() ?? '0.0') ??
                0.0;

            // Parsing globalDiscountType as an int
            final int globalDiscount = int.tryParse(globalDiscountType) ?? 0;

            // Apply global discount logic to the product
            if (globalDiscount == 1) {
              // If globalDiscountType is 1, apply flat discount
              totalProductDiscount += productDiscount;
            } else if (globalDiscount == 0) {
              // If globalDiscountType is 0, apply percentage discount
              final percentageDiscount = productPrice * (productDiscount / 100);
              totalProductDiscount += percentageDiscount;

              // Debugging: Print percentage discount applied to the product
              print(
                  'Percentage Discount Applied to Product: $percentageDiscount');
            }

            // Debugging information for each product
            print(
                'Product: ${product['productName']}, Price: $productPrice, Discount: $productDiscount');
          }
        }
      }
    });

// Apply total product discount to subtotal
    subtotal -= totalProductDiscount;

    // Print total product discount
    print('Total product discount applied: $totalProductDiscount');

    // Combine both service and product discounts
    double combinedDiscount = totalServiceDiscount + totalProductDiscount;
    print('Total discount subtracted from subtotal: $combinedDiscount');

    // Print final subtotal
    print('Total subtotal after all discounts: $subtotal');

    _saveSubtotalToPreferences(subtotal);
    return subtotal;
  }

  Future<void> _saveSubtotalToPreferences(double subtotal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('subtotal', subtotal);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return WillPopScope(
      onWillPop: () async {
        // This will navigate back to BookAppointmentPage and clear the navigation stack
        // Navigator.pop(context);
        await _clearPreferences();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(title: ''),
          ),
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => BookAppointmentPage()),
        // );
        return Future.value(false); // Prevent the default back action
      },
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: CustomColors.backgroundLight,
          elevation: 0,
          leading: GestureDetector(
            onTap: () async {
              await _clearPreferences();
              // Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(title: ''),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Image.asset(
                'assets/back.png',
                width: screenWidth * 0.06,
                height: screenWidth * 0.06,
              ),
            ),
          ),
          title: Text(
            'E-Reciept',
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? _buildShimmerEffect()
                    : SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: screenHeight,
                          ),
                          child: Container(
                            width: screenWidth,
                            color: Color.fromARGB(166, 255, 255, 255),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                _buildReviewSummary(),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Clear preferences if needed (optional)
                    await _clearPreferences();

                    // Retrieve the receipt URL from SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    final receiptUrl = prefs
                        .getString('receipt_url'); // Adjust the key if needed

                    if (receiptUrl != null && receiptUrl.isNotEmpty) {
                      // Launch the receipt URL
                      if (await canLaunch(receiptUrl)) {
                        await launch(receiptUrl);
                      } else {
                        throw 'Could not launch $receiptUrl';
                      }
                    } else {
                      // Handle the case when the URL is not available
                      print('No receipt URL found');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        CustomColors.backgroundtext, // Background color
                    fixedSize: Size(screenWidth - 40,
                        48), // Adjusted to screen width with padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Download Receipt',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  offset: Offset(10, -2),
                  blurRadius: 75,
                  spreadRadius: 4,
                  color: Color(0x00000008),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 10,
                  color: Colors.white,
                ),
                Container(
                  width: 50,
                  height: 10,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _getFullNameFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('full_name') ?? 'Test Saloon';
  }

  Widget _buildReviewSummary() {
    return FutureBuilder<String>(
      future: _getFullNameFromPreferences(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        String fullName = snapshot.data ?? 'Test Saloon';

        Future<Map<String, String?>> _fetchCouponData() async {
          final prefs = await SharedPreferences.getInstance();
          final minimumAmount = prefs.getString('minimum_amount');
          final offeredPrice = prefs.getString('offered_price');
          return {
            'minimumAmount': minimumAmount,
            'offeredPrice': offeredPrice,
          };
        }

        Future<Map<String, String?>> _fetchGiftCardData() async {
          final prefs = await SharedPreferences.getInstance();
          final minAmount = prefs.getString('giftcard_min_amount');
          final discountAmount = prefs.getString('giftcard_discount_amount');
          return {
            'minAmount': minAmount,
            'discountAmount': discountAmount,
          };
        }

        Future<double> _fetchRewardDiscount() async {
          final prefs = await SharedPreferences.getInstance();
          final rewardDiscount =
              prefs.getDouble('discount_amount_rewards') ?? 0.0;
          return rewardDiscount;
        }

        return FutureBuilder<Map<String, dynamic>>(
          future: Future.wait([
            _fetchCouponData(),
            _fetchGiftCardData(),
            _fetchRewardDiscount()
          ]).then((results) {
            return {
              'coupon': results[0],
              'giftCard': results[1],
              'rewardDiscount': results[2],
            };
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final couponData = snapshot.data?['coupon'] ?? {};
            final giftCardData = snapshot.data?['giftCard'] ?? {};
            final rewardDiscount = snapshot.data?['rewardDiscount'] ?? 0.0;

            final minimumAmount = couponData['minimumAmount'];
            final offeredPrice = couponData['offeredPrice'];

            final giftCardMinAmount = giftCardData['minAmount'];
            final giftCardDiscountAmount = giftCardData['discountAmount'];

            double subtotal = _calculateSubtotal();
            print('Initial Subtotal: ₹${subtotal.toStringAsFixed(2)}');

            // Service and product discounts
            double totalServiceDiscount = 0.0;
            double totalProductDiscount = 0.0;

            // Calculate total service and product discounts
            _mergeServiceData().values.forEach((service) {
              if (service != null) {
                final price =
                    double.tryParse(service['price'].toString()) ?? 0.0;
                final discount =
                    double.tryParse((service['discount'] ?? 0.0).toString()) ??
                        0.0;
                final serviceDiscount = price * (discount / 100);
                //service discount
                // totalServiceDiscount += serviceDiscount;

                print('Service: ${service['serviceName']}');
                print(
                    'Price: ₹$price, Discount: $discount%, Discount Amount: ₹$serviceDiscount');

                if (service['products'] != null) {
                  service['products'].forEach((product) {
                    final productPrice =
                        double.tryParse(product['productPrice'].toString()) ??
                            0.0;
                    final productDiscount = double.tryParse(
                            (product['productDiscount'] ?? 0.0).toString()) ??
                        0.0;
                    final productDiscountAmount =
                        productPrice * (productDiscount / 100);
                    totalProductDiscount += productDiscountAmount;

                    print('Product: ${product['productName']}');
                    print(
                        'Product Price: ₹$productPrice, Product Discount: $productDiscount%, Discount Amount: ₹$productDiscountAmount');
                  });
                }
              }
            });

            print(
                'Total Service Discount: ₹${totalServiceDiscount.toStringAsFixed(2)}');
            print(
                'Total Product Discount: ₹${totalProductDiscount.toStringAsFixed(2)}');

            // Apply service and product discounts to subtotal
            double discountedSubtotal =
                subtotal - totalServiceDiscount - totalProductDiscount;

            // Apply member discounts if applicable
            double memberServiceDiscount = _isMember ? serviceDiscount : 0.0;
            double memberProductDiscount = _isMember ? productDiscount : 0.0;
            discountedSubtotal -= memberServiceDiscount;
            discountedSubtotal -= memberProductDiscount;

            print(
                'Discounted Subtotal after Member Discounts: ₹${discountedSubtotal.toStringAsFixed(2)}');

            // Gift card logic
            double giftCardDiscount = 0.0;
            bool isGiftCardApplied = false;
            String giftCardStatusMessage = '';

            if (giftCardMinAmount != null && giftCardDiscountAmount != null) {
              final giftCardMinAmountDouble =
                  double.tryParse(giftCardMinAmount) ?? 0.0;
              final giftCardDiscountAmountDouble =
                  double.tryParse(giftCardDiscountAmount) ?? 0.0;

              if (discountedSubtotal >= giftCardMinAmountDouble) {
                // Subtotal meets or exceeds the minimum amount, apply the required gift card discount
                if (discountedSubtotal <= giftCardDiscountAmountDouble) {
                  // Subtotal is less than or equal to the gift card amount, use subtotal
                  giftCardDiscount = discountedSubtotal;
                } else {
                  // Subtotal is greater than the gift card discount amount, use full discount amount
                  giftCardDiscount = giftCardDiscountAmountDouble;
                }
                isGiftCardApplied = true;
                giftCardStatusMessage =
                    'Gift Card Applied: ₹${giftCardDiscount.toStringAsFixed(2)} used from the gift card balance.';
              } else {
                // Subtotal does not meet the minimum required amount, no gift card applied
                giftCardDiscount = 0.0;
                isGiftCardApplied = false;
                giftCardStatusMessage =
                    'Gift Card not applied due to insufficient subtotal.';
              }
            }

// Apply the gift card discount to subtotal
            double adjustedSubtotal = discountedSubtotal - giftCardDiscount;
            print(
                'Adjusted Subtotal after Gift Card: ₹${adjustedSubtotal.toStringAsFixed(2)}');

// Apply reward discount to adjusted subtotal
            double totalAmount = adjustedSubtotal - rewardDiscount;
            print(
                'Total Amount after Reward Discount: ₹${totalAmount.toStringAsFixed(2)}');

            bool isCouponApplied = false;
            String couponStatusMessage = '';

            // Check if any service has a package
            bool hasPackage = _mergeServiceData().values.any((service) =>
                service != null &&
                service.containsKey('packageName') &&
                service['packageName'] != null);

            if (!hasPackage && minimumAmount != null && offeredPrice != null) {
              final minimumAmountDouble = double.tryParse(minimumAmount) ?? 0.0;
              final offeredPriceDouble = double.tryParse(offeredPrice) ?? 0.0;

              if (totalAmount >= minimumAmountDouble) {
                double couponDiscount = offeredPriceDouble;
                totalAmount -= couponDiscount;
                isCouponApplied = true;
                couponStatusMessage =
                    'Coupon Applied: ₹${couponDiscount.toStringAsFixed(2)} off';
              } else {
                couponStatusMessage =
                    'Coupon Not Applied: Total amount ₹${totalAmount.toStringAsFixed(2)} is less than minimum required ₹${minimumAmountDouble.toStringAsFixed(2)}';
              }
            } else {
              couponStatusMessage = hasPackage
                  ? 'Offers, coupons, and gift cards can\'t be applied due to package inclusion.'
                  : '';
            }

            return Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: CustomColors.backgroundPrimary,
                      // borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Box for Name, Booking Date, and Booking Hours
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors
                                    .transparent), // Set border color to transparent
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors
                                .white, // Set container background color to white
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTextRow('Name', fullName, isBold: true),
                              SizedBox(height: 8),
                              buildTextRow('Booking Date:', bookingDate),
                              SizedBox(height: 8),
                              buildTextRow('Booking Hours:', bookingTime),
                            ],
                          ),
                        ),

                        SizedBox(height: 16), // Space between boxes

                        // Box for services and other details
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors
                                    .transparent), // Set border color to transparent
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors
                                .white, // Set container background color to white
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._mergeServiceData().values.map((service) {
                                if (service != null) {
                                  final serviceName = service['serviceName'] ??
                                      'No Service Available';
                                  final price = double.tryParse(
                                          service['price'].toString()) ??
                                      0.0;
                                  final discount = double.tryParse(
                                          (service['discount'] ?? 0.0)
                                              .toString()) ??
                                      0.0;

                                  double discountAmount = 0.0;
                                  String discountDisplay = '';

                                  // Debug prints
                                  print(
                                      'Before Conditional Check: Global Discount Type = $globalDiscountType');
                                  print('Service Discount Value: $discount');

                                  // Check the global discount type
                                  if (globalDiscountType == 1) {
                                    // Flat discount logic
                                    if (discount > 0) {
                                      discountAmount =
                                          discount; // Use flat discount amount directly
                                      discountDisplay =
                                          'Flat Discount: ₹${discountAmount.toStringAsFixed(2)}';
                                      print('Discount Type: Flat');
                                      print(
                                          'Discount Amount: ₹${discountAmount.toStringAsFixed(2)}');
                                    }
                                  } else if (globalDiscountType == 0) {
                                    // Percentage discount logic
                                    if (discount > 0) {
                                      discountAmount = price *
                                          (discount /
                                              100); // Calculate percentage discount
                                      discountDisplay =
                                          '(-${discount}%) - ₹${(price - discountAmount).toStringAsFixed(2)}';
                                      print('Discount Type: Percentage');
                                      print(
                                          'Discount Percentage: ${discount}%');
                                      print(
                                          'Discount Amount: ₹${discountAmount.toStringAsFixed(2)}');
                                    }
                                  }

                                  final discountedPrice = price -
                                      discountAmount; // Final price after discount
                                  print(
                                      'Final Discounted Price: ₹${discountedPrice.toStringAsFixed(2)}');
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (service
                                                .containsKey('packageName') &&
                                            service['packageName'] != null)
                                          buildTextRow(
                                              'Package: ${service['packageName']}',
                                              ''),
                                        buildTextRow(
                                          '$serviceName',
                                          '₹${discountedPrice.toStringAsFixed(2)} ${globalDiscountType == 1 && discount > 0 ? discountDisplay : ''}',
                                          valueColor: discount > 0
                                              ? Colors.red
                                              : Colors.black,
                                          isBold: discount > 0,
                                        ),
                                        if (service
                                            .containsKey('offer_description'))
                                          // buildTextRow(
                                          //   'Offer Applied:',
                                          //   '${service['offer_description'] ?? 'No Offer'} ${discount > 0 ? (globalDiscountType == 1 ? '(Flat Discount: ₹${discountAmount.toStringAsFixed(2)})' : '(-${discount}%)') : ''}',
                                          //   valueColor: Colors.green,
                                          // ),
                                          buildTextRow(
                                            'Offer Applied:',
                                            ' ${discount > 0 ? globalOfferDetails : ''}', // Use globalOfferDetails
                                            valueColor: Colors.green,
                                          ),
                                        if (service.containsKey('products') &&
                                            service['products'] != null &&
                                            service['products'].isNotEmpty)
                                          ...service['products'].map((product) {
                                            // Product discount logic
                                            final productName =
                                                product['productName'] ??
                                                    'No Product Name';
                                            final productPrice =
                                                double.tryParse(
                                                        product['productPrice']
                                                            .toString()) ??
                                                    0.0;
                                            final productDiscount =
                                                double.tryParse((product[
                                                                'productDiscount'] ??
                                                            0.0)
                                                        .toString()) ??
                                                    0.0;

                                            double productDiscountAmount = 0.0;
                                            String productDiscountDisplay = '';

                                            // Debug prints for product discounts
                                            print(
                                                'Global Discount Type for Product: $globalDiscountType');

                                            if (globalDiscountType == 1) {
                                              // Flat discount calculation for products
                                              if (productDiscount > 0) {
                                                productDiscountAmount =
                                                    productDiscount; // Use flat discount amount directly
                                                productDiscountDisplay =
                                                    'Flat Discount: ₹${productDiscountAmount.toStringAsFixed(2)}';
                                                print(
                                                    'Product Discount Type: Flat');
                                                print(
                                                    'Product Discount Amount: ₹${productDiscountAmount.toStringAsFixed(2)}');
                                              }
                                            } else if (globalDiscountType ==
                                                0) {
                                              // Percentage discount calculation for products
                                              if (productDiscount > 0) {
                                                productDiscountAmount =
                                                    productPrice *
                                                        (productDiscount /
                                                            100); // Calculate percentage discount
                                                productDiscountDisplay =
                                                    '(-${productDiscount}%) - ₹${(productPrice - productDiscountAmount).toStringAsFixed(2)}';
                                                print(
                                                    'Product Discount Type: Percentage');
                                                print(
                                                    'Product Discount Percentage: ${productDiscount}%');
                                                print(
                                                    'Product Discount Amount: ₹${productDiscountAmount.toStringAsFixed(2)}');
                                              }
                                            }

                                            final productDiscountedPrice =
                                                productPrice -
                                                    productDiscountAmount;

                                            return buildTextRow(
                                              'Product: $productName',
                                              '₹${productDiscountedPrice.toStringAsFixed(2)} ${globalDiscountType == 1 && productDiscount > 0 ? productDiscountDisplay : ''}',
                                            );
                                          }).toList(),
                                      ],
                                    ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              }).toList(),
                              Divider(height: 32, color: Colors.grey[300]),
                              buildTextRowWithDivider('Sub Total',
                                  '₹${subtotal.toStringAsFixed(2)}'),
                              // if (totalServiceDiscount > 0) ...[
                              //   SizedBox(height: 8),
                              //   buildTextRowWithDivider(
                              //     'Service Discount',
                              //     '-₹${totalServiceDiscount.toStringAsFixed(2)}',
                              //     valueColor: Colors.red,
                              //   ),
                              // ],
                              if (totalProductDiscount > 0) ...[
                                SizedBox(height: 8),
                                buildTextRowWithDivider(
                                  'Product Discount',
                                  '-₹${totalProductDiscount.toStringAsFixed(2)}',
                                  valueColor: Colors.red,
                                ),
                              ],
                              if (isGiftCardApplied) ...[
                                SizedBox(height: 8),
                                buildTextRowWithDivider(
                                  'Gift Card Discount',
                                  '-₹${giftCardDiscount.toStringAsFixed(2)}',
                                  valueColor: Colors.red,
                                ),
                              ],
                              if (_isMember &&
                                  (serviceDiscount != 0.0 ||
                                      productDiscount != 0.0)) ...[
                                SizedBox(height: 8),
                                buildTextRowWithDivider(
                                  'Member Service Discount (${discountType == 1 ? '₹${serviceDiscount.toStringAsFixed(2)} off' : '${serviceDiscountPercentage.toStringAsFixed(1)}% Discount'})',
                                  '-₹${serviceDiscount.toStringAsFixed(2)}',
                                  valueColor: CustomColors.backgroundtext,
                                ),
                                SizedBox(height: 8),
                                // Only show the product discount row if productDiscount is greater than 0
                                if (productDiscount > 0.0) ...[
                                  buildTextRowWithDivider(
                                    'Member Product Discount (${discountType == 1 ? '₹${productDiscount.toStringAsFixed(2)} off' : '${productDiscountPercentage.toStringAsFixed(1)}% Discount'})',
                                    '-₹${productDiscount.toStringAsFixed(2)}',
                                    valueColor: CustomColors.backgroundtext,
                                  ),
                                ],
                              ],

                              if (rewardDiscount > 0) ...[
                                SizedBox(height: 8),
                                buildTextRowWithDivider(
                                  'Reward Discount',
                                  '-₹${rewardDiscount.toStringAsFixed(2)}',
                                  valueColor: Colors.red,
                                ),
                              ],
                              if (couponStatusMessage.isNotEmpty) ...[
                                SizedBox(height: 8),
                                buildTextRowWithDivider(
                                  'Coupon Status',
                                  couponStatusMessage,
                                  valueColor: isCouponApplied
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                              // Divider(height: 32, color: Colors.grey[300]),
                              buildTextRow(
                                'Total',
                                '₹${totalAmount.toStringAsFixed(2)}',
                                isBold: true,
                              ),
                              SizedBox(height: 10),
                              buildTextRow(
                                'GST ($gstPercent%)',
                                '₹${(totalAmount * gstPercent / 100).toStringAsFixed(2)}', // GST amount only
                                isBold: true,
                              ),
                              Divider(thickness: 1, color: Colors.grey),
                              SizedBox(height: 10),
                              buildTextRow(
                                'Grand Total',
                                '₹${(() {
                                  grandTotal = totalAmount +
                                      (totalAmount *
                                          gstPercent /
                                          100); // Calculate and store in global variable
                                  return grandTotal.toStringAsFixed(
                                      2); // Return the formatted value
                                })()}',
                                isBold: true,
                              ),

                              if (giftCardStatusMessage.isNotEmpty) ...[
                                SizedBox(height: 8),
                                buildTextRowWithDivider(
                                  'Gift Card Status',
                                  giftCardStatusMessage,
                                  valueColor: isGiftCardApplied
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                              // Divider(height: 32, color: Colors.grey[300]),
                              // buildTextRowWithDivider(
                              //   'Stylists Assigned',
                              //   _stylistsData != null &&
                              //           _stylistsData!.isNotEmpty
                              //       ? _formatStylistsData(_stylistsData!)
                              //       : 'No stylists assigned',
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors
                                    .transparent), // Set border color to transparent
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors
                                .white, // Set container background color to white
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row for "Services" and "Specialist" labels
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .start, // Aligning to start of row
                                children: [
                                  Text(
                                    'Stylists and Services',
                                    style: GoogleFonts.lato(
                                      fontSize: 18.0,
                                      fontWeight:
                                          FontWeight.w500, // Regular weight
                                      height: 1.2,
                                      letterSpacing: 0.02,
                                      color: Color(0xFF424752),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),

                              // Table-like structure for stylist and services
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: selectedData.isNotEmpty
                                    ? Column(
                                        children:
                                            _groupStylistServices(selectedData),
                                      )
                                    : Center(
                                        child:
                                            Text('No stylist data available')),
                              ),
                            ],
                          ),
                        )

                        // Container(
                        //   padding: const EdgeInsets.all(16.0),
                        //   decoration: BoxDecoration(
                        //     border: Border.all(
                        //         color: Colors
                        //             .transparent), // Set border color to transparent
                        //     borderRadius: BorderRadius.circular(8.0),
                        //     color: Colors
                        //         .white, // Set container background color to white
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       // Add a separate Text widget for the "Specialist" label
                        //       Padding(
                        //         padding:
                        //             const EdgeInsets.symmetric(vertical: 4.0),
                        //         child: Text(
                        //           'Specialist',
                        //           style: GoogleFonts.lato(
                        //             fontSize: 16.0,
                        //             fontWeight:
                        //                 FontWeight.w400, // Regular weight
                        //             height:
                        //                 1.2, // Equivalent to line-height of 19.2px (16px * 1.2)
                        //             letterSpacing: 0.02, // Letter spacing in em
                        //             color: Color(0xFF424752), // Hex color code
                        //           ),
                        //           textAlign:
                        //               TextAlign.left, // Align text to the left
                        //         ),
                        //       ),

                        //       // Keep the existing buildTextRowWith function for the stylist data
                        //       buildTextRowWith(
                        //         '',
                        //         _stylistsData != null &&
                        //                 _stylistsData!.isNotEmpty
                        //             ? '${_formatStylistsData(_stylistsData!)}\n'
                        //                 '(${_mergeServiceData().values.map((service) {
                        //                       if (service != null) {
                        //                         return service['serviceName'] ??
                        //                             'No Service Available';
                        //                       }
                        //                       return null;
                        //                     }).where((name) => name != null).join(', ')})'
                        //             : 'No stylists assigned',
                        //       ),
                        //       // Collect service names
                        //       // if (_mergeServiceData().isNotEmpty)
                        //       //   Padding(
                        //       //     padding:
                        //       //         const EdgeInsets.symmetric(vertical: 4.0),
                        //       //     child: buildTextRow(
                        //       //       'Services: ${_mergeServiceData().values.map((service) {
                        //       //             if (service != null) {
                        //       //               return service['serviceName'] ??
                        //       //                   'No Service Available';
                        //       //             }
                        //       //             return null;
                        //       //           }).where((name) => name != null).join(', ')}',
                        //       //       '',
                        //       //       // You can leave this empty since you want to omit other details
                        //       //     ),
                        //       //   ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Widget _buildReviewSummary() {
  //   return FutureBuilder<String>(
  //     future: _getFullNameFromPreferences(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       }

  //       if (snapshot.hasError) {
  //         return Center(child: Text('Error: ${snapshot.error}'));
  //       }

  //       String fullName = snapshot.data ?? 'Test Saloon';

  //       Future<Map<String, String?>> _fetchCouponData() async {
  //         final prefs = await SharedPreferences.getInstance();
  //         final minimumAmount = prefs.getString('minimum_amount');
  //         final offeredPrice = prefs.getString('offered_price');
  //         return {
  //           'minimumAmount': minimumAmount,
  //           'offeredPrice': offeredPrice,
  //         };
  //       }

  //       Future<Map<String, String?>> _fetchGiftCardData() async {
  //         final prefs = await SharedPreferences.getInstance();
  //         final minAmount = prefs.getString('giftcard_min_amount');
  //         final discountAmount = prefs.getString('giftcard_discount_amount');
  //         return {
  //           'minAmount': minAmount,
  //           'discountAmount': discountAmount,
  //         };
  //       }

  //       Future<double> _fetchRewardDiscount() async {
  //         final prefs = await SharedPreferences.getInstance();
  //         final rewardDiscount =
  //             prefs.getDouble('discount_amount_rewards') ?? 0.0;
  //         return rewardDiscount;
  //       }

  //       return FutureBuilder<Map<String, dynamic>>(
  //         future: Future.wait([
  //           _fetchCouponData(),
  //           _fetchGiftCardData(),
  //           _fetchRewardDiscount()
  //         ]).then((results) {
  //           return {
  //             'coupon': results[0],
  //             'giftCard': results[1],
  //             'rewardDiscount': results[2],
  //           };
  //         }),
  //         builder: (context, snapshot) {
  //           if (snapshot.connectionState == ConnectionState.waiting) {
  //             return Center(child: CircularProgressIndicator());
  //           }

  //           if (snapshot.hasError) {
  //             return Center(child: Text('Error: ${snapshot.error}'));
  //           }

  //           final couponData = snapshot.data?['coupon'] ?? {};
  //           final giftCardData = snapshot.data?['giftCard'] ?? {};
  //           final rewardDiscount = snapshot.data?['rewardDiscount'] ?? 0.0;

  //           final minimumAmount = couponData['minimumAmount'];
  //           final offeredPrice = couponData['offeredPrice'];

  //           final giftCardMinAmount = giftCardData['minAmount'];
  //           final giftCardDiscountAmount = giftCardData['discountAmount'];

  //           double subtotal = _calculateSubtotal();
  //           print('Initial Subtotal: ₹${subtotal.toStringAsFixed(2)}');

  //           // Service and product discounts
  //           double totalServiceDiscount = 0.0;
  //           double totalProductDiscount = 0.0;

  //           // Calculate total service and product discounts
  //           _mergeServiceData().values.forEach((service) {
  //             if (service != null) {
  //               final price =
  //                   double.tryParse(service['price'].toString()) ?? 0.0;
  //               final discount =
  //                   double.tryParse((service['discount'] ?? 0.0).toString()) ??
  //                       0.0;
  //               final serviceDiscount = price * (discount / 100);
  //               totalServiceDiscount += serviceDiscount;

  //               print('Service: ${service['serviceName']}');
  //               print(
  //                   'Price: ₹$price, Discount: $discount%, Discount Amount: ₹$serviceDiscount');

  //               if (service['products'] != null) {
  //                 service['products'].forEach((product) {
  //                   final productPrice =
  //                       double.tryParse(product['productPrice'].toString()) ??
  //                           0.0;
  //                   final productDiscount = double.tryParse(
  //                           (product['productDiscount'] ?? 0.0).toString()) ??
  //                       0.0;
  //                   final productDiscountAmount =
  //                       productPrice * (productDiscount / 100);
  //                   totalProductDiscount += productDiscountAmount;

  //                   print('Product: ${product['productName']}');
  //                   print(
  //                       'Product Price: ₹$productPrice, Product Discount: $productDiscount%, Discount Amount: ₹$productDiscountAmount');
  //                 });
  //               }
  //             }
  //           });

  //           print(
  //               'Total Service Discount: ₹${totalServiceDiscount.toStringAsFixed(2)}');
  //           print(
  //               'Total Product Discount: ₹${totalProductDiscount.toStringAsFixed(2)}');

  //           // Apply service and product discounts to subtotal
  //           double discountedSubtotal =
  //               subtotal - totalServiceDiscount - totalProductDiscount;

  //           // Apply member discounts if applicable
  //           double memberServiceDiscount = _isMember ? serviceDiscount : 0.0;
  //           double memberProductDiscount = _isMember ? productDiscount : 0.0;
  //           discountedSubtotal -= memberServiceDiscount;
  //           discountedSubtotal -= memberProductDiscount;

  //           print(
  //               'Discounted Subtotal after Member Discounts: ₹${discountedSubtotal.toStringAsFixed(2)}');

  //           // Gift card logic
  //           double giftCardDiscount = 0.0;
  //           bool isGiftCardApplied = false;
  //           String giftCardStatusMessage = '';

  //           if (giftCardMinAmount != null && giftCardDiscountAmount != null) {
  //             final giftCardMinAmountDouble =
  //                 double.tryParse(giftCardMinAmount) ?? 0.0;
  //             final giftCardDiscountAmountDouble =
  //                 double.tryParse(giftCardDiscountAmount) ?? 0.0;

  //             if (discountedSubtotal >= giftCardMinAmountDouble) {
  //               giftCardDiscount = giftCardDiscountAmountDouble;
  //               isGiftCardApplied = true;
  //               giftCardStatusMessage =
  //                   'Gift Card Applied: ₹${giftCardDiscount.toStringAsFixed(2)} off';
  //             } else {
  //               giftCardStatusMessage =
  //                   'Gift Card Not Applied: Subtotal ₹${discountedSubtotal.toStringAsFixed(2)} is less than minimum required ₹${giftCardMinAmountDouble.toStringAsFixed(2)}';
  //             }
  //           }

  //           // Apply gift card discount to subtotal
  //           double adjustedSubtotal = discountedSubtotal - giftCardDiscount;
  //           print(
  //               'Adjusted Subtotal after Gift Card: ₹${adjustedSubtotal.toStringAsFixed(2)}');

  //           // Apply reward discount to adjusted subtotal
  //           double totalAmount = adjustedSubtotal - rewardDiscount;
  //           print(
  //               'Total Amount after Reward Discount: ₹${totalAmount.toStringAsFixed(2)}');

  //           bool isCouponApplied = false;
  //           String couponStatusMessage = '';

  //           // Check if any service has a package
  //           bool hasPackage = _mergeServiceData().values.any((service) =>
  //               service != null &&
  //               service.containsKey('packageName') &&
  //               service['packageName'] != null);

  //           if (!hasPackage && minimumAmount != null && offeredPrice != null) {
  //             final minimumAmountDouble = double.tryParse(minimumAmount) ?? 0.0;
  //             final offeredPriceDouble = double.tryParse(offeredPrice) ?? 0.0;

  //             if (totalAmount >= minimumAmountDouble) {
  //               double couponDiscount = offeredPriceDouble;
  //               totalAmount -= couponDiscount;
  //               isCouponApplied = true;
  //               couponStatusMessage =
  //                   'Coupon Applied: ₹${couponDiscount.toStringAsFixed(2)} off';
  //             } else {
  //               couponStatusMessage =
  //                   'Coupon Not Applied: Total amount ₹${totalAmount.toStringAsFixed(2)} is less than minimum required ₹${minimumAmountDouble.toStringAsFixed(2)}';
  //             }
  //           } else {
  //             couponStatusMessage = hasPackage
  //                 ? 'Offers, coupons, and gift cards can\'t be applied due to package inclusion.'
  //                 : '';
  //           }

  //           return Padding(
  //             padding: const EdgeInsets.all(2),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: CustomColors.backgroundPrimary,
  //                     // borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   padding: EdgeInsets.all(8),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // Box for Name, Booking Date, and Booking Hours
  //                       Container(
  //                         padding: const EdgeInsets.all(16.0),
  //                         decoration: BoxDecoration(
  //                           border: Border.all(
  //                               color: Colors
  //                                   .transparent), // Set border color to transparent
  //                           borderRadius: BorderRadius.circular(8.0),
  //                           color: Colors
  //                               .white, // Set container background color to white
  //                         ),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             buildTextRow('Name', fullName, isBold: true),
  //                             SizedBox(height: 8),
  //                             buildTextRow('Booking Date:', bookingDate),
  //                             SizedBox(height: 8),
  //                             buildTextRow('Booking Hours:', bookingTime),
  //                           ],
  //                         ),
  //                       ),

  //                       SizedBox(height: 16), // Space between boxes

  //                       // Box for services and other details
  //                       Container(
  //                         padding: const EdgeInsets.all(16.0),
  //                         decoration: BoxDecoration(
  //                           border: Border.all(
  //                               color: Colors
  //                                   .transparent), // Set border color to transparent
  //                           borderRadius: BorderRadius.circular(8.0),
  //                           color: Colors
  //                               .white, // Set container background color to white
  //                         ),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             ..._mergeServiceData().values.map((service) {
  //                               if (service != null) {
  //                                 final serviceName = service['serviceName'] ??
  //                                     'No Service Available';
  //                                 final price = double.tryParse(
  //                                         service['price'].toString()) ??
  //                                     0.0;
  //                                 final discount = double.tryParse(
  //                                         (service['discount'] ?? 0.0)
  //                                             .toString()) ??
  //                                     0.0;
  //                                 final discountAmount =
  //                                     (price * (discount / 100))
  //                                         .toStringAsFixed(2);

  //                                 return Padding(
  //                                   padding: const EdgeInsets.symmetric(
  //                                       vertical: 4.0),
  //                                   child: Column(
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.start,
  //                                     children: [
  //                                       if (service
  //                                               .containsKey('packageName') &&
  //                                           service['packageName'] != null)
  //                                         buildTextRow(
  //                                             'Package: ${service['packageName']}',
  //                                             ''),
  //                                       buildTextRow(
  //                                         '$serviceName',
  //                                         '₹${price.toStringAsFixed(2)} ${discount > 0 ? '(-${discount}%)\n = ₹$discountAmount' : ''}',
  //                                         valueColor: discount > 0
  //                                             ? Colors.red
  //                                             : Colors.black,
  //                                         isBold: discount > 0,
  //                                       ),
  //                                       if (service
  //                                           .containsKey('offer_description'))
  //                                         buildTextRow(
  //                                           'Offer Applied:',
  //                                           '${service['offer_description'] ?? 'No Offer'} ${discount > 0 ? '(${discount}%)' : ''}',
  //                                           valueColor: Colors.green,
  //                                         ),
  //                                       if (service.containsKey('products') &&
  //                                           service['products'] != null &&
  //                                           service['products'].isNotEmpty)
  //                                         ...service['products'].map((product) {
  //                                           final productName =
  //                                               product['productName'] ??
  //                                                   'No Product Name';
  //                                           final productPrice =
  //                                               double.tryParse(
  //                                                       product['productPrice']
  //                                                           .toString()) ??
  //                                                   0.0;
  //                                           final productDiscount =
  //                                               double.tryParse((product[
  //                                                               'productDiscount'] ??
  //                                                           0.0)
  //                                                       .toString()) ??
  //                                                   0.0;
  //                                           final productDiscountAmount =
  //                                               productPrice *
  //                                                   (productDiscount / 100);
  //                                           return buildTextRow(
  //                                             'Product: $productName',
  //                                             '₹${productPrice.toStringAsFixed(2)} ${productDiscount > 0 ? '(-${productDiscount}%) - ₹${productDiscountAmount.toStringAsFixed(2)}' : ''}',
  //                                           );
  //                                         }).toList(),
  //                                     ],
  //                                   ),
  //                                 );
  //                               } else {
  //                                 return SizedBox.shrink();
  //                               }
  //                             }).toList(),
  //                             Divider(height: 32, color: Colors.grey[300]),
  //                             buildTextRowWithDivider('Sub Total',
  //                                 '₹${subtotal.toStringAsFixed(2)}'),
  //                             if (totalServiceDiscount > 0) ...[
  //                               SizedBox(height: 8),
  //                               buildTextRowWithDivider(
  //                                 'Service Discount',
  //                                 '-₹${totalServiceDiscount.toStringAsFixed(2)}',
  //                                 valueColor: Colors.red,
  //                               ),
  //                             ],
  //                             if (totalProductDiscount > 0) ...[
  //                               SizedBox(height: 8),
  //                               buildTextRowWithDivider(
  //                                 'Product Discount',
  //                                 '-₹${totalProductDiscount.toStringAsFixed(2)}',
  //                                 valueColor: Colors.red,
  //                               ),
  //                             ],
  //                             if (isGiftCardApplied) ...[
  //                               SizedBox(height: 8),
  //                               buildTextRowWithDivider(
  //                                 'Gift Card Discount',
  //                                 '-₹${giftCardDiscount.toStringAsFixed(2)}',
  //                                 valueColor: Colors.red,
  //                               ),
  //                             ],
  //                             if (_isMember &&
  //                                 (serviceDiscount != 0.0 ||
  //                                     productDiscount != 0.0)) ...[
  //                               SizedBox(height: 8),
  //                               buildTextRowWithDivider(
  //                                 'Member Service Discount (${discountType == 1 ? '₹${serviceDiscount.toStringAsFixed(2)} off' : '${serviceDiscountPercentage.toStringAsFixed(1)}% Discount'})',
  //                                 '-₹${serviceDiscount.toStringAsFixed(2)}',
  //                                 valueColor: CustomColors.backgroundtext,
  //                               ),
  //                               SizedBox(height: 8),
  //                               // Only show the product discount row if productDiscount is greater than 0
  //                               if (productDiscount > 0.0) ...[
  //                                 buildTextRowWithDivider(
  //                                   'Member Product Discount (${discountType == 1 ? '₹${productDiscount.toStringAsFixed(2)} off' : '${productDiscountPercentage.toStringAsFixed(1)}% Discount'})',
  //                                   '-₹${productDiscount.toStringAsFixed(2)}',
  //                                   valueColor: CustomColors.backgroundtext,
  //                                 ),
  //                               ],
  //                             ],

  //                             if (rewardDiscount > 0) ...[
  //                               SizedBox(height: 8),
  //                               buildTextRowWithDivider(
  //                                 'Reward Discount',
  //                                 '-₹${rewardDiscount.toStringAsFixed(2)}',
  //                                 valueColor: Colors.red,
  //                               ),
  //                             ],
  //                             // Divider(height: 32, color: Colors.grey[300]),
  //                             buildTextRow(
  //                               'Total',
  //                               '₹${totalAmount.toStringAsFixed(2)}',
  //                               isBold: true,
  //                             ),
  //                             // if (couponStatusMessage.isNotEmpty) ...[
  //                             //   SizedBox(height: 8),
  //                             //   buildTextRowWithDivider(
  //                             //     'Coupon Status',
  //                             //     couponStatusMessage,
  //                             //     valueColor: isCouponApplied
  //                             //         ? Colors.green
  //                             //         : Colors.red,
  //                             //   ),
  //                             // ],
  //                             if (giftCardStatusMessage.isNotEmpty) ...[
  //                               SizedBox(height: 8),
  //                               buildTextRowWithDivider(
  //                                 'Gift Card Status',
  //                                 giftCardStatusMessage,
  //                                 valueColor: isGiftCardApplied
  //                                     ? Colors.green
  //                                     : Colors.red,
  //                               ),
  //                             ],
  //                             // Divider(height: 32, color: Colors.grey[300]),
  //                             // buildTextRowWithDivider(
  //                             //   'Stylists Assigned',
  //                             //   _stylistsData != null &&
  //                             //           _stylistsData!.isNotEmpty
  //                             //       ? _formatStylistsData(_stylistsData!)
  //                             //       : 'No stylists assigned',
  //                             // ),
  //                           ],
  //                         ),
  //                       ),
  //                       SizedBox(height: 10),
  //                       // Container(
  //                       //   padding: const EdgeInsets.all(16.0),
  //                       //   decoration: BoxDecoration(
  //                       //     border: Border.all(
  //                       //         color: Colors
  //                       //             .transparent), // Set border color to transparent
  //                       //     borderRadius: BorderRadius.circular(8.0),
  //                       //     color: Colors
  //                       //         .white, // Set container background color to white
  //                       //   ),
  //                       //   child: Column(
  //                       //     crossAxisAlignment: CrossAxisAlignment.start,
  //                       //     children: [
  //                       //       // Add a separate Text widget for the "Specialist" label
  //                       //       Padding(
  //                       //         padding:
  //                       //             const EdgeInsets.symmetric(vertical: 4.0),
  //                       //         child: Text(
  //                       //           'Specialist',
  //                       //           style: GoogleFonts.lato(
  //                       //             fontSize: 16.0,
  //                       //             fontWeight:
  //                       //                 FontWeight.w400, // Regular weight
  //                       //             height:
  //                       //                 1.2, // Equivalent to line-height of 19.2px (16px * 1.2)
  //                       //             letterSpacing: 0.02, // Letter spacing in em
  //                       //             color: Color(0xFF424752), // Hex color code
  //                       //           ),
  //                       //           textAlign:
  //                       //               TextAlign.left, // Align text to the left
  //                       //         ),
  //                       //       ),
  //                       //       // Keep the existing buildTextRowWith function for the stylist data
  //                       //       buildTextRowWith(
  //                       //         '',
  //                       //         _stylistsData != null &&
  //                       //                 _stylistsData!.isNotEmpty
  //                       //             ? '${_formatStylistsData(_stylistsData!)}\n'
  //                       //                 '(${_mergeServiceData().values.map((service) {
  //                       //                       if (service != null) {
  //                       //                         return service['serviceName'] ??
  //                       //                             'No Service Available';
  //                       //                       }
  //                       //                       return null;
  //                       //                     }).where((name) => name != null).join(', ')})'
  //                       //             : 'No stylists assigned',
  //                       //       ),
  //                       //       // Collect service names
  //                       //       // if (_mergeServiceData().isNotEmpty)
  //                       //       //   Padding(
  //                       //       //     padding:
  //                       //       //         const EdgeInsets.symmetric(vertical: 4.0),
  //                       //       //     child: buildTextRow(
  //                       //       //       'Services: ${_mergeServiceData().values.map((service) {
  //                       //       //             if (service != null) {
  //                       //       //               return service['serviceName'] ??
  //                       //       //                   'No Service Available';
  //                       //       //             }
  //                       //       //             return null;
  //                       //       //           }).where((name) => name != null).join(', ')}',
  //                       //       //       '',
  //                       //       //       // You can leave this empty since you want to omit other details
  //                       //       //     ),
  //                       //       //   ),
  //                       //     ],
  //                       //   ),
  //                       // ),
  //                       Container(
  //                         padding: const EdgeInsets.all(16.0),
  //                         decoration: BoxDecoration(
  //                           border: Border.all(
  //                               color: Colors
  //                                   .transparent), // Set border color to transparent
  //                           borderRadius: BorderRadius.circular(8.0),
  //                           color: Colors
  //                               .white, // Set container background color to white
  //                         ),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             // Row for "Services" and "Specialist" labels
  //                             Row(
  //                               mainAxisAlignment: MainAxisAlignment
  //                                   .start, // Aligning to start of row
  //                               children: [
  //                                 Text(
  //                                   'Specialist and Services',
  //                                   style: GoogleFonts.lato(
  //                                     fontSize: 18.0,
  //                                     fontWeight:
  //                                         FontWeight.w500, // Regular weight
  //                                     height: 1.2,
  //                                     letterSpacing: 0.02,
  //                                     color: Color(0xFF424752),
  //                                   ),
  //                                   textAlign: TextAlign.left,
  //                                 ),
  //                               ],
  //                             ),

  //                             // Table-like structure for stylist and services
  //                             Padding(
  //                               padding:
  //                                   const EdgeInsets.symmetric(vertical: 8.0),
  //                               child: selectedData.isNotEmpty
  //                                   ? Column(
  //                                       children:
  //                                           _groupStylistServices(selectedData),
  //                                     )
  //                                   : Center(
  //                                       child:
  //                                           Text('No stylist data available')),
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  List<Widget> _groupStylistServices(List<dynamic> data) {
    Map<String, List<String>> groupedData = {};

    // Group data by stylist
    for (var item in data) {
      String stylist = item['selected_stylist'] ?? 'N/A';
      String service = item['selected_service'] ?? 'N/A';

      if (groupedData.containsKey(stylist)) {
        groupedData[stylist]!.add(service);
      } else {
        groupedData[stylist] = [service];
      }
    }

    // Generate the list of widgets to display
    List<Widget> result = [];
    groupedData.forEach((stylist, services) {
      result.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Stylist name (left side)
              Expanded(
                flex: 1,
                child: Text(
                  stylist,
                  style: GoogleFonts.lato(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424752),
                  ),
                ),
              ),
              // Services (right side)
              Expanded(
                flex: 1,
                child: Text(
                  services.join(', '),
                  style: GoogleFonts.lato(
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF7D7D7D),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return result;
  }

  Widget buildTextRowWith(String title, String value,
      {Color? valueColor, String? percentage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextRow(title, value, valueColor: valueColor),
        if (percentage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              percentage,
              style: GoogleFonts.lato(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500, // Set font weight to 500
              ),
            ),
          ),
        // Removed the Divider here
      ],
    );
  }

  Widget buildTextRow(String title, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontWeight: isBold
                  ? (title == 'Grand Total' ? FontWeight.w800 : FontWeight.w500)
                  : FontWeight
                      .normal, // Set font weight to w700 for 'Grand Total'
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lato(
              color: valueColor ?? Colors.black,
              fontWeight: isBold
                  ? (title == 'Grand Total' ? FontWeight.w700 : FontWeight.w500)
                  : FontWeight
                      .normal, // Set font weight to w700 for 'Grand Total'
              fontSize: 16,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget buildTextRowWithDivider(String label, String value,
      {Color valueColor = Colors.black, String? percentage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextRow(
          label,
          '$value${percentage != null ? ' (Percentage: $percentage%)' : ''}',
          valueColor: valueColor,
        ),
        SizedBox(height: 8),
        Divider(
          color: Color(0xFFDDDDDD),
          thickness: 1,
        ),
      ],
    );
  }
}
