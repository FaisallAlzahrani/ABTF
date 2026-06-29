import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class TicketDetailsReports extends StatelessWidget {
  final QueryDocumentSnapshot ticket;
  double screenHeight = 0;
  double screenWidth = 0;

  TicketDetailsReports({required this.ticket});

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final ticketData = ticket.data() as Map<String, dynamic>;

    const brandColor = Color(0xFF104164);
    final String reqNumber = '${ticketData['Requisition Number'] ?? ''}';

    Widget infoRow({required String label, required String value}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.70),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: brandColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget sectionCard({required String title, required IconData icon, required Widget child}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.lightBlue[50],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: brandColor.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: brandColor.withOpacity(0.12)),
                  ),
                  child: Icon(icon, color: brandColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: brandColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: brandColor),
        title: const Text(
          'Ticket Details',
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double contentWidth = maxWidth.clamp(0, 900);
          final double padding = (maxWidth * 0.04).clamp(12.0, 20.0);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(padding, 12, padding, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[50],
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: brandColor.withOpacity(0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: brandColor.withOpacity(0.12)),
                                  ),
                                  child: const Icon(Icons.receipt_long_outlined, color: brandColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Requisition #$reqNumber',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: brandColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Final report view (PDF available)',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.55),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          sectionCard(
                            title: 'Ticket Info',
                            icon: Icons.info_outline,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                infoRow(label: 'Factory', value: '${ticketData['Factory'] ?? 'N/A'}'),
                                infoRow(label: 'Section', value: '${ticketData['Section'] ?? 'N/A'}'),
                                infoRow(label: 'Machine Equipment', value: '${ticketData['machineEquipment'] ?? 'N/A'}'),
                                infoRow(label: 'Serial No', value: '${ticketData['Serial Number'] ?? 'N/A'}'),
                                infoRow(label: 'Priority', value: '${ticketData['Priority'] ?? 'N/A'}'),
                                infoRow(label: 'Reported By', value: '${ticketData['Reported_By'] ?? 'N/A'}'),
                                infoRow(label: 'Reported Date/Time', value: '${ticketData['Date_Time'] ?? 'N/A'}'),
                                infoRow(label: 'Received By', value: '${ticketData['RecevedBy'] ?? 'N/A'}'),
                                infoRow(label: 'Received Date/Time', value: '${ticketData['Date_Time2'] ?? 'N/A'}'),
                                const SizedBox(height: 6),
                                Text(
                                  'Trouble Description',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.72),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${ticketData['TroubleDescription'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.75),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          sectionCard(
                            title: 'Maintenance Details',
                            icon: Icons.engineering_outlined,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Analysis of work to be done',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.72),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${ticketData['AnalysisOfWorkToBeDone'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.75),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Repair & work done',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.72),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${ticketData['RepairWorkDone'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.75),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Remarks & recommendations',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.72),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${ticketData['RemarksAndRecom'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.75),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                infoRow(label: 'Type of Services', value: '${ticketData['TypeOfServices'] ?? 'N/A'}'),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    Text(
                                      'No. of break dawn Hours: ${ticketData['NoOfBreackDawnHours']}',
                                      style: TextStyle(fontSize: screenHeight*0.017),
                                    ),
                                    Text(
                                      'Q.C checked if (Required: ${ticketData['QcChecked']}',
                                      style: TextStyle(fontSize: screenHeight*0.017),
                                    ),
                                    Text(
                                      'No .Of Reparing Hours: ${ticketData['NoOfReparingHours']}',
                                      style: TextStyle(fontSize: screenHeight*0.017),
                                    ),
                                    Text(
                                      'Prepared By: ${ticketData['PreapardBY']}',
                                      style: TextStyle(fontSize: screenHeight*0.017),
                                    ),
                                    Text(
                                      'Cost of Consumed Materials: ${ticketData['CostOfCunsumedMaterials']}',
                                      style: TextStyle(fontSize: screenHeight*0.017),
                                    ),
                                    Text(
                                      'Cost Of Consumed ManHours: ${ticketData['CostOfConsumedManHours']}',
                                      style: TextStyle(fontSize: screenHeight*0.017),
                                    ),
                                    Text(
                                      'Total Cost Of Services: ${ticketData['ToCoOfServices']}',
                                      style: TextStyle(fontSize: screenHeight*0.017),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          sectionCard(
                            title: 'Consumed Spare Parts & Materials',
                            icon: Icons.construction_outlined,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildTable(ticketData['TableData1'] ?? []),
                            ),
                          ),
                          const SizedBox(height: 14),
                          sectionCard(
                            title: 'Consumed Man Hours',
                            icon: Icons.access_time,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildTable1(ticketData['TableData2'] ?? ['No.','Crew Name','I.Do.No','No.Of Hrs','Rate/Hrs','Total Cost']),
                            ),
                          ),
                          const SizedBox(height: 14),
                          sectionCard(
                            title: 'Approvals',
                            icon: Icons.verified_outlined,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                Text(
                                  'Approved By: ${ticketData['status3'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: screenHeight*0.017),
                                ),
                                Text(
                                  'Approved Date / Time: ${ticketData['Data_Time3']}',
                                  style: TextStyle(fontSize: screenHeight*0.017),
                                ),
                                Text(
                                  'Received After Repair Completion: ${ticketData['status4'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: screenHeight*0.017),
                                ),
                                Text(
                                  'Received Date / Time: ${ticketData['Data_Time4']}',
                                  style: TextStyle(fontSize: screenHeight*0.017),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(padding, 8, padding, 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _generatePDF(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Generate PDF',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  // Function to create a table for spare parts/materials or man hours
  Widget _buildTable(List data) {
    if (data.isEmpty) {
      return Text('No data available');
    }
    return Table(
      border: TableBorder.all(width: 1.0, color: Colors.black),
      children: [
        TableRow(
          children: [
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                child: Text('No.',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.005,left: screenHeight*0.001,bottom: screenHeight*0.001,top: screenHeight*0.001),
                child: Text('Material Description',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.03,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.002),
                child: Text('Unit',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.03,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.002),
                child: Text('Qty',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.03,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.002),
                child: Text('U.Price',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding:EdgeInsets.only(right: screenHeight*0.03,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.002),
                child: Text('Total Cost',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ),
        ...data.map<TableRow>((item) {
          return TableRow(
            children: [
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['No_table1'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['Materialdescription_table'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['unit_table'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['Qty_table'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['U.Price_table'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['TotalCost_table1'] ?? 'N/A'))),
            ],
          );
        }).toList(),
      ],
    );
  }
  Widget _buildTable1(List data) {
    if (data.isEmpty) {
      return Text('No data available');
    }print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
    return Table(
      border: TableBorder.all(width: 1.0, color: Colors.black),
      children: [
        TableRow(
          children: [
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                child: Text('No.',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                child: Text('Crew Name',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                child: Text('Unit',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                child: Text('Qty',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                child: Text('U.Price',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                child: Text('Total Cost',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ),
        ...data.map<TableRow>((item) {
          return TableRow(
            children: [
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['No_table2'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['Crew_Name_table2'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['I.D.No_table2'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['No.OfHrs_table2'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['Rate/Hrs_table2'] ?? 'N/A'))),
              TableCell(child: Padding(padding: EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: Text(item['TotalCost2'] ?? 'N/A'))),
            ],
          );
        }).toList(),
      ],
    );
  }

  // PDF generation function
  void _generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    final ticketData = ticket.data() as Map<String, dynamic>;
    final imageData = await rootBundle.load('assest/images/r2.png');
    final image = pw.MemoryImage(imageData.buffer.asUint8List());

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
        return pw.Padding(
          padding: pw.EdgeInsets.all(2),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Text('Requisition #: ${ticketData['Requisition Number']}',
                  style: pw.TextStyle(
                      fontSize: 10.0, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Container(
             padding: pw.EdgeInsets.only(top: screenHeight*0.01,bottom: screenHeight*0.013,right: screenHeight*0.02,left: screenHeight*0.01),
             decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0),
              borderRadius: pw.BorderRadius.circular(10),
              color: PdfColors.grey200,
            ),
                  child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Image(image,width: screenHeight*0.09,height: screenHeight*0.05),
                  pw.Text('Tower Factory Requisition For Maintenance Services',
                      style: pw.TextStyle(fontSize: screenHeight*0.0096,
                          fontWeight: pw.FontWeight.bold)),

                ]
              )
              ),
              // First Container
              pw.SizedBox(height: 4),
              pw.Container(
                padding: pw.EdgeInsets.only(top: screenHeight*0.01,bottom: screenHeight*0.013,right: screenHeight*0.02,left: screenHeight*0.01),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0),
                  borderRadius: pw.BorderRadius.circular(10),
                  color: PdfColors.grey200,
                ),

                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Factory: ${ticketData['Factory']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Section: ${ticketData['Section']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                            'Machine Equipment: ${ticketData['machineEquipment']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Serial NO.: ${ticketData['Serial Number']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Divider(),

                    pw.Text(
                        'Trouble Description: ${ticketData['TroubleDescription'] ?? ''}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 11.0)),
                    pw.Text('Priority: ${ticketData['Priority'] ?? ''}',
                        style: pw.TextStyle(
                            fontSize: 11.0, fontWeight: pw.FontWeight.bold)),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Reported By: ${ticketData['Reported_By']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date/Time: ${ticketData['Date_Time']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Receved By: ${ticketData['RecevedBy']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date/Time: ${ticketData['Date_Time2']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Divider(),
                    pw.SizedBox(width: 2000,height: 1),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Analysis Of Work to be Done: ',
                            style: pw.TextStyle(
                                fontSize: 11.0, fontWeight: pw.FontWeight.bold)),
                        pw.Text('${ticketData['AnalysisOfWorkToBeDone'] ?? ''}',
                            style: pw.TextStyle(fontSize: 11.0)),
                        pw.SizedBox(height: 9.0),
                        pw.Text('Repair & Work Done: ',
                            style: pw.TextStyle(
                                fontSize: 11.0, fontWeight: pw.FontWeight.bold)),
                        pw.Text('${ticketData['RepairWorkDone'] ?? ''}',
                            style: pw.TextStyle(fontSize: 11.0)),
                        pw.SizedBox(height: 9.0),
                        pw.Text('Remarks & Recommendations: ',
                            style: pw.TextStyle(
                                fontSize: 11.0, fontWeight: pw.FontWeight.bold)),
                        pw.Text('${ticketData['RemarksAndRecom'] ?? ''}',
                            style: pw.TextStyle(fontSize: 11.0)),
                      ],
                    ),
                    pw.Divider(),
                 pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Type Of Services: ${ticketData['TypeOfServices'] ??
                        ''}',
                        style: pw.TextStyle(
                            fontSize: 10.0, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    pw.Text('Financial Analysis:',
                        style: pw.TextStyle(
                            fontSize: 11.0, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text('Consumed Spare Parts & Materials Used:',
                        style: pw.TextStyle(
                            fontSize: 11.0, fontWeight: pw.FontWeight.bold)),pw.SizedBox(height: 3),
                    _buildPDFTable(ticketData['TableData1'] ?? []),
                    pw.SizedBox(height: 10),

                    pw.Text('Consumed Man Hours:',
                        style: pw.TextStyle(
                            fontSize: 11.0, fontWeight: pw.FontWeight.bold)),pw.SizedBox(height:3),
                    _buildPDFTable1(ticketData['TableData2'] ?? []),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('No.Of Break dawn Hours: ${ticketData['NoOfBreackDawnHours']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Q.c (if Required): ${ticketData['QcChecked']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('No.Of Repairing Hours: ${ticketData['NoOfReparingHours']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Prepared BY: ${ticketData['PreapardBY']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Cost Of Consumed Materials: ${ticketData['CostOfCunsumedMaterials']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Checked BY: ${ticketData['CheckedBy']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Cost Of Consumed ManHrs: ${ticketData['CostOfConsumedManHours']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Total Cost Of Services: ${ticketData['TotalofServices']}',
                            style: pw.TextStyle(fontSize: 11.0,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),

              ]     ),


        ),pw.SizedBox(height: 3),
          pw.Container(
            padding: pw.EdgeInsets.only(top: screenHeight*0.01,bottom: screenHeight*0.013,right: screenHeight*0.02,left: screenHeight*0.01),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0),
              borderRadius: pw.BorderRadius.circular(10),
              color: PdfColors.grey200,
            ),

            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Approves BY : ',
                  style: pw.TextStyle(fontSize: 11.0,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text(
                '${ticketData['status3'] ?? 'N/A'}',
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.Text('Data/Time: ${ticketData['Data_Time3']}',
                  style: pw.TextStyle(fontSize: 11.0,
                      fontWeight: pw.FontWeight.bold)),
            ]),


                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Received After Repair Completion : ',
                          style: pw.TextStyle(fontSize: 11.0,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        '${ticketData['status4'] ?? 'N/A'}',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                      pw.Text('Data/Time: ${ticketData['Data_Time4']}',
                          style: pw.TextStyle(fontSize: 11.0,
                              fontWeight: pw.FontWeight.bold)),
                    ]

                ),
              ]

            ),

          ),
              pw.Text('This document is certified and digitally signed.', style: pw.TextStyle(
                fontSize: screenHeight*0.006,fontWeight: pw.FontWeight.bold
              )),

            ],


          ),

        );

      },
    ));

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

// Helper function to create PDF tables
  pw.Widget _buildPDFTable(List data) {
    if (data.isEmpty) {
      return pw.Text('No data available');
    }print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');

    return pw.Table(
      border: pw.TableBorder.all(width: 1.0, color: PdfColors.black),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text(
                  'No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text('Material Description',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text(
                  'Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text(
                  'Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text('U.Price',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text('Total Cost',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        ...data.map<pw.TableRow>((item) {
          return pw.TableRow(
            children: [
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['No_table1'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['Materialdescription_table'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['unit_table'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['Qty_table'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['U.Price_table'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['TotalCost_table1'] ?? 'N/A')),
            ],
          );
        }).toList(),
      ],
    );
  }
  pw.Widget _buildPDFTable1(List data) {
    if (data.isEmpty) {
      return pw.Text('No data available');
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 1, color: PdfColors.black),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text(
                  'No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text('Crew Name',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text(
                  'I.Do.NO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text(
                  'No .Of Hrs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text('Rate/Hrs',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
              child: pw.Text('Total Cost',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        ...data.map<pw.TableRow>((item) {
          return pw.TableRow(
            children: [
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['No_table2'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['Crew_Name_table2'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['I.D.No_table2'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['No.OfHrs_table2'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['Rate/Hrs_table2'] ?? 'N/A')),
              pw.Padding(padding: pw.EdgeInsets.only(right: screenHeight*0.003,left: screenHeight*0.001,bottom: screenHeight*0.002,top: screenHeight*0.0002),
                  child: pw.Text(item['TotalCost2'] ?? 'N/A')),
            ],
          );
        }).toList(),
      ],
    );
  }
}
