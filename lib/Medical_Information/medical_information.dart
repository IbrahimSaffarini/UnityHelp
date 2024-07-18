import 'package:disaster_relief_application/Medical_Information/edit_medical_information.dart';
import 'package:disaster_relief_application/Utility/read_only_text_from_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicalInformationPage extends StatefulWidget {
  final Map<String, dynamic> medicalData;

  const MedicalInformationPage({super.key, required this.medicalData});

  @override
  _MedicalInformationPageState createState() => _MedicalInformationPageState();
}

class _MedicalInformationPageState extends State<MedicalInformationPage> {
  final _textStyle = const TextStyle(fontSize: 20, color: Colors.white);
  final _borderStyle = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(15),
  );

  String formatText(String key, String? value) {
    if (value == null || value.isEmpty) return '';
    switch (key) {
      case 'Age':
        return 'You are $value Years Old';
      case 'Chest Pain Type':
        return 'You have Type $value';
      case 'Exercise Angina':
        return value == 'Yes' ? 'You have Exercise Angina' : 'You don\'t have Exercise Angina';
      case 'Hypertension':
        return value == 'Yes' ? 'You have Hypertension' : 'You don\'t have Hypertension';
      case 'Heart Disease':
        return value == 'Yes' ? 'You have Heart Disease' : 'You don\'t have Heart Disease';
      case 'Smoking Status':
        return value == 'Unknown' ? 'Not Specified' : 'You are a $value';
      case 'Classification':
        return 'You are $value';
      default:
        return value;
    }
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController ageController = TextEditingController(text: formatText('Age', widget.medicalData['Age']));
    TextEditingController chestPainController = TextEditingController(text: formatText('Chest Pain Type', widget.medicalData['Chest Pain Type']));
    TextEditingController exerciseAnginaController = TextEditingController(text: formatText('Exercise Angina', widget.medicalData['Exercise Angina']));
    TextEditingController hypertensionController = TextEditingController(text: formatText('Hypertension', widget.medicalData['Hypertension']));
    TextEditingController heartDiseaseController = TextEditingController(text: formatText('Heart Disease', widget.medicalData['Heart Disease']));
    TextEditingController smokingStatusController = TextEditingController(text: formatText('Smoking Status', widget.medicalData['Smoking Status']));
    TextEditingController classificationController = TextEditingController(text: formatText('Classification', widget.medicalData['Classification']));

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.notoSansKhudawadi(color: Colors.white, fontSize: 24),
        centerTitle: true,
        title: const Text('Medical Information'),
        backgroundColor: const Color.fromARGB(255, 96, 88, 180),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              var updatedMedicalData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMedicalInformation(medicalData: widget.medicalData),
                ),
              );
              if (updatedMedicalData != null) {
                setState(() {
                  widget.medicalData.addAll(updatedMedicalData);
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 96, 88, 180),
              Color.fromARGB(255, 130, 120, 185),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/MedicalInfo.png', 
                        height: MediaQuery.of(context).size.height*0.1615,
                        width: MediaQuery.of(context).size.width*0.54,
                      ),
                      ReadOnlyTextFormField(
                        controller: ageController,
                        label: 'Age',
                        textStyle: _textStyle,
                        borderStyle: _borderStyle,
                      ),
                      const SizedBox(height: 20),
                      ReadOnlyTextFormField(
                        controller: chestPainController,
                        label: 'Chest Pain Type',
                        textStyle: _textStyle,
                        borderStyle: _borderStyle,
                      ),
                      const SizedBox(height: 20),
                      ReadOnlyTextFormField(
                        controller: smokingStatusController,
                        label: 'Smoking Status',
                        textStyle: _textStyle,
                        borderStyle: _borderStyle,
                      ),
                      const SizedBox(height: 20),
                      ReadOnlyTextFormField(
                        controller: exerciseAnginaController,
                        label: 'Exercise Angina',
                        textStyle: _textStyle,
                        borderStyle: _borderStyle,
                      ),
                      const SizedBox(height: 20),
                      ReadOnlyTextFormField(
                        controller: hypertensionController,
                        label: 'Hypertension',
                        textStyle: _textStyle,
                        borderStyle: _borderStyle,
                      ),
                      const SizedBox(height: 20),
                      ReadOnlyTextFormField(
                        controller: heartDiseaseController,
                        label: 'Heart Disease',
                        textStyle: _textStyle,
                        borderStyle: _borderStyle,
                      ),
                      const SizedBox(height: 20),
                      ReadOnlyTextFormField(
                        controller: classificationController,
                        label: 'Classification',
                        textStyle: _textStyle,
                        borderStyle: _borderStyle,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
