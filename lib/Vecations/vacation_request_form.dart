import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


class VacationRequestPage extends StatefulWidget {
  @override
  _VacationRequestPageState createState() => _VacationRequestPageState();
}
enum VacationType{

shortVacation,
  longVacation,
Emrgency,
Sick,
}
class _VacationRequestPageState extends State<VacationRequestPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late DateTime _endDate;
  late String _reason;
  double _leaveBalance = 10.87;
  VacationType _SelecetedVactionType=
  VacationType.shortVacation;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('Vacation Request',
        style: TextStyle(
          color: Colors.white,
        fontWeight: FontWeight.bold),),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0,),
          child :Column(
            children: [
              Text('Leave Balance : $_leaveBalance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              ),
           SizedBox(height: 20.0,),
           DropdownButtonFormField<VacationType>(
             value: _SelecetedVactionType,
             items: [
               DropdownMenuItem(value: VacationType.shortVacation,
               child: Text('Short Vacation'),),
               DropdownMenuItem(value: VacationType.longVacation,
                 child: Text('Long Vacation'),),

               DropdownMenuItem(
                 value: VacationType.Emrgency,
                 child: Text('Emrgency'),
               ),
               DropdownMenuItem(value: VacationType.Sick,
               child: Text('Sick'),)
             ],
             onChanged: (value){
               setState(() {
                 _SelecetedVactionType = value!;
               });
             },
           ),


              SizedBox(height: 20.0),

              if (_SelecetedVactionType == VacationType.shortVacation)
                shortVacationForm(formKey: _formKey, onFormSubmitted: _submitForm),
              if (_SelecetedVactionType == VacationType.longVacation)
                longVacationForm(formKey: _formKey, onFormSubmitted: _submitForm),
              if (_SelecetedVactionType == VacationType.Emrgency)
                EmrgencyVacationForm(formKey: _formKey, onFormSubmitted: _submitForm),
              if (_SelecetedVactionType == VacationType.Sick)
                SickVacationForm(formKey: _formKey, onFormSubmitted: _submitForm),

            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Submit request logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vacation request submitted')),
      );
    }
  }
}
class shortVacationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onFormSubmitted;

  const shortVacationForm({
    Key? key,
    required this.formKey,
    required this.onFormSubmitted,
  }) : super(key: key);

  @override
  _shortVacationFormState createState() => _shortVacationFormState();
}

class _shortVacationFormState extends State<shortVacationForm> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _visaChacked = false;
  String? _Reason;
  String? _balance;

  void _selectStartDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedStartDate = selectedDate;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedEndDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Start Date *'),
            onTap: () {
              _selectStartDate(context);
            },
            validator: (value) {
              if (_selectedStartDate == null) {
                return 'Please select a start date';
              }
              return null;
            },
            controller: TextEditingController(
              text: _selectedStartDate != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!)
                  : '',
            ),
          ),

          // End Date Field
          TextFormField(
            decoration: InputDecoration(labelText: 'End Date *'),
            onTap: () {
              _selectEndDate(context);
            },
            validator: (value) {
              if (_selectedEndDate == null) {
                return 'Please select an end date';
              }
              return null;
            },
            controller: TextEditingController(
              text: _selectedEndDate != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
                  : '',
            ),
          ),
          TextFormField(

            decoration: InputDecoration(labelText: 'Reason *'),
            onChanged: (value) {
              // TODO: Handle reason field value change
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a reason';
              }
              return null;
            },

          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'How many blance you need ? *'),
            onChanged: (value) {
              // TODO: Handle reason field value change
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a balance';
              }
              return null;
            },

    ),
          CheckboxListTile(
              title:Text('Visa') ,value: _visaChacked,
            onChanged: (value){
                       setState(() {
                                _visaChacked = value!;
                             });
                               },
                  controlAffinity: ListTileControlAffinity.leading,
          ),
          ElevatedButton(

            onPressed: widget.onFormSubmitted,
            child: Text('Submit short Vacations',
              style: TextStyle(
                fontSize: 16,
              ),),
          ),
        ],
      ),
    );

  }
}

class longVacationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onFormSubmitted;

  const longVacationForm({
    Key? key,
    required this.formKey,
    required this.onFormSubmitted,
  }) : super(key: key);

  @override
  _longVacationFormState createState() => _longVacationFormState();
}

class _longVacationFormState extends State<longVacationForm> {
  late TextEditingController _TimesheetController;
  late TextEditingController _PassportController;
  late TextEditingController _IQamacopyController;
  late TextEditingController _ClearanceController;
  String? _selectedFilePath;
  DateTime? _selectedIqamaexpirytDate;
  DateTime? _selectedStartingdatetDate;
  DateTime? _selectedDataofjoiningDate;
  final _FullNameController = TextEditingController();
  final _FactdeptController = TextEditingController();
  final _FileNOController = TextEditingController();
  final _TelExtController = TextEditingController();
  final _NationalityCntroller = TextEditingController();
  final _positionCntroller = TextEditingController();
  final _JobtitleCntroller = TextEditingController();
  final _SalaryCntroller = TextEditingController();
  final _IQamaECntroller = TextEditingController();
  bool _Reentrycheck= false ;
  bool _Exitcheck= false ;
  bool _EmargancyVACcheck= false ;


  void _selectedIqama(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedIqamaexpirytDate = selectedDate;
      });
    }
  }

  void _selectedStarting(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedStartingdatetDate = selectedDate;
      });
    }
  }
  void _selectdate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDataofjoiningDate = selectedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _TimesheetController = TextEditingController();
    _IQamacopyController = TextEditingController();
    _PassportController = TextEditingController();
    _ClearanceController= TextEditingController();
  }

  @override
  void dispose() {
    _TimesheetController.dispose();
    _PassportController.dispose();
    _TimesheetController.dispose();
    _ClearanceController.dispose();
    super.dispose();
  }
  Future<void>
  _openFilePicker1() async{
    FilePickerResult? result =
    await
    FilePicker.platform.pickFiles();
    if(result != null){
      setState(() {
        _selectedFilePath =
            result.files.single.path;
        _IQamacopyController.text =
            result.files.single.name;
      });
    }
  }
  Future<void>
  _openFilePicker2() async{
    FilePickerResult? result =
    await
    FilePicker.platform.pickFiles();
    if(result != null){
      setState(() {
        _selectedFilePath =
            result.files.single.path;
        _PassportController.text =
            result.files.single.name;
      });
    }
  }
  Future<void>
  _openFilePicker3() async{
    FilePickerResult? result =
    await
    FilePicker.platform.pickFiles();
    if(result != null){
      setState(() {
        _selectedFilePath =
            result.files.single.path;
        _TimesheetController.text =
            result.files.single.name;
      });
    }
  }
  Future<void>
  _openFilePicker4() async{
    FilePickerResult? result =
    await
    FilePicker.platform.pickFiles();
    if(result != null){
      setState(() {
        _selectedFilePath =
            result.files.single.path;
        _ClearanceController.text =
            result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget.formKey,


        child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(16.0,),
           child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            SizedBox(height: 1,),
            Text('Vacation Application',
            style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
            ),),

            const SizedBox(height: 20),
             Row(
                children: [

                SizedBox(width: 1,),
                Text('Full Name :'),
                // Text preceding the TextFormField

                SizedBox(width: 10),
                // Add some space between the text and TextFormField
                Expanded(


                  child: TextFormField(
                  decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                  horizontal: 10, vertical: 2),
                  enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(),
                  borderSide: const BorderSide(
                  color: Color(0xFF104164),
                  width: 1.0,
                       )
                  ),
                    disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.only(),
                    borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                        )
                    ),
                      focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.0,
                            )
                        ),
                      ),
                    validator: (value) {
                    if (value!.isEmpty) {
                    return "Enter Full name";
                         }
                    },
                       controller: _FullNameController,
                         ),
                  // Add your TextFormField properties and validators here
                     ),

                   ],
                  ),

                   Row(
                     children: [
                       SizedBox(height: 10,),
                       Text('Re-Entry'),
                       Checkbox(
                        value: _Reentrycheck,
                         onChanged: (value){
                           setState(() {
                             _Reentrycheck = value!;
                           });
                         },

                       ),
                       SizedBox(height: 10,),
                       Text('Exit'),
                       Checkbox(
                         value: _Exitcheck,
                         onChanged: (value){
                           setState(() {
                             _Exitcheck = value!;
                           });
                         },

                       ),
                       SizedBox(height: 10,),
                       Text('Emergancy Vac.'),
                       Checkbox(
                         value: _EmargancyVACcheck,
                         onChanged: (value){
                           setState(() {
                             _EmargancyVACcheck = value!;
                           });
                         },

                       ),
                     ],
                   ),
              SizedBox(height: 10,),
              Column(
                children: [
                  SizedBox(height: 1,),
                  Text('TO BE FILLED BY EMPLOYEE & SUBMITTED TO ADMINISTRATIVE DEPT. WITH A PHOTO & IQAMA COPY BEFORE 3 MONTHS FROM VACATION DATE ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13
                    ),),
                ],
              ),

                   SizedBox(height: 20,),
                  Row(

                    children: [
                    Text('Fact/ DEPT. :'),
                    // Text preceding the TextFormField
                    SizedBox(width: 10),
                    // Add some space between the text and TextFormField
                    Expanded(

                       child: TextFormField(
                              decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                         enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                          color: Color(0xFF104164),
                          width: 1.0,
                      )
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                            width: 1.0,
                       )
                     ),
                      focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.0,
                        )
                      ),
                   ),
                         validator: (value) {
                        if (value!.isEmpty) {
                             return "Enter Fact/DEPT.";
                        }
                    },
                        controller: _FactdeptController,
                ),
              ),
                     Text(' FILE NO:'),
                            // Text preceding the TextFormField
                            SizedBox(width: 10),
                       // Add some space between the text and TextFormField
                    Expanded(

                      child: TextFormField(
                      decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                      horizontal: 10, vertical: 2),
                      enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                      color: Color(0xFF104164),
                      width: 1.0,
                      )
                      ),
                          disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(),
                          borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                         )
                   ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(),
                          borderSide: const BorderSide(
                         color: Colors.blue,
                          width: 1.0,
                         )
                       ),
                      ),
                      validator: (value) {
                      if (value!.isEmpty) {
                      return "Enter File # ";
                          }
                      },
                           controller: _FileNOController,
                        ),
                        ),
                        ],
                         ),
              SizedBox(height: 30,),
               Row(
                 children: [
                   Text('Position :'),
                                  // Text preceding the TextFormField
                   SizedBox(width: 14),
                                  // Add some space between the text and TextFormField
                   Expanded(

                     child: TextFormField(
                       decoration: InputDecoration(
                         contentPadding: EdgeInsets.symmetric(
                             horizontal: 10, vertical: 2),
                         enabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.only(),
                             borderSide: const BorderSide(
                               color: Color(0xFF104164),
                               width: 1.0,)
                            ),
                         disabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.only(),
                             borderSide: const BorderSide(
                               color: Colors.blue,
                               width: 1.0,)
                            ),
                         focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.only(),
                             borderSide: const BorderSide(
                               color: Colors.blue,
                               width: 1.0,)
                         ),
                       ),
                       validator: (value) {
                         if (value!.isEmpty) {
                           return "Enter Position";
                         }
                         },
                       controller: _positionCntroller,
                     ),
                   ),
                   Text(' TEL,.EXT:'),
                            // Text preceding the TextFormField
                   SizedBox(width: 10),
                            // Add some space between the text and TextFormField
                   Expanded(

                     child: TextFormField(
                       decoration: InputDecoration(
                         contentPadding: EdgeInsets.symmetric(
                             horizontal: 10, vertical: 2),
                         enabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.only(),
                             borderSide: const BorderSide(
                               color: Color(0xFF104164),
                               width: 1.0,)
                         ),
                         disabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.only(),
                             borderSide: const BorderSide(
                               color: Colors.blue,
                               width: 1.0,)
                         ),
                         focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.only(),
                             borderSide: const BorderSide(
                               color: Colors.blue,
                               width: 1.0,)
                         ),
                       ),
                       validator: (value) {
                         if (value!.isEmpty) {
                           return "Enter TEL,.EXT ";
                         }
                         },
                       controller: _TelExtController,
                     ),
                   ),
                 ],
               ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('Salary :'),
                            // Text preceding the TextFormField
                  SizedBox(width: 1),
                            // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,)
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,)
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Nationalitiy";
                        }
                        },
                      controller: _SalaryCntroller,
                    ),
                  ),
                  Text(' JoB titel/JOB LEVEL:'),
                            // Text preceding the TextFormField
                  SizedBox(width: 10),
                            // Add some space between the text and TextFormField
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,)
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Job level ";
                        }
                        }, controller: _JobtitleCntroller,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(height: 10,),
                  Text('Nationality :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 1),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Salary";
                        }
                      },
                      controller: _NationalityCntroller,
                    ),
                  ),
                ],
              ),
              Row(
                  children: [
                    SizedBox(height: 65,),
                    Text('IQAMA EXPIRY DATE :'),
                    // Text preceding the TextFormField
                    SizedBox(width: 1),
                    // Add some space between the text and TextFormField
                    Expanded(

                      child: TextFormField(
                        decoration: InputDecoration(hintText: 'yy-mm-dd',
                      contentPadding: EdgeInsets.symmetric(
                      horizontal: 10, vertical: 2),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(),
                          borderSide: const BorderSide(
                            color: Color(0xFF104164),
                            width: 1.0,
                          )
                      ),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.0,
                          )
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.0,
                          )
                      ),
                    ),
                        onTap: () {
                          _selectedIqama(context);
                        },
                        validator: (value) {
                          if (_selectedIqamaexpirytDate == null) {
                            return 'Enter IQAMA EXPIRY DATE';
                          }
                          return null;
                        },
                        controller: TextEditingController(
                          text: _selectedIqamaexpirytDate != null
                              ? DateFormat('yy-MM-dd').format(_selectedIqamaexpirytDate!)
                              : '',
                        ),
                      ),
                    ),

                  ]
              ),
              Row(
                  children: [
                    SizedBox(height: 65,),
                    Text('PERIOD OF VACATION REQUESTED :'),
                    // Text preceding the TextFormField
                    SizedBox(width: 1),
                    // Add some space between the text and TextFormField
                    Expanded(

                      child: TextFormField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(),
                              borderSide: const BorderSide(
                                color: Color(0xFF104164),
                                width: 1.0,
                              )
                          ),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              )
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter PERIOD OF VACATION REQ";
                          }
                        },
                        controller: _IQamaECntroller,
                      ),
                    ),
                  ]
              ),
              Row(
                  children: [
                    SizedBox(height: 65,),
                    Text('SARTING DATE REQUESTED :'),
                    // Text preceding the TextFormField
                    SizedBox(width: 1),
                    // Add some space between the text and TextFormField
                    Expanded(

                      child: TextFormField(
                          decoration: InputDecoration(hintText: 'yy-mm-dd',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.only(),
                                borderSide: const BorderSide(
                                  color: Color(0xFF104164),
                                  width: 1.0,
                                )
                            ),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.only(),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 1.0,
                                )
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.only(),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 1.0,
                                )
                            ),
                          ),
                        onTap: () {
                          _selectedStarting(context);
                        },
                        validator: (value) {
                          if (_selectedStartingdatetDate == null) {
                            return 'Enter STARTING DATE';
                          }
                          return null;
                        },
                        controller: TextEditingController(
                          text: _selectedStartingdatetDate != null
                              ? DateFormat('yy-MM-dd').format(_selectedStartingdatetDate!)
                              : '',
                        ),
                      ),
                    ),

                  ]
              ),
              Row(
                  children: [
                    SizedBox(height: 65,),
                    Text('date of joining /Date of last Vacation :'),
                    // Text preceding the TextFormField
                    SizedBox(width: 1),
                    // Add some space between the text and TextFormField
                    Expanded(

                      child: TextFormField(
                        decoration: InputDecoration(hintText: 'yy-mm-dd',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(),
                              borderSide: const BorderSide(
                                color: Color(0xFF104164),
                                width: 1.0,
                              )
                          ),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              )
                          ),
                        ),
                          onTap: () {
                            _selectdate(context);
                          },
                          validator: (value) {
                            if (_selectedDataofjoiningDate == null) {
                              return 'Enter date of joining';
                            }
                            return null;
                          },
                          controller: TextEditingController(
                            text: _selectedDataofjoiningDate != null
                                ? DateFormat('yy-MM-dd').format(_selectedDataofjoiningDate!)
                                : '',
                          ),
                        ),
                      ),

                  ]
              ),
              SizedBox(height:15,),
              Text('Uplode IQAMA',style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              )),
              TextFormField(
                controller: _IQamacopyController,
                decoration: InputDecoration(hintText: 'pdf',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 2),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Color(0xFF104164),
                        width: 1.0,
                      )
                  ),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      )
                  ),
                ),
                validator: (value) {

                  return null;
                },
                readOnly: true,
                onTap: _openFilePicker1,
              ),

              SizedBox(height:15,),
              Text('Uplode Passport',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              )),
              TextFormField(

                controller: _PassportController,
                decoration: InputDecoration(hintText: 'pdf',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 1),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Color(0xFF104164),
                        width: 1.0,
                      )
                  ),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      )
                  ),
                ),
                validator: (value) {

                  return null;
                },
                readOnly: true,
                onTap: _openFilePicker2,
              ),
              SizedBox(height:15,),
              Text('Uplode TimeSheet',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              )),
              TextFormField(
                controller: _TimesheetController,
                decoration: InputDecoration(hintText: 'pdf',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 2),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Color(0xFF104164),
                        width: 1.0,
                      )
                  ),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      )
                  ),
                ),
                validator: (value) {

                  return null;
                },
                readOnly: true,
                onTap: _openFilePicker3,
              ),
              SizedBox(height:15,),
              Text('Clearance Vacations',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              )),
              TextFormField(
                controller: _ClearanceController,
                decoration: InputDecoration(hintText: 'pdf',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 2),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Color(0xFF104164),
                        width: 1.0,
                      )
                  ),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      )
                  ),
                ),
                validator: (value) {

                  return null;
                },
                readOnly: true,
                onTap: _openFilePicker4,
              ),
              SizedBox(height: 10,),
              Column(
                  children: [
                    Text('I HEREBY ACCEPT THAT UNPAID AND ABESENT DAYS ARE NOT COUNTED IN THE SERVICE BENEFITS ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                      ),),
                    // Text preceding the TextFormField
                    SizedBox(width: 10),
                    // Add some space between the text and TextFormField
                  ]
              ),






            ]
           ),
    ),
    );



        }
}
class EmrgencyVacationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onFormSubmitted;

  const EmrgencyVacationForm({
    Key? key,
    required this.formKey,
    required this.onFormSubmitted,
  }) : super(key: key);

  @override
  _EmrgencyVacationFormState createState() => _EmrgencyVacationFormState();
}

class _EmrgencyVacationFormState extends State<EmrgencyVacationForm> {
  late TextEditingController _documentController;
  String? _selectedFilePath;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  void _selectStartDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedStartDate = selectedDate;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedEndDate = selectedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _documentController = TextEditingController();
  }

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }
  Future<void>
  _openFilePicker() async{
    FilePickerResult? result =
    await
    FilePicker.platform.pickFiles();
    if(result != null){
      setState(() {
        _selectedFilePath =
            result.files.single.path;
        _documentController.text =
            result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Start Date *'),
            onTap: () {
              _selectStartDate(context);
            },
            validator: (value) {
              if (_selectedStartDate == null) {
                return 'Please select a start date';
              }
              return null;
            },
            controller: TextEditingController(
              text: _selectedStartDate != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!)
                  : '',
            ),
          ),

          // End Date Field
          TextFormField(
            decoration: InputDecoration(labelText: 'End Date *'),
            onTap: () {
              _selectEndDate(context);
            },
            validator: (value) {
              if (_selectedEndDate == null) {
                return 'Please select an end date';
              }
              return null;
            },
            controller: TextEditingController(
              text: _selectedEndDate != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
                  : '',
            ),
          ),

          // Reason Field
          TextFormField(
            decoration: InputDecoration(labelText: 'Reason *'),
            onChanged: (value) {
              // TODO: Handle reason field value change
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a reason';
              }
              return null;
            },
          ),


          TextFormField(
            controller: _documentController,
            decoration: InputDecoration(labelText: 'Upload Document '),
            validator: (value) {

              return null;
            },
            readOnly: true,
            onTap: _openFilePicker,
          ),

          ElevatedButton(
            onPressed: widget.onFormSubmitted,
            child: Text('Submit'),
          ),const Text("Note: Please uplode sick leave as (PDF)",
            style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold,height: 10, ),),
        ],
      ),
    );
  }
}



class SickVacationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onFormSubmitted;

  const SickVacationForm({
    Key? key,
    required this.formKey,
    required this.onFormSubmitted,
  }) : super(key: key);

  @override
  _SickVacationFormState createState() => _SickVacationFormState();
}

class _SickVacationFormState extends State<SickVacationForm> {
  late TextEditingController _documentController;
  String? _selectedFilePath;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  void _selectStartDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedStartDate = selectedDate;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedEndDate = selectedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _documentController = TextEditingController();
  }

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }
  Future<void>
  _openFilePicker() async{
    FilePickerResult? result =
        await
        FilePicker.platform.pickFiles();
    if(result != null){
      setState(() {
        _selectedFilePath =
        result.files.single.path;
        _documentController.text =
            result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Start Date *'),
            onTap: () {
              _selectStartDate(context);
            },
            validator: (value) {
              if (_selectedStartDate == null) {
                return 'Please select a start date';
              }
              return null;
            },
            controller: TextEditingController(
              text: _selectedStartDate != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!)
                  : '',
            ),
          ),

          // End Date Field
          TextFormField(
            decoration: InputDecoration(labelText: 'End Date *'),
            onTap: () {
              _selectEndDate(context);
            },
            validator: (value) {
              if (_selectedEndDate == null) {
                return 'Please select an end date';
              }
              return null;
            },
            controller: TextEditingController(
              text: _selectedEndDate != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
                  : '',
            ),
          ),

          // Reason Field
          TextFormField(
            decoration: InputDecoration(labelText: 'Reason *'),
            onChanged: (value) {
              // TODO: Handle reason field value change
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a reason';
              }
              return null;
            },
          ),


          TextFormField(
            controller: _documentController,
            decoration: InputDecoration(labelText: 'Upload Sick Leave Document *'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please upload the sick leave document';
              }
              return null;
            },
            readOnly: true,
            onTap: _openFilePicker,
          ),

          ElevatedButton(
            onPressed: widget.onFormSubmitted,
            child: Text('Submit'),
          ),const Text("Note: Please uplode sick leave as (PDF)",
            style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold,height: 10, ),),
        ],
      ),
    );
  }
}
