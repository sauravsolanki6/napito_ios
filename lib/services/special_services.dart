import 'dart:convert'; // Import for jsonDecode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_salon_task/Book_appointment/book_appointment.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/My_Bookings/datetime.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:shimmer/shimmer.dart'; // Import for Shimmer

class SpecialServicesPage extends StatefulWidget {
  @override
  _SpecialServicesPageState createState() => _SpecialServicesPageState();
}

class _SpecialServicesPageState extends State<SpecialServicesPage> {
  bool isSelected = false;
  Map<int, dynamic> servicesData = {}; // Stores services data
  bool isLoading = true; // To track loading state
  String _selectedServiceDataJson = '';
  Map<int, String> serviceSources = {};

  // final Map<String, dynamic> servicesData = {}; // Your service data
  final Set<String> servicesToRemove = {}; // Services marked for removal
  @override
  void initState() {
    super.initState();
    _fetchAndPrintSelectedServices();
    printStoredData();
  }

  Future<void> _deleteService(int serviceId) async {
    // Remove the service from the local data
    setState(() {
      servicesData.remove(serviceId);
      serviceSources.remove(serviceId); // Remove from serviceSources
    });

    // Obtain the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Update the data for each relevant key in SharedPreferences
    String selectedServiceDataJson = jsonEncode(
        servicesData.map((key, value) => MapEntry(key.toString(), value)));
    await prefs.setString('selected_service_data', selectedServiceDataJson);

    String? selectedServiceDataJson1 =
        prefs.getString('selected_service_data1');
    if (selectedServiceDataJson1 != null) {
      Map<String, dynamic> selectedServiceData1 =
          jsonDecode(selectedServiceDataJson1);
      selectedServiceData1.remove(serviceId.toString());
      String updatedServiceDataJson1 = jsonEncode(selectedServiceData1);
      await prefs.setString('selected_service_data1', updatedServiceDataJson1);
    }

    String? storedData = prefs.getString('selected_package_data_add_package');
    if (storedData != null) {
      Map<String, dynamic> packageData = jsonDecode(storedData);
      List<dynamic> servicesArray = packageData['services_array'] ?? [];
      servicesArray.removeWhere(
          (service) => int.parse(service['service_id']) == serviceId);
      packageData['services_array'] = servicesArray;
      String updatedPackageDataJson = jsonEncode(packageData);
      await prefs.setString(
          'selected_package_data_add_package', updatedPackageDataJson);
    }

    // Optionally refresh data
    await _fetchAndPrintSelectedServices();
  }

  Future<void> _removeService(int serviceId) async {
    // Remove the service from the local data
    setState(() {
      servicesData.remove(serviceId);
      serviceSources.remove(serviceId); // Remove from serviceSources
    });

    // Obtain the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Update the data for each relevant key in SharedPreferences
    String selectedServiceDataJson = jsonEncode(
        servicesData.map((key, value) => MapEntry(key.toString(), value)));
    await prefs.setString('selected_service_data', selectedServiceDataJson);

    String? selectedServiceDataJson1 =
        prefs.getString('selected_service_data1');
    if (selectedServiceDataJson1 != null) {
      Map<String, dynamic> selectedServiceData1 =
          jsonDecode(selectedServiceDataJson1);
      selectedServiceData1.remove(serviceId.toString());
      String updatedServiceDataJson1 = jsonEncode(selectedServiceData1);
      await prefs.setString('selected_service_data1', updatedServiceDataJson1);
    }

    String? storedData = prefs.getString('selected_package_data_add_package');
    if (storedData != null) {
      Map<String, dynamic> packageData = jsonDecode(storedData);
      List<dynamic> servicesArray = packageData['services_array'] ?? [];
      servicesArray.removeWhere(
          (service) => int.parse(service['service_id']) == serviceId);
      packageData['services_array'] = servicesArray;
      String updatedPackageDataJson = jsonEncode(packageData);
      await prefs.setString(
          'selected_package_data_add_package', updatedPackageDataJson);
    }

    // Optionally refresh data
    await _fetchAndPrintSelectedServices();
  }

  void _removeMarkedServices() {
    final idsToRemove = servicesData.keys.where((id) {
      final service = servicesData[id];
      return servicesToRemove.contains(service['serviceName']);
    }).toList();

    for (var id in idsToRemove) {
      _removeService(
          id); // Remove service from local data and SharedPreferences
    }

    setState(() {
      servicesToRemove.clear(); // Clear after removal
    });
  }

  Future<void> printStoredData() async {
    // Obtain the SharedPreferences instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the data using the key 'selected_package_data_add_package'
    final String? storedData =
        prefs.getString('selected_package_data_add_package');

    // Check if the data is null or not, and print accordingly
    if (storedData != null) {
      print('Stored Data: $storedData');
    } else {
      print('No data found for the key "selected_package_data_add_package".');
    }
  }

  Future<void> _fetchAndPrintSelectedServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Fetch data from both keys
      String? selectedServiceDataJson1 =
          prefs.getString('selected_service_data');
      String? selectedServiceDataJson2 =
          prefs.getString('selected_service_data1');
      String? storedData = prefs.getString('selected_package_data_add_package');

      Map<int, dynamic> mergedData = {};

      if (selectedServiceDataJson1 != null) {
        Map<String, dynamic> selectedServiceData1 =
            jsonDecode(selectedServiceDataJson1);
        mergedData.addAll(
          selectedServiceData1.map(
            (key, value) => MapEntry(
              int.parse(key),
              {...value, 'source': 'selected_service_data'}, // Add source
            ),
          ),
        );
      }

      if (selectedServiceDataJson2 != null) {
        Map<String, dynamic> selectedServiceData2 =
            jsonDecode(selectedServiceDataJson2);
        mergedData.addAll(
          selectedServiceData2.map(
            (key, value) => MapEntry(
              int.parse(key),
              {...value, 'source': 'selected_service_data1'}, // Add source
            ),
          ),
        );
      }

      if (storedData != null) {
        Map<String, dynamic> packageData = jsonDecode(storedData);
        List<dynamic> servicesArray = packageData['services_array'] ?? [];

        for (var service in servicesArray) {
          int serviceId = int.parse(service['service_id']);
          mergedData[serviceId] = {
            'image': service['image'] ?? '',
            'serviceName': service['service_name'] ?? 'No Title',
            'products': service['products'] ?? [],
            'price': service['price'] ?? '0',
            'duration': service['service_duration'] ?? '0',
            'isHighlighted': true,
            'packageName': packageData['package_name'] ?? 'Unknown Package',
            'source': 'selected_package_data_add_package', // Add source
          };
        }
      }

      setState(() {
        servicesData = mergedData;
        isLoading = false; // Set loading to false once data is fetched
      });
      print('Merged Service Data: $servicesData');
    } catch (e) {
      print('Error fetching selected service data: $e');
      setState(() {
        isLoading = false; // Set loading to false on error
      });
    }
  }

  bool _canProceedToNextStep() {
    if (servicesData.isEmpty) return false;

    // Check if there are services from 'selected_service_data1'
    if (servicesData.values
        .any((service) => service['source'] == 'selected_service_data1')) {
      return true;
    }

    // Case 1: Allow if there is only one service left
    if (servicesData.length == 1) {
      return true;
    }

    // Case 2: Allow if all services come from only one source
    final uniqueSources =
        servicesData.values.map((service) => service['source']).toSet();
    return uniqueSources.length == 1;
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true; // Set loading to true to show shimmer while refreshing
    });
    await _fetchAndPrintSelectedServices(); // Fetch data again
  }

  void _toggleServiceSelection(String title, bool isSelected) {
    setState(() {
      if (isSelected) {
        servicesToRemove
            .remove(title); // Do not add to removal list if selected
      } else {
        servicesToRemove.add(title); // Add to removal list if not selected
      }
    });
  }

  void _showErrorSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: Duration(milliseconds: 1500), // Snackbar duration
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Dismiss the Snackbar after 100 milliseconds
    Future.delayed(Duration(milliseconds: 1500), () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }

  String _calculateTotalDuration() {
    int totalMinutes = 0;

    for (var service in servicesData.values) {
      if (service.containsKey('duration')) {
        var duration = service['duration'];
        if (duration is int) {
          totalMinutes += duration;
        } else if (duration is String) {
          int? durationInt = int.tryParse(duration);
          if (durationInt != null) {
            totalMinutes += durationInt;
          }
        }
      }
    }

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    // Save total minutes to SharedPreferences
    _saveTotalDuration(totalMinutes);

    if (hours > 0 && minutes > 0) {
      return '$hours hour(s) $minutes minute(s)';
    } else if (hours > 0) {
      return '$hours hour(s)';
    } else if (minutes > 0) {
      return '$minutes minute(s)';
    } else {
      return '0 minutes'; // If there are no hours or minutes
    }
  }

  Future<void> _saveTotalDuration(int totalMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_duration_minutes', totalMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to SDateTime when back button is pressed
        Navigator.pop(context);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BookAppointmentPage(),
        //   ),
        // );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        backgroundColor: CustomColors.backgroundPrimary,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: CustomColors.backgroundLight,
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to SDateTime when back button is pressed
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => BookAppointmentPage(),
                  //   ),
                  // );
                },
              ),
              Text(
                'Schedule Services',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Display total duration above the list
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal:
                      16.0), // Adjusted padding for a more minimal layout
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    10.0), // Slightly reduced border radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(
                        0.15), // Lighter shadow for a minimal effect
                    offset: Offset(0, 2), // Reduced offset for a subtler shadow
                    blurRadius: 4, // Reduced blur radius for a cleaner look
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Duration Row
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: CustomColors.backgroundtext,
                        size:
                            24, // Slightly smaller icon for a more minimalist approach
                      ),
                      SizedBox(
                          width: 8), // Reduced spacing for a more compact look
                      Expanded(
                        child: Text(
                          'Total Duration: ${_calculateTotalDuration()}',
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w600, // Bold for emphasis
                            color: CustomColors.backgroundtext,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Reduced space between rows
                  // Info Row
                  Divider(
                    color: Colors.grey[300],
                    thickness: 0.8, // Subtle divider thickness
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: CustomColors.backgroundtext,
                        size: 24, // Consistent icon size
                      ),
                      const SizedBox(width: 8), // Consistent spacing
                      Expanded(
                        child: Text(
                          'You can book or modify services later from the main menu',
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w500, // Regular weight for info text
                            color: CustomColors.backgroundtext,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: 5), // Reduced padding for a more compact layout
                  // // Decorative Divider
                  // Divider(
                  //   color: Colors.grey[300],
                  //   thickness: 0.8, // Subtle divider thickness
                  // ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: isLoading
                    ? ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: 6, // Number of skeleton items
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    offset: Offset(0, 4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            color: Colors.grey,
                                            height: 18,
                                            width: double.infinity,
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            color: Colors.grey,
                                            height: 14,
                                            width: double.infinity,
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                color: Colors.grey,
                                                height: 16,
                                                width: 60,
                                              ),
                                              Spacer(),
                                              Row(
                                                children: [
                                                  Container(
                                                    color: Colors.grey,
                                                    height: 16,
                                                    width: 60,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : servicesData.isEmpty
                        ? Center(child: Text('No Services Selected'))
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: servicesData.length,
                            itemBuilder: (context, index) {
                              final service =
                                  servicesData.values.elementAt(index);
                              final imagePath = service['image'] ?? '';
                              final title =
                                  service['serviceName'] ?? 'No Title';
                              final description = service['products'] != null &&
                                      service['products'].isNotEmpty
                                  ? 'Product Selected: ${service['products'].map((p) => p['productName'] ?? 'Unknown').join(', ')}'
                                  : 'No products';
                              final price = '₹${service['price'] ?? '0'}';
                              final duration = service.containsKey('duration')
                                  ? '${service['duration']} minutes'
                                  : 'Duration not available';
                              final isHighlighted =
                                  service.containsKey('package_id');
                              final helperText = isHighlighted
                                  ? 'This service is part of a '
                                  : '';
                              final packageName = isHighlighted
                                  ? service['packageName'] ?? 'Unknown Package'
                                  : ''; // Fetch package name from service data

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelected = !isSelected;
                                  });
                                },
                                child: HeadMassageContainer(
                                  isSelected: isSelected,
                                  isHighlighted: isHighlighted,
                                  imagePath: imagePath,
                                  title: title,
                                  description: description,
                                  price: price,
                                  duration: duration,
                                  helperText: helperText,
                                  packageName: packageName,
                                  onDelete: (title) {
                                    final serviceIdToRemove = servicesData.keys
                                        .firstWhere(
                                            (id) =>
                                                servicesData[id]
                                                    ['serviceName'] ==
                                                title,
                                            orElse: () => -1);
                                    if (serviceIdToRemove != -1) {
                                      _removeService(serviceIdToRemove);
                                    }
                                  },
                                  onMarkForRemoval: (title) {
                                    setState(() {
                                      if (servicesToRemove.contains(title)) {
                                        servicesToRemove.remove(title);
                                      } else {
                                        servicesToRemove.add(title);
                                      }
                                    });
                                  },
                                  onProductSelectionChanged:
                                      (title, isSelected) {
                                    _toggleServiceSelection(title, isSelected);
                                  },
                                  isFromSelectedServiceData1:
                                      service['source'] ==
                                          'selected_service_data1', // New line
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: CustomColors.backgroundPrimary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: CustomColors.backgroundtext, // Text color
                  backgroundColor:
                      CustomColors.backgroundPrimary, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(5), // Set border radius to 5
                    side: BorderSide(
                      color: CustomColors.backgroundtext, // Border color
                      width: 1, // Border width
                    ),
                  ),
                  padding:
                      EdgeInsets.zero, // Remove default padding to control size
                  minimumSize: Size(
                      135, 40), // Set minimum size to width 135 and height 40
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.backgroundtext, // Text color
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _removeMarkedServices();
                  if (servicesData.isEmpty) {
                    _showErrorSnackbar(
                        'No services selected. Please select a service before proceeding.');
                  } else if (!_canProceedToNextStep()) {
                    _showErrorSnackbar(
                        'You must remove services from either "Selected Package" or "Selected Service Data" to proceed.');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SDateTime()), // Adjust the destination as needed
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.backgroundtext,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(6), // Set border radius to 6
                  ),
                  padding:
                      EdgeInsets.zero, // Remove default padding to control size
                  minimumSize: Size(135,
                      40), // Set the minimum size to width 135 and height 40
                ),
                child: Text(
                  'Next Step',
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeadMassageContainer extends StatefulWidget {
  final bool isSelected;
  final bool isHighlighted;
  final String imagePath;
  final String title;
  final String description;
  final String price;
  final String duration;
  final String helperText;
  final Function(String) onDelete; // This will handle the delete action
  final String packageName;
  final Function(String) onMarkForRemoval;
  final Function(String, bool) onProductSelectionChanged;

  final bool isFromSelectedServiceData1;

  const HeadMassageContainer({
    Key? key,
    required this.isSelected,
    required this.onDelete,
    required this.isHighlighted,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.helperText,
    required this.packageName,
    required this.onMarkForRemoval,
    required this.onProductSelectionChanged,
    required this.isFromSelectedServiceData1,
  }) : super(key: key);

  @override
  _HeadMassageContainerState createState() => _HeadMassageContainerState();
}

class _HeadMassageContainerState extends State<HeadMassageContainer> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  void _toggleSelection() {
    setState(() {
      _isSelected = !_isSelected;
    });

    if (_isSelected) {
      widget.onMarkForRemoval(widget.title);
      widget.onProductSelectionChanged(widget.title, false);
    } else {
      widget.onMarkForRemoval(widget.title);
      widget.onProductSelectionChanged(widget.title, true);
    }
  }

  bool get _isBookLater => !_isSelected && !widget.isFromSelectedServiceData1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _isBookLater ? Colors.yellow[100] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            _isBookLater ? Border.all(color: Colors.yellow, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: _isSelected ? 0.5 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.imagePath.isNotEmpty
                          ? Image.network(
                              widget.imagePath,
                              width: isPortrait ? screenWidth * 0.25 : 80,
                              height: isPortrait ? screenWidth * 0.25 : 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $error');
                                return _buildPlaceholder(screenWidth);
                              },
                            )
                          : _buildPlaceholder(screenWidth),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF424752),
                                    ),
                                  ),
                                ),
                                if (widget.isFromSelectedServiceData1)
                                  TextButton(
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      widget.onDelete(widget.title);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          CustomColors.backgroundtext,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                else
                                  TextButton(
                                    child: Text(
                                      _isBookLater ? 'Book Later' : 'Book Now',
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: _toggleSelection,
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          CustomColors.backgroundtext,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 6),
                            if (_isBookLater)
                              Text(
                                'This is a package service.',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(height: 6),
                            Text(
                              widget.description,
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  widget.price,
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF424752),
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Color(0xFF7F8C8D),
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      widget.duration,
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: Color(0xFF7F8C8D),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            if (widget.helperText.isNotEmpty)
                              Text(
                                widget.helperText,
                                style: GoogleFonts.lato(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                            if (widget.packageName.isNotEmpty)
                              Text(
                                'Package: ${widget.packageName}',
                                style: GoogleFonts.lato(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(double screenWidth) {
    return Container(
      width: screenWidth * 0.25,
      height: screenWidth * 0.25,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
