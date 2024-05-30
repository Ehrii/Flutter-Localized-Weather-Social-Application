import 'package:flutter/material.dart';
import 'package:proj/colors.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class Hotline extends StatefulWidget {
  const Hotline({super.key});

  @override
  State<Hotline> createState() => _HotlineState();
}

class _HotlineState extends State<Hotline> {
  final List<HotlineItem> hotlines = [
    HotlineItem(name: 'National Emergency Hotline', number: '911'),
    HotlineItem(name: 'NDDRMC', number: '02 8911 1406'),
    HotlineItem(name: 'Philippine Red Cross', number: '143'),
    HotlineItem(name: 'Philippine National Police', number: '117'),
    HotlineItem(name: 'Bureau of Fire Protection', number: '02 8426 0219'),
    HotlineItem(name: 'Department of Health', number: '1555'),
    HotlineItem(name: 'MMDA', number: '136'),
    HotlineItem(name: 'Philippine Coast Guard', number: '0917 724 3682'),
    HotlineItem(name: 'PAG ASA', number: '02 8284 0800'),
    HotlineItem(name: 'PHIVOLCS', number: '02 8426 1488'),

    // Add more hotlines as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.greyblue,
      appBar: AppBar(
        centerTitle: false,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(10, 61, 98, 1.0),
        title: const Row(
          children: [
            Icon(Icons.emergency), // Add the desired icon here
            SizedBox(width: 10),
            Text("Emergency Hotlines"),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: hotlines.length,
        itemBuilder: (context, index) {
          final hotline = hotlines[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ColorPalette.darkblue),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.call),
                title: Text(hotline.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(hotline.number),
                onTap: () {
                  _launchPhoneCall(hotline.number);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Function to launch phone call
void _launchPhoneCall(String phoneNumber) async {
  final uri = Uri.parse('tel:$phoneNumber');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}

class HotlineItem {
  final String name;
  final String number;

  HotlineItem({required this.name, required this.number});
}
