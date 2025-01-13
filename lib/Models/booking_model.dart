// class Booking {
//   final String bookingId;
//   final String refId;
//   final String bookingDate;
//   final String customer;
//   final String phoneNo;
//   final String servicesText;
//   final String stylistsText;
//   bool isReminderSet;
//   final bool isReviewSubmitted;
//   final List<Service> services;
//   double get totalPrice => services.fold(
//       0, (sum, service) => sum + double.parse(service.finalPrice));

//   Booking({
//     required this.bookingId,
//     required this.refId,
//     required this.bookingDate,
//     required this.customer,
//     required this.phoneNo,
//     required this.servicesText,
//     required this.stylistsText,
//     this.isReminderSet = false,
//     required this.isReviewSubmitted,
//     required this.services,
//   });

//   factory Booking.fromJson(Map<String, dynamic> json) {
//     var servicesList = json['services'] as List;
//     List<Service> services =
//         servicesList.map((i) => Service.fromJson(i)).toList();

//     return Booking(
//       bookingId: json['booking_id'] ?? '',
//       refId: json['ref_id'] ?? '',
//       bookingDate: json['booking_date'] ?? '',
//       customer: json['customer'] ?? '',
//       phoneNo: json['phone_no'] ?? '',
//       servicesText: json['services_text'] ?? '',
//       stylistsText: json['stylists_text'] ?? '',
//       isReminderSet: json['is_reminder_set'] == '1',
//       isReviewSubmitted: json['is_review_submitted'] == '1',
//       services: services,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'booking_id': bookingId,
//       'ref_id': refId,
//       'booking_date': bookingDate,
//       'customer': customer,
//       'phone_no': phoneNo,
//       'services_text': servicesText,
//       'stylists_text': stylistsText,
//       'is_reminder_set': isReminderSet ? '1' : '0',
//       'services': services.map((service) => service.toJson()).toList(),
//     };
//   }
// }

// class Service {
//   final String serviceId;
//   final String serviceDetailsId;
//   final String serviceName;
//   final String serviceNameMarathi;
//   final String stylist;
//   final String duration;
//   final String serviceFrom;
//   final String serviceTo;
//   final String image;
//   final String price;
//   final String discount;
//   final String finalPrice;
//   final String serviceAddedFrom;
//   final String serviceStatusText;
//   final String serviceStatusFlag;
//   final List<String> products;

//   Service({
//     required this.serviceId,
//     required this.serviceDetailsId,
//     required this.serviceName,
//     required this.serviceNameMarathi,
//     required this.stylist,
//     required this.duration,
//     required this.serviceFrom,
//     required this.serviceTo,
//     required this.image,
//     required this.price,
//     required this.discount,
//     required this.finalPrice,
//     required this.serviceAddedFrom,
//     required this.serviceStatusText,
//     required this.serviceStatusFlag,
//     required this.products,
//   });

//   factory Service.fromJson(Map<String, dynamic> json) {
//     var productsList = json['products'] as List;
//     List<String> products = productsList.map((i) => i.toString()).toList();

//     return Service(
//       serviceId: json['service_id'] ?? '',
//       serviceDetailsId: json['service_details_id'] ?? '',
//       serviceName: json['service_name'] ?? '',
//       serviceNameMarathi: json['service_name_marathi'] ?? '',
//       stylist: json['stylist'] ?? '',
//       duration: json['duration'] ?? '',
//       serviceFrom: json['service_from'] ?? '',
//       serviceTo: json['service_to'] ?? '',
//       image: json['image'] ?? '',
//       price: json['price'] ?? '',
//       discount: json['discount'] ?? '',
//       finalPrice: json['final_price'] ?? '',
//       serviceAddedFrom: json['service_added_from'] ?? '',
//       serviceStatusText: json['service_status_text'] ?? '',
//       serviceStatusFlag: json['service_status_flag'] ?? '',
//       products: products,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'service_id': serviceId,
//         'service_details_id': serviceDetailsId,
//         'service_name': serviceName,
//         'service_name_marathi': serviceNameMarathi,
//         'stylist': stylist,
//         'duration': duration,
//         'service_from': serviceFrom,
//         'service_to': serviceTo,
//         'image': image,
//         'price': price,
//         'discount': discount,
//         'final_price': finalPrice,
//         'service_added_from': serviceAddedFrom,
//         'service_status_text': serviceStatusText,
//         'service_status_flag': serviceStatusFlag,
//         'products': products,
//       };
// }

import 'package:intl/intl.dart';

class Booking {
  final String bookingId;
  final String refId;
  final String bookingDate;
  final String customer;
  final String phoneNo;
  final String servicesText;
  final String stylistsText;
  bool isReminderSet;
  final bool isReviewSubmitted;
  final List<Service> services;

  // Date format change: "11 Nov 23"
  String get formattedBookingDate {
    try {
      DateTime parsedDate = DateFormat("dd MMM, yyyy").parse(bookingDate);
      return DateFormat("dd MMM yy").format(parsedDate);
    } catch (e) {
      return bookingDate; // Return original if parsing fails
    }
  }

  double get totalPrice => services.fold(0, (sum, service) {
        double price =
            double.tryParse(service.price) ?? 0; // Handle invalid price values
        return sum + price;
      });

  String get servicesFrom =>
      services.isNotEmpty ? services.first.serviceFrom : '';

  Booking({
    required this.bookingId,
    required this.refId,
    required this.bookingDate,
    required this.customer,
    required this.phoneNo,
    required this.servicesText,
    required this.stylistsText,
    this.isReminderSet = false,
    required this.isReviewSubmitted,
    required this.services,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    var servicesList = json['services'] as List;
    List<Service> services =
        servicesList.map((i) => Service.fromJson(i)).toList();

    return Booking(
      bookingId: json['booking_id'] ?? '',
      refId: json['ref_id'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      customer: json['customer'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      servicesText: json['services_text'] ?? '',
      stylistsText: json['stylists_text'] ?? '',
      isReminderSet:
          (json['is_reminder_set'] == '1' || json['is_reminder_set'] == 1),
      isReviewSubmitted: json['is_review_submitted'] == '1',
      services: services,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'ref_id': refId,
      'booking_date': bookingDate,
      'customer': customer,
      'phone_no': phoneNo,
      'services_text': servicesText,
      'stylists_text': stylistsText,
      'is_reminder_set': isReminderSet ? '1' : '0',
      'services': services.map((service) => service.toJson()).toList(),
    };
  }
}

class Service {
  final String serviceId;
  final String serviceDetailsId;
  final String serviceName;
  final String serviceNameMarathi;
  final String stylist;
  final String duration;
  final String serviceFrom;
  final String serviceTo;
  final String image;
  final String price;
  final String discount;
  final String finalPrice;
  final String serviceAddedFrom;
  final String serviceStatusText;
  final String serviceStatusFlag;
  final List<String> products;

  Service({
    required this.serviceId,
    required this.serviceDetailsId,
    required this.serviceName,
    required this.serviceNameMarathi,
    required this.stylist,
    required this.duration,
    required this.serviceFrom,
    required this.serviceTo,
    required this.image,
    required this.price,
    required this.discount,
    required this.finalPrice,
    required this.serviceAddedFrom,
    required this.serviceStatusText,
    required this.serviceStatusFlag,
    required this.products,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    var productsList = json['products'] as List;
    List<String> products = productsList.map((i) => i.toString()).toList();

    return Service(
      serviceId: json['service_id'] ?? '',
      serviceDetailsId: json['service_details_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      serviceNameMarathi: json['service_name_marathi'] ?? '',
      stylist: json['stylist'] ?? '',
      duration: json['duration'] ?? '',
      serviceFrom: json['service_from'] ?? '',
      serviceTo: json['service_to'] ?? '',
      image: json['image'] ?? '',
      price: json['price']?.toString() ?? '',
      discount: json['discount'] ?? '',
      finalPrice: json['final_price'] ?? '',
      serviceAddedFrom: json['service_added_from'] ?? '',
      serviceStatusText: json['service_status_text'] ?? '',
      serviceStatusFlag: json['service_status_flag'] ?? '',
      products: products,
    );
  }

  Map<String, dynamic> toJson() => {
        'service_id': serviceId,
        'service_details_id': serviceDetailsId,
        'service_name': serviceName,
        'service_name_marathi': serviceNameMarathi,
        'stylist': stylist,
        'duration': duration,
        'service_from': serviceFrom,
        'service_to': serviceTo,
        'image': image,
        'price': price,
        'discount': discount,
        'final_price': finalPrice,
        'service_added_from': serviceAddedFrom,
        'service_status_text': serviceStatusText,
        'service_status_flag': serviceStatusFlag,
        'products': products,
      };
}
