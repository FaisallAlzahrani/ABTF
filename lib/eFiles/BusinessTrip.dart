import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class Forms extends StatefulWidget {
  @override
  State<Forms> createState() => _FormsState();

}
enum BusinessType{
  BillOfBusinessTrip,
   BusinessTrip,
}

class _FormsState extends State<Forms> {
  final _formKey = GlobalKey<FormState>();
  double screenHeight = 0 ;
  double screenWidth = 0 ;

BusinessType _SelectedBusinessType=
    BusinessType.BillOfBusinessTrip;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(

        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text('Forms ',
            style: TextStyle(
              color: Colors.white,

            ),
          ),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(16.0,),
            child: Column(
              children: [

                DropdownButtonFormField<BusinessType>(
                  value: _SelectedBusinessType,
                  items: [
                    DropdownMenuItem(value: BusinessType.BusinessTrip,
                      child: Text('Bill of Business Trip'),),
                    DropdownMenuItem(value: BusinessType.BillOfBusinessTrip,
                      child: Text('Business Trip'),),
                  ],
                  onChanged: (value){
                    setState(() {
                      _SelectedBusinessType = value!;
                    });
                  },
                ),

                if (_SelectedBusinessType == BusinessType.BusinessTrip)
                  BillOfBusinessTripForm(formKey: _formKey, onFormSubmitted: _submitForm),
                if (_SelectedBusinessType == BusinessType.BillOfBusinessTrip)
                  BusinessTrip(formKey: _formKey, onFormSubmitted: _submitForm),
              ],
            ),
        ),

    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Submit request logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Business Trip request submitted')),
      );
    }
  }
}
class BusinessTrip extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onFormSubmitted;

  BusinessTrip({
    Key? key,
    required this.formKey,
    required this.onFormSubmitted,
  }) : super(key: key);

  @override
  State<BusinessTrip> createState() => _BusinessTripState();

}

class _BusinessTripState extends State<BusinessTrip> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;

  final _FullNameController = TextEditingController();
  final _FactdeptController = TextEditingController();
  final _PurposeOfTripController = TextEditingController();
  final _FileNOController = TextEditingController();
  final _GradeController = TextEditingController();
  final _TelExtController = TextEditingController();
  final _NationalityCntroller = TextEditingController();
  final _positionCntroller = TextEditingController();
  final _RemarkCntroller = TextEditingController();
  final _SectorReq1Controller = TextEditingController();
  final _SectorReq2Controller = TextEditingController();

  DateTime? _selectedDate4;
  DateTime? _selcetedDate5;
  DateTime? _selcetedDate6;
  DateTime? _selcetedDate7;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
    );

    if (picked != null && picked != _selectedDate4) {
      setState(() {
        _selectedDate4 = picked;
      });
    }
  }
  Future<void> _SelcetDate1() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
    );

    if (picked != null && picked != _selcetedDate5) {
      setState(() {
        _selcetedDate5 = picked;
      });
    }
  }
  Future<void> _SelcetDate2() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
    );

    if (picked != null && picked != _selcetedDate6) {
      setState(() {
        _selcetedDate6 = picked;
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

    if (picked != null && picked != _selcetedDate7) {
      setState(() {
        _selcetedDate7 = picked;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Form(
        key: widget.formKey,


        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(top: screenHeight*0.0001 ),
          child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Text('Bussiness Trip form',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              ),),

            Padding(
              padding:  EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
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
                            borderRadius: BorderRadius.circular(60),
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
            ),


            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
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
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
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
                          return "Enter TEL,.EXT ";
                        }
                      },
                      controller: _TelExtController,
                    ),
                  ),

                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
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
                          return "Enter Job level ";
                        }
                      },
                      controller: _GradeController,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Column(
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
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
                children: [
                  Text('SECTOR REQUIRED 1 :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
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
                          return "Enter SectorReq";
                        }
                      },
                      controller: _SectorReq1Controller,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(''),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: Text('Departure.'),
                  ),
                  SizedBox(width: 5),
                  Text(_selectedDate4 != null
                      ? DateFormat('yy-MM-dd').format(_selectedDate4!)
                      : '',
                  ),

                  Text(''),
                  SizedBox(width: 1),
                  ElevatedButton(
                    onPressed: _SelcetDate1,
                    child: Text('Arrival.'),
                  ),
                  SizedBox(width: 9),
                  Text(_selcetedDate5 != null
                      ? DateFormat('yy-MM-dd').format(_selcetedDate5!)
                      : '',
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
                children: [
                  Text('SECTOR REQUIRED 2 :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
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

                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(''),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _SelcetDate2,
                    child: Text('Departure.'),
                  ),
                  SizedBox(width: 5),
                  Text(_selcetedDate6 != null
                      ? DateFormat('yy-MM-dd').format(_selcetedDate6!)
                      : '',
                  ),

                  Text(''),
                  SizedBox(width: 1),
                  ElevatedButton(
                    onPressed: _SelcetDate3,
                    child: Text('Arrival.'),
                  ),
                  SizedBox(width: 9),
                  Text(_selcetedDate7 != null
                      ? DateFormat('yy-MM-dd').format(_selcetedDate7!)
                      : '',
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
                children: [
                  Text('Purpose Of Trip :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
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
                          return "Enter Purpose";
                        }
                      },
                      controller: _PurposeOfTripController,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: Row(
                children: [
                  Text('Remark if any    :'),
                  // Text preceding the TextFormField
                  SizedBox(width: 7),
                  // Add some space between the text and TextFormField
                  Expanded(flex: 1,

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

                    ),
                  ),
                ],
              ),
            ),Padding(
              padding: EdgeInsets.only(top: screenHeight*0.01),
              child: ElevatedButton(

                onPressed: widget.onFormSubmitted,
                child: Text('Submit',
                  style: TextStyle(
                    fontSize: 16,
                  ),),
              ),
            ),

          ],
        ),
    ),
    );
  }
}

class BillOfBusinessTripForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onFormSubmitted;

  BillOfBusinessTripForm({
    Key? key,
    required this.formKey,
    required this.onFormSubmitted,
  }) : super(key: key);


  @override
  State<BillOfBusinessTripForm> createState() => _BillOfBusinessTripFormState();

}

class _BillOfBusinessTripFormState extends State<BillOfBusinessTripForm> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;
  late TextEditingController _HotelBillController;
  late TextEditingController _patrolBillController;
  late TextEditingController _ExtraBillController;
  final _UserController = TextEditingController();
  final _FileNOController = TextEditingController();
  final _GradeController = TextEditingController();
  final _TripToController = TextEditingController();
  final _ResonCntroller = TextEditingController();
  final _TotalDaysController = TextEditingController();
  final _CountryVisitController = TextEditingController();
  final _TotalAmountController = TextEditingController();
  String? _SelectedFilePath;
  DateTime? _selectedDate;
  DateTime? _selcetedDate2;
  bool _Billchecked = false;
  bool _Hotelchecked= false;
  bool _patrolTaxichecked=false;
  bool _ticketchecked=false;



  @override
  void initState() {
    super.initState();
    _HotelBillController = TextEditingController();
    _patrolBillController =TextEditingController();
    _ExtraBillController = TextEditingController();
  }

  @override
  void dispose() {
    _HotelBillController.dispose();
    _patrolBillController.dispose();
    _ExtraBillController.dispose();
    super.dispose();
  }
  Future<void>
  _UplodeFilePicker() async{
    FilePickerResult? result =
    await
    FilePicker.platform.pickFiles();
    if(result != null){
      setState(() {
        _SelectedFilePath =
            result.files.single.path;
        _HotelBillController.text =
            result.files.single.name;
        _patrolBillController.text =
            result.files.single.name;
        _ExtraBillController.text =
            result.files.single.name;
      });
    }
  }


  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  Future<void> _SelcetDate1() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
    );

    if (picked != null && picked != _selcetedDate2) {
      setState(() {
        _selcetedDate2 = picked;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Form(
      key: widget.formKey,


      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.02),
            child: Text('Bussiness Trip form',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              ),),
          ),

          Padding(
            padding:EdgeInsets.only(top: screenHeight*0.02),
            child: Row(
              children: [
                SizedBox(width: 1,),
                Text('User   :'),
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
                        return "Enter user";
                      }
                    },
                    controller: _UserController,
                  ),
                  // Add your TextFormField properties and validators here
                ),
                SizedBox(width: 70,),
                Text(' File #:'),
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
                        return "Enter File number";
                      }
                    },
                    controller: _FileNOController,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:EdgeInsets.only(top: screenHeight*0.02),
            child: Row(
              children: [
                Text('Grade :'),
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
                        return "Enter Grade";
                      }
                    },
                    controller: _GradeController,
                  ),
                ),
                Text(' Business Trip to:'),
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
                        return "Enter Business Trip ";
                      }
                    },
                    controller: _TripToController,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.02),
            child: Row(
              children: [
                Text('Purpose :'),
                // Text preceding the TextFormField
                SizedBox(width: 40),
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
                        return "Enter Purpose";
                      }
                    },
                    controller: _ResonCntroller,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.02),
            child: Row(
              children: [
                Text('Total Days :'),
                // Text preceding the TextFormField
                SizedBox(width: 27),
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
                        return "Enter Total Days";
                      }
                    },
                    controller: _TotalDaysController,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.02),
            child: Row(
              children: [
                Text('Total Amount :'),
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
                        return "Enter Total Amount";
                      }
                    },
                    controller: _TotalAmountController,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:  EdgeInsets.only(top: screenHeight*0.02),
            child: Row(
              children: [
                Text('Date Dep. of Trip:'),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: Text('Departure.'),
                ),

                Padding(
                  padding:  EdgeInsets.all(screenWidth*0.01),
                  child: Text(_selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                      : 'no date selceted',
                  ),
                )
              ],

            ),
          ),

          Row(
            children: [
              Text('Date Arivval of Trip:'),
              SizedBox(width: 3),
              ElevatedButton(
                onPressed: _SelcetDate1,
                child: Text('Arrival.'),
              ),
              SizedBox(width: 9),
              Text(_selcetedDate2 != null
                  ? DateFormat('yyyy-MM-dd').format(_selcetedDate2!)
                  : 'No date seleceted',
              ),
            ],
          ),



          Column(
            children: [
              SizedBox(width: 1,),
              CheckboxListTile(
                title: Text('Need Ticket?'), value: _ticketchecked,
                onChanged: (value) {
                  setState(() {
                    _ticketchecked = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(width: 1,),
              CheckboxListTile(
                title: Text('Hotel'),
                value: _Hotelchecked,
                subtitle: Text('need to uplod the Bill'),
                onChanged: (value) {
                  setState(() {
                    _Hotelchecked = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                secondary: _Hotelchecked ? ElevatedButton(
                  onPressed: _UplodeFilePicker,
                  child: Text('Upload Bill'),)
                    : null,

              ),
              SizedBox(width: 1,),
              CheckboxListTile(
                title: Text('Patrol/Taxi'),
                value: _patrolTaxichecked,
                subtitle: Text('need to uplod the Bill'),
                onChanged: (value) {
                  setState(() {
                    _patrolTaxichecked = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                secondary: _patrolTaxichecked ? ElevatedButton(
                  onPressed: _UplodeFilePicker,
                  child: Text('Upload Bill'),)
                    : null,

              ),
              SizedBox(width: 1,),
              CheckboxListTile(
                title: Text('Extra Bill'),
                value: _Billchecked,
                subtitle: Text('need to uplod the Bill'),
                onChanged: (value) {
                  setState(() {
                    _Billchecked = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                secondary: _Billchecked ? ElevatedButton(
                  onPressed: _UplodeFilePicker,
                  child: Text('Upload Bill'),)
                    : null,
              ),

            ],


          ),ElevatedButton(

            onPressed: widget.onFormSubmitted,
            child: Text('Submit',
              style: TextStyle(
                fontSize: 16,
              ),),
          ),
        ],

      ),

    );
    }
  }
