public with sharing class LabOrderController {
    public Lab_Order__c labOrder {get; set;}
    
    public LabOrderController(){
        this.labOrder = new Lab_Order__c();
    }
    public PageReference saveAndSendEmail(){
        try{
           insert labOrder; 
            
            //Reference: https://www.linkedin.com/pulse/sending-email-attachment-using-process-builder-shweta-soparkar-/
            // Generate PDF 
           /*   PageReference pdfPage = Page.CreateLabOrderPDF; 
            pdfPage.getParameters().put('id', labOrder.Id);
            System.debug('Lab Order id'+labOrder.Id);
            Blob pdfBlob = pdfPage.getContentAsPDF();
           
            // Save the PDF as an attachment
            Attachment pdfAttachment = new Attachment();
            pdfAttachment.ParentId = labOrder.Id;
            pdfAttachment.Name = 'LabOrder_' + labOrder.Name + '.pdf';
            pdfAttachment.Body = pdfBlob;
            pdfAttachment.ContentType = 'application/pdf';
            pdfAttachment.IsPrivate = false;
           
            insert pdfAttachment; */
            
            //SOQL
            Contact patient = [Select Id, FirstName, Email from Contact Where Id = :labOrder.Patient_Id__c];
            System.debug('Patient Email: '+patient.Email);
            System.debug('Patient Id: '+patient.Id);
            
            Contact physician = [Select FirstName from Contact Where Id = :labOrder.Ordering_Physician__c];
            
            // Send email to the patient
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //Messaging.EmailFileAttachment attach= new Messaging.EmailFileAttachment();
            email.setToAddresses(new String[] { patient.Email });
            email.setSubject('Your Lab Order Details');
            String messageBody = '<html><body>Hi,'+patient.FirstName+'<br><br> Your lab order details is below: <br><br> Ordering Physician: '+physician.FirstName+'<br>Test Name: '+labOrder.Test_Name__c+'<br>Test Details: '+labOrder.Test_Details__c+'<br>Status: '+labOrder.Status__c+'<br><br>Thanks,<br>Senior Care Management System </body></html>';
            System.debug('Email body: '+messageBody);
            email.setHtmlBody(messageBody);
            //email.setPlainTextBody('Please find your lab order details attached.');
            //email.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            
            //Create a task for the patient to book a lab appointment
            Task task = new Task();
            task.Subject = 'Book Lab Appointment';
            task.Description = 'Please book an appointment for your lab test.';
            task.WhoId = patient.Id;
            //task.OwnerId = patient.Id;
            //task.WhatId = labOrder.Id;
            task.ActivityDate = Date.today();
            task.Status = 'Not Started';
            insert task;
            
            //System.debug('Task created for patient');
            
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        return new PageReference('https://akidev-d0-dev-ed.develop.lightning.force.com/'+labOrder.Id);
    }

}