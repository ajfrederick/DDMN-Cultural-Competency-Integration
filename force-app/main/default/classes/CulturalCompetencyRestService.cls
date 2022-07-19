/**
 * @name CulturalCompetencyRestService
 * @description api endpoint for DDMN WebApps Cultural Competency Training Attestation
 */
@RestResource(urlMapping='/cases/cultural-competency')
global without sharing class CulturalCompetencyRestService {
   
/**
 * REST SERVICE METHOD
 */

    /**
     * @name create
     * @description actual method that gets called when endpoint is reached
     * @param none
     * @return none
     */
    @HttpPost
    global static void create(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        CulturalCompetencyRestServiceHelper helper = getHelper( request.requestBody.toString() );

        Case caseObj = createCase( helper );

        if( caseObj == null || caseObj.Id == null ){
            return;
        }
        
        response.statusCode = 201;
        response.responseBody = Blob.valueOf( JSON.serialize( caseObj ) );
    }

/**
 * ACTION METHODS
 */

    /**
     * @name parseRequest
     * @description parses the raw JSON into a typed class outlined at the bottom of this class.
     * Also handles any errors in case the raw JSON is formed unexpectedly.
     * @param String caseJSON
     * @return ClientData
     */
    private static CulturalCompetencyRestServiceHelper getHelper( String caseJSON ){
        if( String.isBlank( caseJSON ) ){ return null; }

        CulturalCompetencyRestServiceHelper helper;

        try {

            helper = new CulturalCompetencyRestServiceHelper( caseJSON );

        } catch( Exception e ){

            creedint.CreedExceptionHandler handler = new creedint.CreedExceptionHandler( e );
            handler.addMessage('Malformed Training Attestion Reqeust: ' + caseJSON );
            handler.handle();

            ErrorResponse error = new ErrorResponse( 'Malformed Reqeust: ' + e.getMessage() );
            error.details = caseJSON;

            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf( JSON.serialize( error ) );
        }

        return helper;
    }

    /**
     * @name createCase
     * @description inserts the case and handles any errors
     * @param CulturalCompetencyRestServiceHelper helper
     * @return none
     */
    private static Case createCase( CulturalCompetencyRestServiceHelper helper ){
        if( helper == null ){ return null; }
  
        Case caseObj = helper.getCase();

        try {

            insert caseObj;

        } catch( Exception e ){
            String caseJSON = helper.getRequestJSON();

            creedint.CreedExceptionHandler handler = new creedint.CreedExceptionHandler( e );
            handler.addMessage('Training Attestation\'s Case Detail: ' + caseJSON );
            handler.handle();

            ErrorResponse error = new ErrorResponse( 'Insert Operation Failed: ' + e.getMessage() );
            error.details = caseJSON;

            RestContext.response.statusCode = 501;
            RestContext.response.responseBody = Blob.valueOf( JSON.serialize( error ) );
        }

        return caseObj;
    }

/**
 * CLASSES
 */

    public class ErrorResponse {
            
        public String message {get;set;}
        public String details {get;set;}

        public ErrorResponse( String m ){
            message = m;
        }
    }

    public class RestServiceException extends Exception {}
}
