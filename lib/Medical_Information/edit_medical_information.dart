import 'dart:convert';
import 'dart:io';
import 'package:disaster_relief_application/Medical_Information/firebase_medical_information.dart';
import 'package:disaster_relief_application/Utility/read_only_text_from_field.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sklite/tree/tree.dart';

class EditMedicalInformation extends StatefulWidget {
  final Map<String, dynamic> medicalData;

  const EditMedicalInformation({super.key, required this.medicalData});

  @override
  _EditMedicalInformationState createState() => _EditMedicalInformationState();
}

class _EditMedicalInformationState extends State<EditMedicalInformation> {
  final _formKey = GlobalKey<FormState>();

  String? selectedAge;
  String? selectedChestPain;
  String? selectedExerciseAngina;
  String? selectedHypertension;
  String? selectedHeartDisease;
  String? selectedSmokingStatus;

  DecisionTreeClassifier? dTree;
  bool hasChanged = false;
  bool isButtonDisabled = true; // Initially disable the button
  bool isLoading = false; // To track the loading state

  // Store the initial values
  String? initialAge;
  String? initialChestPain;
  String? initialExerciseAngina;
  String? initialHypertension;
  String? initialHeartDisease;
  String? initialSmokingStatus;

  final FirebaseMedicalInformation _firebaseMedicalInformation = FirebaseMedicalInformation();

  TextEditingController classificationController = TextEditingController();

  double dropDownMenuHeight = Platform.isIOS ? 64 : 63;

  @override
  void initState() {
    super.initState();
    loadModel();
    initializeMedicalInfo();
  }

  void loadModel() async {
    final jsonString = await DefaultAssetBundle.of(context).loadString('assets/classmodel.json');
    setState(() {
      dTree = DecisionTreeClassifier.fromMap(json.decode(jsonString));
    });
  }

  void initializeMedicalInfo() {
    setState(() {
      selectedAge = widget.medicalData['Age'] != null ? 'Age: ${widget.medicalData['Age']} Years Old' : null;
      selectedChestPain = widget.medicalData['Chest Pain Type'] != null ? 'Chest Pain Type: ${widget.medicalData['Chest Pain Type']}' : null;
      selectedExerciseAngina = widget.medicalData['Exercise Angina'] != null ? 'Exercise Angina: ${widget.medicalData['Exercise Angina']}' : null;
      selectedHypertension = widget.medicalData['Hypertension'] != null ? 'Hypertension: ${widget.medicalData['Hypertension']}' : null;
      selectedHeartDisease = widget.medicalData['Heart Disease'] != null ? 'Heart Disease: ${widget.medicalData['Heart Disease']}' : null;
      selectedSmokingStatus = widget.medicalData['Smoking Status'] != null ? 'Smoking Status: ${widget.medicalData['Smoking Status']}' : null;

      // Set initial values
      initialAge = selectedAge;
      initialChestPain = selectedChestPain;
      initialExerciseAngina = selectedExerciseAngina;
      initialHypertension = selectedHypertension;
      initialHeartDisease = selectedHeartDisease;
      initialSmokingStatus = selectedSmokingStatus;

      // Check if there are any changes initially
      hasChanged = checkForChanges();
      isButtonDisabled = !hasChanged; // Enable button if there are changes

      classificationController.text = formatText('Classification', widget.medicalData['Classification']);
    });
  }

  Future<void> makePrediction() async {
    if (!isFormComplete()) {
      return;
    }

    int age = int.parse(selectedAge!.split(': ').last.split(' ').first);
    int chestPain = int.parse(selectedChestPain!.split(': ').last);
    String exerciseAngina = selectedExerciseAngina!.split(': ').last;
    String hypertension = selectedHypertension!.split(': ').last;
    String heartDisease = selectedHeartDisease!.split(': ').last;
    String smokingStatus = selectedSmokingStatus!.split(': ').last;

    List<double> inputArray = [
      age.toDouble(),
      chestPain.toDouble(),
      exerciseAngina == 'Yes' ? 1.0 : 0.0,
      hypertension == 'Yes' ? 1.0 : 0.0,
      heartDisease == 'Yes' ? 1.0 : 0.0,
      smokingStatus == 'Non-Smoker' ? 1.0 : 0.0,
      smokingStatus == 'Smoker' ? 1.0 : 0.0,
      smokingStatus == 'Unknown' ? 1.0 : 0.0,
    ];

    if (dTree != null) {
      var prediction = dTree!.predict(inputArray);
      String classificationResult = prediction == 1 ? "Fit for Volunteering" : "Not Fit for Volunteering";
      try {
        await _firebaseMedicalInformation.saveUserData(
          selectedAge: selectedAge,
          selectedChestPain: selectedChestPain,
          selectedExerciseAngina: selectedExerciseAngina,
          selectedHypertension: selectedHypertension,
          selectedHeartDisease: selectedHeartDisease,
          selectedSmokingStatus: selectedSmokingStatus,
          classificationResult: classificationResult,
        );

        var updatedMedicalData = await _firebaseMedicalInformation.fetchMedicalInfo();

        setState(() {
          classificationController.text = formatText('Classification', classificationResult);
        });

        Navigator.pop(context, updatedMedicalData); // Pop the screen with updated data
      } catch (error) {
        print('Error saving data: $error');
      }
    } else {
      print('Model not loaded yet');
    }
  }

  bool checkForChanges() {
    return selectedAge != initialAge ||
        selectedChestPain != initialChestPain ||
        selectedExerciseAngina != initialExerciseAngina ||
        selectedHypertension != initialHypertension ||
        selectedHeartDisease != initialHeartDisease ||
        selectedSmokingStatus != initialSmokingStatus;
  }

  bool isFormComplete() {
    return selectedAge != null &&
        selectedChestPain != null &&
        selectedExerciseAngina != null &&
        selectedHypertension != null &&
        selectedHeartDisease != null &&
        selectedSmokingStatus != null;
  }

  String formatText(String key, String? value) {
    if (value == null || value.isEmpty) return '';
    switch (key) {
      case 'Classification':
        return 'You are $value';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.notoSansKhudawadi(color: Colors.white, fontSize: 24),
        title: const Text('Edit Medical Info'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 96, 88, 180),
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: hasChanged && !isButtonDisabled && isFormComplete()
                      ? () async {
                          setState(() {
                            isLoading = true;
                          });
                          await makePrediction();
                          setState(() {
                            isLoading = false;
                          });
                        }
                      : null,
                ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Image.asset('assets/EditMedicalInfo.png',
                  height: MediaQuery.of(context).size.height*0.1615,
                  width: MediaQuery.of(context).size.width*0.55
                ),
                buildDropdownField(
                  label: 'Age',
                  icon: Icons.cake,
                  items: List.generate(73, (index) => DropdownMenuItem(
                    value: 'Age: ${index + 18} Years Old',
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Text('Age: ${index + 18} Years Old', 
                        style: const TextStyle(fontSize: 20,
                        color: Colors.white)
                        ),
                      ],
                    ),
                  )),
                  value: selectedAge,
                  onChanged: (value) => setState(() {
                    selectedAge = value;
                    hasChanged = checkForChanges();
                    isButtonDisabled = !hasChanged && !isFormComplete(); // Update button state
                  }),
                ),
                buildDropdownField(
                  label: 'Chest Pain Type',
                  icon: Icons.person_search_sharp,
                  items: List.generate(4, (index) => DropdownMenuItem(
                    value: 'Chest Pain Type: ${index + 1}',
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Text('Chest Pain Type: ${index + 1}', 
                        style: const TextStyle(fontSize: 20,
                        color: Colors.white),
                        ),
                      ],
                    ),
                  )),
                  value: selectedChestPain,
                  onChanged: (value) => setState(() {
                    selectedChestPain = value;
                    hasChanged = checkForChanges();
                    isButtonDisabled = !hasChanged && !isFormComplete(); // Update button state
                  }),
                ),
                buildDropdownField(
                  label: 'Smoking Status',
                  icon: Icons.smoking_rooms_outlined,
                  items: ['Smoker', 'Non-Smoker', 'Unknown'].map((String value) => DropdownMenuItem(
                    value: 'Smoking Status: $value',
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Text('Smoking Status: $value', 
                          style: const TextStyle(fontSize: 20, 
                          color: Colors.white),),
                      ],
                    ),
                  )).toList(),
                  value: selectedSmokingStatus,
                  onChanged: (value) => setState(() {
                    selectedSmokingStatus = value;
                    hasChanged = checkForChanges();
                    isButtonDisabled = !hasChanged && !isFormComplete(); // Update button state
                  }),
                ),
                buildDropdownField(
                  label: 'Exercise Angina',
                  icon: Icons.run_circle,
                  items: ['Yes', 'No'].map((String value) => DropdownMenuItem(
                    value: 'Exercise Angina: $value',
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Text('Exercise Angina: $value', style: const TextStyle(fontSize: 20,
                        color: Colors.white),),
                      ],
                    ),
                  )).toList(),
                  value: selectedExerciseAngina,
                  onChanged: (value) => setState(() {
                    selectedExerciseAngina = value;
                    hasChanged = checkForChanges();
                    isButtonDisabled = !hasChanged && !isFormComplete(); // Update button state
                  }),
                ),
                buildDropdownField(
                  label: 'Hypertension',
                  icon: Icons.bloodtype,
                  items: ['Yes', 'No'].map((String value) => DropdownMenuItem(
                    value: 'Hypertension: $value',
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Text('Hypertension: $value', style: const TextStyle(fontSize: 20,
                        color: Colors.white),),
                      ],
                    ),
                  )).toList(),
                  value: selectedHypertension,
                  onChanged: (value) => setState(() {
                    selectedHypertension = value;
                    hasChanged = checkForChanges();
                    isButtonDisabled = !hasChanged && !isFormComplete(); // Update button state
                  }),
                ),
                buildDropdownField(
                  label: 'Heart Disease',
                  icon: Icons.favorite_border,
                  items: ['Yes', 'No'].map((String value) => DropdownMenuItem(
                    value: 'Heart Disease: $value',
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Text(
                          'Heart Disease: $value', style: const TextStyle(fontSize: 20, 
                          color: Colors.white),
                        ),
                      ],
                    ),
                  )).toList(),
                  value: selectedHeartDisease,
                  onChanged: (value) => setState(() {
                    selectedHeartDisease = value;
                    hasChanged = checkForChanges();
                    isButtonDisabled = !hasChanged && !isFormComplete(); // Update button state
                  }),
                ),
                const SizedBox(height: 12.5),
                ReadOnlyTextFormField(
                  controller: classificationController,
                  label: 'Classification Result',
                  textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                  borderStyle: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownField<T>({
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<dynamic>> items,
    dynamic value,
    Function(dynamic)? onChanged,
  }) {
    return DropdownButtonFormField2(
      iconStyleData: const IconStyleData(iconEnabledColor: Colors.white),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        maxHeight: 350.0,
        offset: const Offset(0, 15),
      ),
      buttonStyleData: ButtonStyleData(
        height: dropDownMenuHeight,
        width: 160,
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white,
          ),
          color: Colors.transparent,
        ),
      ),
      hint: Row(
        children: [
          Icon(
            icon,
            size: 25,
            color: Colors.white,
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Text(
              value == null ? label : value.toString(),
              style: GoogleFonts.rubik(
                fontSize: 20,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      isExpanded: true,
      items: items.map((DropdownMenuItem item) {
        return DropdownMenuItem(
          value: item.value,
          child: Text(
            item.value.toString(),
            style: GoogleFonts.rubik(
              fontSize: 20,
              color: Color.fromARGB(255, 96, 88, 180), // Color for the dropdown items
            ),
          ),
        );
      }).toList(),
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((dynamic item) {
          return Row(
            children: [
              Icon(
                icon,
                size: 25,
                color: Colors.white,
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  item.value.toString(),
                  style: GoogleFonts.rubik(
                    fontSize: 20,
                    color: Colors.white, // Color for the selected value
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList();
      },
      value: value,
      onChanged: onChanged,
    );
  }
}
