import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:proj/colors.dart';

class FirstAid extends StatefulWidget {
  const FirstAid({Key? key}) : super(key: key);

  @override
  State<FirstAid> createState() => _FirstAidState();
}

class _FirstAidState extends State<FirstAid> {
  final List<Item> _data = generateItems();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.greyblue,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.health_and_safety), // Add the desired icon here
            SizedBox(width: 10),
            Text("First Aid and Safety"),
          ],
        ),
        centerTitle: false,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(10, 61, 98, 1.0),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200, // Adjust the height as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorPalette.darkblue.withOpacity(0.9), // Optional: Adjust the color as needed
                border: Border.all(
                    color: ColorPalette.darkblue), // Optional: Add border
              ),
              child: ClipOval(
                child: Lottie.asset(
                  'assets/firstaid.json', // Replace with your animation file path
                  width: MediaQuery.of(context).size.width,
                  height: 200, // Adjust the height as needed
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: ColorPalette.darkblue),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'This section contains tips and preventions for weather-related conditions like stroke, weather allergies, sunburn, and accidents for severe weather conditions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      color: ColorPalette.darkblue,
                    ),
                  ),
                ),
              ),
            ),
            const Text('FREQUENTLY ASKED QUESTIONS (FAQ)',style: TextStyle(fontWeight: FontWeight.bold),),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: _data.map<Widget>((Item item) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: ColorPalette.darkblue),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            item.headerValue,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.darkblue,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              item.isExpanded = !item.isExpanded;
                            });
                          },
                          trailing: Icon(
                            item.isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                        ),
                        if (item.isExpanded)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              item.expandedValue,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.045,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  String expandedValue;
  String headerValue;
  bool isExpanded;

  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });
}

List<Item> generateItems() {
  return [
    Item(
      headerValue:
          'What are the first steps to take if someone is having a stroke?',
      expandedValue:
          "➤ The first step is to call emergency services immediately. If you're experiencing stroke symptoms, have someone else make the call for you. Stay calm and wait for emergency help.\n\n➤ If you're caring for someone else, ensure they are in a safe, comfortable position, preferably lying on one side with their head slightly raised to prevent vomiting. Check if they are breathing and perform CPR if necessary. Loosen any constrictive clothing if they are having difficulty breathing. \n\n➤ Talk to them calmly and reassuringly, cover them with a blanket, and avoid giving them anything to eat or drink. Do not move them if they show any weakness in a limb. \n\n➤ Observe them closely for any changes in condition and be prepared to report their symptoms and the start time to the emergency operator.",
    ),
    Item(
      headerValue: 'What should I do if someone is showing signs of a stroke?',
      expandedValue:
          '➤ Immediate action is crucial. Call emergency services right away or have someone else do it. Knowing the signs of a stroke and taking quick action can save a life. \n\n ➤ Strokes occur when the blood supply to the brain is blocked or limited, and early intervention is key.',
    ),
    Item(
      headerValue: 'What are the main types of stroke and their causes?',
      expandedValue:
          '➤ There are two main types of stroke: ischemic and hemorrhagic. Ischemic strokes occur when blood flow to part of the brain is blocked, while hemorrhagic strokes happen when a blood vessel in the brain ruptures. \n\n ➤The causes of these strokes can vary, but they often involve issues with blood vessels, blood clots, or bleeding in the brain. ',
    ),
    Item(
      headerValue: 'What is the emergency first aid treatment for strokes?',
      expandedValue:
          "➤ The emergency first aid treatment for all types of strokes is the same. It involves calling emergency services immediately, ensuring the person is in a safe position, checking their breathing, performing CPR if necessary, and loosening any constrictive clothing to aid breathing. It's important to stay calm, talk to the person reassuringly, and cover them with a blanket.",
    ),
    Item(
      headerValue: 'How can I prepare for a stroke emergency?',
      expandedValue:
          '➤ Knowing the signs of a stroke and having a first aid kit with items like a phone, pen, and paper can be helpful. Ensure you have a clear path to the nearest emergency exit and keep a list of emergency contacts. Being prepared can help you act quickly and efficiently in an emergency situation.',
    ),
    Item(
      headerValue: 'What should I do immediately after noticing a sunburn?',
      expandedValue:
          "➤ The first step in treating a sunburn is to get out of the sun and go indoors. This helps prevent further damage to the skin. It's important to avoid harsh soaps and exfoliating the skin, as these can further irritate the sunburned area ",
    ),
    Item(
      headerValue: 'How can I relieve the pain from a sunburn?',
      expandedValue:
          "➤ To relieve the pain from a sunburn, take frequent cool baths or showers. After bathing, gently pat yourself dry but leave your skin slightly damp to help trap moisture. Applying a moisturizer that contains aloe vera or soy can help soothe the skin. Avoid petroleum-based moisturizers as they can trap heat and worsen the sunburn.  ",
    ),
    Item(
      headerValue: 'How can I prevent dehydration from a sunburn?',
      expandedValue:
          "➤ Drinking extra water is crucial after a sunburn as it helps prevent dehydration. A sunburn draws fluid away from the rest of your body, so staying hydrated is important for recovery  ",
    ),
    Item(
      headerValue: 'What are the signs of a severe sunburn?',
      expandedValue:
          "➤ Severe sunburns, also known as third-degree sunburns, are characterized by blistering, severe pain, and a loss of function in the affected area. If you suspect you have a severe sunburn, seek medical attention immediately. Severe sunburns require emergency treatment, which may include skin grafts",
    ),
    Item(
      headerValue: 'What are the symptoms of weather allergies?',
      expandedValue:
          "➤ Symptoms of weather allergies can include a runny nose, stuffy nose, itchy eyes, watery eyes, itchy skin, sneezing, coughing, fatigue, wheezing, and dry, scaly skin. These symptoms can be similar to those from other conditions, such as the common cold, and may be worse if you also have asthma",
    ),
    Item(
      headerValue: 'How can I manage symptoms from weather allergies?',
      expandedValue:
          "➤  Symptoms from weather allergies can often be managed with over-the-counter medications, such as antihistamines, decongestants, nose sprays, and creams. Antihistamines block the chemicals in your immune system that are causing an allergic reaction, while decongestants decrease swelling in your nose and sinuses to make breathing easier. \n\n ➤ Nasal sprays are effective for treating runny, itchy nose symptoms, and skin creams can temporarily reduce itching and pain from allergy-related rashes. Prescription medications such as topical or oral steroids might be required to treat more severe allergies",
    ),
    Item(
      headerValue: 'How can I manage my weather allergies?',
      expandedValue:
          "➤  To manage your weather allergies, you can take steps such as avoiding exposure to your allergens whenever possible, checking your local news for daily pollen counts, and scheduling outdoor activities when levels are lower. Monitor the weather to keep track of triggers, such as rain or wind, and wear a mask when working outdoors. Wash your clothes once you get back inside to prevent the spread of allergens",
    ),
    Item(
      headerValue: 'How long do weather allergies last?',
      expandedValue:
          "➤ The length of symptoms for seasonal allergies depends on your specific allergen. Allergy symptoms often fluctuate with changes in season. It's important to monitor your symptoms and consult with a healthcare provider to understand the duration and severity of your allergies",
    ),
    Item(
      headerValue: 'What should I do to prepare for severe weather conditions?',
      expandedValue:
          "➤  To prepare for severe weather conditions, it's important to have a plan and an emergency kit. This includes knowing the best places to shelter both indoors and outdoors, and always protecting yourself from injury, especially your head. Staying informed about weather conditions during thunderstorms and being ready to take action can help keep you and your loved ones safe",
    ),
    Item(
      headerValue: 'How can I protect myself from injuries during a flood?',
      expandedValue:
          "➤ To protect yourself from injuries during a flood, it's important to prepare for the event by having a flood plan and an emergency kit. This includes knowing how to evacuate your home safely, having a safe place to go, and knowing how to stay safe after a flood. Avoid driving through floodwaters, and if you must, use a vehicle with a high clearance. Stay away from downed power lines and avoid touching electrical equipment",
    ),
    Item(
      headerValue:
          'How can I protect myself from injuries during an earthquake?',
      expandedValue:
          "➤ To protect yourself from injuries during an earthquake, it's important to have an earthquake plan and an emergency kit. This includes knowing how to drop, cover, and hold on, and having a safe place to go. Stay away from windows, doors, and outside walls, and avoid using elevators during an earthquake. After an earthquake, stay safe by avoiding damaged structures, and follow local guidelines for reentering your home",
    ),
  ];
}
