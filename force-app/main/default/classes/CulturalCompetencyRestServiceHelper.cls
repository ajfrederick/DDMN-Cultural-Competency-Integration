/**
 * @name CulturalCompetencyRestServiceHelper
 * @description helper class for CulturalCompetencyRestService.cls
 */
public without sharing class CulturalCompetencyRestServiceHelper {

/**
 * FIELDS
 */

    private Case caseObj {
        get {
            
            if( caseObj == null ){
                caseObj = getBaseCase();
            }

            return caseObj;
        }
        set;
    }

    private ClientSideData data {get;set;} 

    private static RecordTypeUtil caseRecordTypeUtil = new RecordTypeUtil( new Case() );
    private static RecordTypeUtil contactRecordTypeUtil = new RecordTypeUtil( new Contact() );

    private static final String CASE_RECORD_TYPE = 'Cultural_Competency';
    private static final String CONTACT_RECORD_TYPE = 'Provider_ddmn';

    private static final Id CASE_RECORD_TYPE_ID = caseRecordTypeUtil.getRecordTypeId( CASE_RECORD_TYPE );
    private static final Id CONTACT_RECORD_TYPE_ID = contactRecordTypeUtil.getRecordTypeId( CONTACT_RECORD_TYPE );

/**
 * CONSTRUCTOR
 */

    public CulturalCompetencyRestServiceHelper( String requestJSON ){
        data = (ClientSideData) JSON.deserialize( requestJSON, ClientSideData.class );
    }

/**
 * ACTION METHODS
 */

    public Case getCase(){

        setProviderDetials();
        setCompetencyDetails();

        return caseObj;
    }

    private Case getBaseCase(){
        return new Case(
            RecordTypeID = CASE_RECORD_TYPE_ID,
            Subject = getSubject(),
            Description = getDescription(),
            Type = 'Compliance',
            Sub_type__c = 'Cultural Competency',
            Origin = 'Web',
            Priority = 'Low'
        );
    }

    private void setProviderDetials(){
        Id contactId = getContactId();

        caseObj.ContactId = contactId;
        caseObj.Provider_Name__c = contactId;
        caseObj.Cultural_Competency_Contact_Name__c = data.contactFirstName + ' ' + data.contactLastName;

        caseObj.Npi_No__c = data.npiNo;
        caseObj.Provider_No__c = data.providerNo;

        caseObj.Clinic_Name__c = data.clinicName;
        caseObj.Address__c = getAddress();
        caseObj.SuppliedPhone = data.phone;
        caseObj.Email__c = data.email;
    }

    private void setCompetencyDetails(){
        caseObj.Training_Date__c = getTrainingDate();
        caseObj.Digital_Signature__c = getBooleanValue(data.digitalSignature);

        caseObj.Accepting_New_Patients__c = getBooleanValue(data.acceptingNewPatients);
        caseObj.Office_Accessible__c = getBooleanValue(data.officeAccessible);
        caseObj.Exam_Rooms_Accessible__c = getBooleanValue(data.examRoomsAccessible);
        caseObj.Equipment_Accessible__c = getBooleanValue(data.equipmentAccessible);

        caseObj.Staff_Training_Complete__c = data.trainingStatus;
        caseObj.Cultural_Awareness_Capability__c = getBooleanValue(data.culturalAwareness);
        caseObj.Cultural_Safety_Capability__c = getBooleanValue(data.culturalSafety);
        caseObj.Cultural_Compliance_Capability__c = getBooleanValue(data.culturalCompliance);
    }

    public String getRequestJSON(){
        return JSON.serialize( data );
    }

/**
 * UTILITY METHODS
 */

    private String getSubject(){
        String subject = 'Cultural Competency Training Attestation Approval';

        if( !String.isBlank(data.contactFirstName) ){
            subject += ' - ' + data.contactFirstName + ' ' + data.contactLastName;
        } else 
        if( !String.isBlank(data.firstName) ){
            subject += ' - ' + data.firstName + ' ' + data.lastName;
        }

        return subject;
    }

    private String getAddress(){
        String address = getStringValue( data.streetAddress ) + '\n';
        address += getStringValue( data.city ) + ', ';
        address += getStringValue( data.state ) + ' ';
        address += getStringValue( data.zip );

        return address;
    }

    private Date getTrainingDate(){
        Date trainingDate;

        try {

            trainingDate = Date.valueOf( data.trainingDate );

        } catch( Exception e ){
            creedint.CreedExceptionHandler handler = new creedint.CreedExceptionHandler( e );
            handler.debug();
        }

        return trainingDate;
    }

    private String getDescription(){
        String description = 'Please review this attestation request and click \'Approve Training\' if everything is in order. Contact the provider as needed to confirm or clarify information.';

        return description;
    }


    private String getStringValue( String value ){
        return value != null ? value : '';
    }

    private Boolean getBooleanValue( String value ){
        value = value != null ? value : 'false';

        return Boolean.valueOf( value );
    }

/**
 * QUERY METHODS
 */

    private Id getContactId(){
        
        if( String.isBlank(data.providerNo) ){ return null; }

        Contact[] contacts = new Contact[]{};

        try {

            contacts.addAll([SELECT
                                Id
                                    FROM Contact
                                    WHERE Provider_No__c = :data.providerNo
                                    AND RecordTypeId = :CONTACT_RECORD_TYPE_ID]);

        } catch( Exception e ){
            creedint.CreedExceptionHandler handler = new creedint.CreedExceptionHandler( e );
            handler.debug();
        }

        Id contactId = !contacts.isEmpty() ? contacts[0].Id : null;

        return contactId;
    }

/**
 * DATA FORMATS
 */

    public class ClientSideData {
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String contactFirstName {get;set;}
        public String contactLastName {get;set;}
        public String npiNo {get;set;}
        public String providerNo {get;set;}

        public String clinicName {get;set;}
        public String streetAddress {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String zip {get;set;}
        public String phone {get;set;}
        public String email {get;set;}
        public String websiteUrl {get;set;}

        public String trainingDate {get;set;}
        public String digitalSignature {get;set;}

        public String acceptingNewPatients {get;set;}
        public String officeAccessible {get;set;}
        public String examRoomsAccessible {get;set;}
        public String equipmentAccessible {get;set;}

        public String trainingStatus {get;set;}
        public String culturalAwareness {get;set;}
        public String culturalSafety {get;set;}
        public String culturalCompliance {get;set;}
    }

    public class RestServiceException extends Exception {}
}
