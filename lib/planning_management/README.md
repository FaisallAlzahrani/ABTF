# Planning Management Module

## Overview
The Planning Management Module is designed to streamline the workflow for the Planning Department when creating and managing work orders with their associated ROUTECARD PDF files. This module integrates with the Inspection Management Module to provide a complete end-to-end solution for post-fabrication inspection processes.

## Key Features
- **Work Order Creation**: Create new work orders with detailed information
- **PDF Upload & Processing**: Upload ROUTECARD PDF files and automatically split them into individual inspection sheets
- **Work Order Management**: View, filter, and manage work orders
- **Inspection Sheet Viewing**: View individual inspection sheets and add inspection data
- **Status Tracking**: Track the status of work orders and inspection sheets

## Module Structure
The module is organized into the following directories:
- `models/`: Data models for planning work orders
- `screens/`: UI screens for different module functionalities
- `widgets/`: Reusable UI components
- `services/`: Business logic and data services, including PDF processing

## Workflow
1. **Work Order Creation**:
   - Planning Department creates a new work order by entering basic information (work order number, project name, item description, quantity)
   - They upload the ROUTECARD PDF file associated with that work order
   - The system automatically splits the PDF into individual pages and stores each page as a separate, editable inspection sheet

2. **Work Order Management**:
   - Planning Department can view all work orders and filter them by status
   - They can update the status of work orders as needed
   - They can view the details of each work order, including all inspection sheets

3. **Inspection Sheet Management**:
   - Planning Department can view individual inspection sheets
   - They can add inspection data to each sheet
   - They can track the status of each inspection sheet

## Integration with Inspection Management
The Planning Management Module is fully integrated with the Inspection Management Module, providing a seamless workflow:
- Work orders created in the Planning Module are available for inspection in the Inspection Module
- Inspection results entered in the Inspection Module are reflected in the Planning Module
- Both modules share the same database structure for consistent data access

## Technical Implementation
- **PDF Processing**: Uses the `pdf_split_merge` package to split PDF files into individual pages
- **Data Storage**: Firebase Firestore for structured data and Firebase Storage for PDF files
- **Authentication**: Integrated with the existing app authentication system
- **UI/UX**: Follows the app's existing design language

## User Roles and Access
- **Planning Department**: Full access to create and manage work orders
- **Inspectors**: Access to view work orders and enter inspection data
- **Administrators**: Full access to all features

## Future Enhancements
- Batch processing for multiple work orders
- Advanced search and filtering options
- Integration with ERP systems
- Automated notifications for status changes
- Analytics dashboard for tracking inspection metrics
