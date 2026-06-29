import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';



class TicketForm extends StatefulWidget {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey;
  final VoidCallback onFormSubmitted;

  TicketForm({
    Key? key,
    required this.formKey,
    required this.onFormSubmitted,
  }) : super(key: key);

      @override
      State<TicketForm> createState() => _TicketFormState();
      }

      class _TicketFormState extends State<TicketForm> {
      final _FullNameController = TextEditingController();
      final _FactdeptController = TextEditingController();
      final _PurposeOfTripController = TextEditingController();
      final _FileNOController = TextEditingController();
      final _GradeController = TextEditingController();
      final _TelExtController = TextEditingController();
      final _NationalityCntroller = TextEditingController();
      final _positionCntroller = TextEditingController();
      final _RemarkCntroller = TextEditingController();
      final _SectorReqController = TextEditingController();
      final _AirlinesreqController = TextEditingController();
      final _PeriodofvacationController = TextEditingController();
      final _TelnoController = TextEditingController();
      final _CountryoforiginController = TextEditingController();
      final _FullName1Controller = TextEditingController();
      final _FullName2Controller = TextEditingController();
      final _FullName3Controller = TextEditingController();
      final _DOBController = TextEditingController();
      final _DOB1Controller = TextEditingController();
      final _DOB2Controller = TextEditingController();
      DateTime? _selcetedDate3;
      DateTime? _selcetedDate4;

      
      
      Future<void> _selectDate() async {
      final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
      );

      
      }
      Future<void> _SelcetDate1() async {
      final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
      );
      
      }
      Future<void> _SelcetDate2() async {
      final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
      );

      if (picked != null && picked != _selcetedDate3) {
      setState(() {
      _selcetedDate3 = picked;
      });
      }
      }
      Future<void> _SelcetDate3() async {
      final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
      );

      if (picked != null && picked != _selcetedDate4) {
      setState(() {
      _selcetedDate4 = picked;
      });
      }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          key: widget.formKey,
        appBar: AppBar(
          title: Text('Tecket Reservations',
          style: TextStyle(
            color: Colors.white,

          ),),
          backgroundColor: Colors.blue[800],

        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(16.0,),
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10,),
              Text('Ticket Reservation',
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
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
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

              SizedBox(height: 30,),
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
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
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
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
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
                  SizedBox(width: 34),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
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
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
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
                  Text('Nationalitiy :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 15),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Nationalitiy";
                        }
                      },
                      controller: _NationalityCntroller,
                    ),
                  ),
                  Text(' JOB LEVEL:'),
                  // Text preceding the TextFormField
                  SizedBox(width: 10),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
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
                      },
                      controller: _GradeController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                  children: [
                    Text('RESERVATION DETAILS :',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      ),),
                    // Text preceding the TextFormField
                    SizedBox(width: 10),
                    // Add some space between the text and TextFormField
                  ]
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text('SECTOR REQUIRED :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter SectorReq";
                        }
                      },
                      controller: _SectorReqController,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10,),
              Row(
                children: [
                  Text('AIRLINES REQUIRED  :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter SectorReq";
                        }
                      },
                      controller: _AirlinesreqController,

                    ),
                  ),
                ],
              ),
              SizedBox(height: 10, width: 4,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(''),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _SelcetDate2,
                    child: Text('Departure.'),
                  ),
                  SizedBox(width: 5),
                  Text(_selcetedDate3 != null
                      ? DateFormat('yy-MM-dd').format(_selcetedDate3!)
                      : '',
                  ),

                  Text(''),
                  SizedBox(width: 1),
                  ElevatedButton(
                    onPressed: _SelcetDate3,
                    child: Text('Arrival.'),
                  ),
                  SizedBox(width: 9),
                  Text(_selcetedDate4 != null
                      ? DateFormat('yy-MM-dd').format(_selcetedDate4!)
                      : '',
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text('PERIOD OF VACATION :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _PeriodofvacationController,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('TEL NO. :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 96,height: 60,),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _TelnoController,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Country of Origin:'),
                  // Text preceding the TextFormField
                  SizedBox(width: 40),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _CountryoforiginController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text('Remark if any :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _RemarkCntroller,

                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                  children: [
                    Text('RESERVATION FOR DEPENDANT :',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      ),),
                    // Text preceding the TextFormField
                    SizedBox(width: 10),
                    // Add some space between the text and TextFormField
                  ]
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text('Ful name :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 6),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _FullName1Controller,

                    ),
                  ),
                  Text(' DOB :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _DOBController,

                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text('Full name :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 6),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _FullName2Controller,

                    ),
                  ),
                  Text(' DOB :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _DOB1Controller,

                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text('Ful name :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 6),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _FullName3Controller,

                    ),
                  ),
                  Text(' DOB :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
                  // Add some space between the text and TextFormField
                  Expanded(

                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Color(0xFF104164),
                              width: 1.0,
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            )
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Purpose";
                        }
                      },
                      controller: _DOB2Controller,

                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                  children: [
                    Text('Note : - I hereby agree the following :-',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                      ),),
                    // Text preceding the TextFormField
                    SizedBox(width: 10),
                    // Add some space between the text and TextFormField
                  ]
              ),
              SizedBox(height: 10,),
              Column(
                  children: [
                    Text('1. Any extra amount other than eligible shall be paid to the Cashier through Accounts Dept. byDeduction Note approved by Administrative Service Manager – HRD and the original receiptto be submitted to TRI for collecting the Ticket.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                      ),),
                    // Text preceding the TextFormField
                    SizedBox(width: 10),
                    // Add some space between the text and TextFormField
                  ]
              ),
              SizedBox(height: 10,),
              Column(
                  children: [
                    Text('2. The return ticket date shall be confirmed in case of Waiting list and re-confirm the confirmedticket for return trip well in advance.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                      ),),
                    // Text preceding the TextFormField
                    SizedBox(width: 10),
                    // Add some space between the text and TextFormField
                  ]
              ),
              SizedBox(height: 10,),
              Column(
                  children: [
                    Text('3. One way used special fare ticket shall not be reimbursed by certain airlines.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                      ),),
                    // Text preceding the TextFormField
                    SizedBox(width: 10),
                    // Add some space between the text and TextFormField
                  ]
              ),
              ElevatedButton(

                onPressed: widget.onFormSubmitted,
                child: Text('Submit',
                  style: TextStyle(
                    fontSize: 16,
                  ),),
              ),

            ],
          ),
        ),
      );
        
    }
        }