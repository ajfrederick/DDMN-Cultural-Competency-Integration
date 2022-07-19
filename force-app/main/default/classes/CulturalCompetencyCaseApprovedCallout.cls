/**
 * @name CulturalCompetencyCaseApprovedCallout
 * @description this class holds invocable methods for the Cultral Competency Approval Flow which is invoked by a button on the
 * Cultural Competency Case Layout.
 * 
 * It sends the case information to DDMN webapps for processing and updating within there on MongoDB database. It also handles
 * any errors from the flow.
 * 
 * @author Creed Interactive (Andrew Frederick) 9/29/21
**/
public class CulturalCompetencyCaseApprovedCallout {

/**
 * FIELDS
**/

    private static final String DEV_ENDPOINT = 'https://qa-services3.deltadentalmn.org/svc3009/attest/approveAttestation'; 
    private static final String PROD_ENDPOINT = 'https://services3.deltadentalmn.org/svc3009/attest/approveAttestation';

/**
 * INVOCABLE METHODS
**/

    /**
     * @name send
     * @description called by Cultural Competency Flow
     * @return void
    **/
    @InvocableMethod( label='Send Case to Webapps' description='For Cultural Competency Flow. Makes an http callout to DDMN webapps to store data in their database.' )
    public static void send( Id[] caseIds ) {
        if( caseIds.isEmpty() ){ return; }

        send( caseIds[0], System.UserInfo.getUserName() );
    }
    
    /**
     * @name send
     * @description sends the caseId to webapps node server. Webapps server then calls into Salesforce as a database to get info about
     * case. 
     * 
     * @param Id caseId
     * @param String userName
     * @return void
    **/
    @future(callout=true)
    public static void send( Id caseId, String userName ){
        String endpoint = getEndpoint() + '/' + caseId; 

        Http http = new Http();

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        try {

            HttpResponse response = http.send(request);

            // 400 and above are error codes
            if( response.getStatusCode() >= 400 ){
                throw new HttpResponseException( response.toString() );
            }

        } catch( Exception e ){
            creedint.CreedExceptionHandler handler = new creedint.CreedExceptionHandler( e );
            handler.handle();
        }
    }

    /**
     * @name getEndpoint
     * @description 
     * @param none
     * @return Boolean
    **/
    private static String getEndpoint(){
        return Constants.IS_DEV ? DEV_ENDPOINT : PROD_ENDPOINT;
    }

/**
 * CLASSES
**/

    public class HttpResponseException extends Exception {}
}