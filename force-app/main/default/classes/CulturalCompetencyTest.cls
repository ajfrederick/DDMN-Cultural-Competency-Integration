/**
 * @name CulturalCompetencyTest
 * @description Test class for Cultural Competency API
 * 
 * @author Andrew Frederick (Creed Interactive) July 2022
 */
@IsTest
public class CulturalCompetencyTest {

    private static RecordTypeUtil contactRecordTypeUtil = new RecordTypeUtil( new Contact() );
    private static final String CONTACT_RECORD_TYPE = 'Provider_ddmn';
    private static final Id CONTACT_RECORD_TYPE_ID = contactRecordTypeUtil.getRecordTypeId( CONTACT_RECORD_TYPE );

    @TestSetup
    static void makeProvider(){

        Contact contact = new Contact();
        contact.RecordTypeId = CONTACT_RECORD_TYPE_ID;
        contact.FirstName = 'Test';
        contact.LastName = 'Tester';
        contact.Provider_No__c = '123';

        insert contact;
    }
    
    @IsTest
    public static void testCulturalCompetency(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        CulturalCompetencyRestServiceHelper.ClientSideData clientSideData = getClientSideData();
        
        req.requestURI = 'services/apexrest/cases/cultural-competency';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf( JSON.serialize(clientSideData) );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

            CulturalCompetencyRestService.create();

        Test.stopTest();

        Contact[] providers = [SELECT Id FROM Contact WHERE Provider_No__c = :clientSideData.providerNo];

        Case[] culturalCompetencyCases = [SELECT Id, Provider_Name__c FROM Case];

        System.assertEquals( providers[0].Id, culturalCompetencyCases[0].Provider_Name__c);
    }

    private static CulturalCompetencyRestServiceHelper.ClientSideData getClientSideData(){
        CulturalCompetencyRestServiceHelper.ClientSideData clientSideData = new CulturalCompetencyRestServiceHelper.ClientSideData();
        clientSideData.firstName = 'Test';
        clientSideData.lastName = 'Tester';
        clientSideData.contactFirstName = 'Test';
        clientSideData.contactLastName = 'Tester';
        clientSideData.npiNo = '123';
        clientSideData.providerNo = '123';

        clientSideData.clinicName = 'Test Clinic';
        clientSideData.streetAddress = '123 Spring Ave';
        clientSideData.city = 'Chanhassen';
        clientSideData.state = 'MN';
        clientSideData.zip = '55317';
        clientSideData.phone = '952-555-5555';
        clientSideData.email = 'test@test.com';
        clientSideData.websiteUrl = 'test.com';

        clientSideData.trainingDate = '2022/9/1';
        clientSideData.digitalSignature = 'true';

        clientSideData.acceptingNewPatients = 'true';
        clientSideData.officeAccessible = 'true';
        clientSideData.examRoomsAccessible = 'true';
        clientSideData.equipmentAccessible = 'true';

        clientSideData.trainingStatus = 'Yes';
        clientSideData.culturalAwareness = 'true';
        clientSideData.culturalSafety = 'true';
        clientSideData.culturalCompliance = 'true';
        
        return clientSideData;
    } 
}