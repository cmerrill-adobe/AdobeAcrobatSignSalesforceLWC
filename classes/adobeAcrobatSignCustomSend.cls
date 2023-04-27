public with sharing class adobeAcrobatSignCustomSend {
    // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-    
    //  Return list of agreement templates to display in button menu.
    @AuraEnabled
    public static List<echosign_dev1__Agreement_Template__c> templates( string recordId ) {
        return [SELECT Id, Name 
                FROM echosign_dev1__Agreement_Template__c
                WHERE echosign_dev1__Master_Object_Type__c = :objectName( recordId )
                ORDER BY name];
    }    
    // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-    
    //  Find Name of object based on record ID. 
    //  Used to make the component easily available to all objects, not just standard   
    @TestVisible
    private static string objectName( String recordId ){
        if( recordId != null && recordId != '' ) {
            for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
                if(obj.getDescribe().getKeyPrefix() == recordId.substring(0,3)){
                    return obj.getDescribe().getName();
                }
            }            
        }
        return null;
    }    
    // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-   
    //  Return field name so that agreements will show up in component list.
    @TestVisible
    private static string objectLabel( String recordId ) {
        switch on objectName(recordId) {
            when 'Opportunity' { return 'echosign_dev1__Opportunity__c'; }
            when 'Contact' { return 'echosign_dev1__Recipient__c'; }
            when 'Account' { return 'echosign_dev1__Account__c'; }

            when else { return ''; }
        }
    }
    // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-    
    //  Create agreement using Adobe Sign package
    @AuraEnabled
    public static id createAgreement( id templateId, id recordId ) {
        
        Map<String, String> runtimeVariables = new Map<String, String>();
        
        for( echosign_dev1__Recipient_Template__c rt : [SELECT echosign_dev1__Agreement_Template__c,echosign_dev1__Type__c,echosign_dev1__Variable_Name__c FROM echosign_dev1__Recipient_Template__c WHERE echosign_dev1__Type__c = 'Runtime Variable' AND echosign_dev1__Agreement_Template__c = :templateId] ) {
            runtimeVariables.put( rt.echosign_dev1__Variable_Name__c,'' );
        }
        
        for( echosign_dev1__Attachment_Template__c ft : [SELECT echosign_dev1__Agreement_Template__c,echosign_dev1__Type__c,echosign_dev1__Variable_Name__c FROM echosign_dev1__Attachment_Template__c WHERE echosign_dev1__Type__c = 'Runtime Variable' AND echosign_dev1__Agreement_Template__c = :templateId] ) {
            runtimeVariables.put( ft.echosign_dev1__Variable_Name__c,'' );
        }
        
        // :..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:
        // use custom apex to get and set values of runtime variables.
        if( runtimeVariables.containsKey('signerOne') ) runtimeVariables.put( 'signerOne','0035c00002SSQ6GAAX' );
        if( runtimeVariables.containsKey('signerTwo') ) runtimeVariables.put( 'signerTwo','0035c00002bru80AAA' );
        // :..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:..:
        
        if( !runtimeVariables.isEmpty() ) {
            return createAgreementRuntime( templateId, recordId, runtimeVariables );
        } else {
            return echosign_dev1.AgreementTemplateService.load(templateId, recordId);
        }
    }  
    // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-    
    //  Create agreement using Adobe Sign package with runtime variables.
    @AuraEnabled
    public static Id createAgreementRuntime(Id templateId, Id recordId, Map<String, String> runtimeVariables) {
        
        Map<String, echosign_dev1.AgreementTemplateVariable> runtimeVariablesMap = new Map<String, echosign_dev1.AgreementTemplateVariable>();
        
        for (String key : runtimeVariables.keySet()) {
            echosign_dev1.AgreementTemplateVariable runtimeVariable = new echosign_dev1.AgreementTemplateVariable(key, runtimeVariables.get(key));
            runtimeVariablesMap.put(key, runtimeVariable);
        }
        
        return echosign_dev1.AgreementTemplateService.load(templateId, recordId, runtimeVariablesMap);
    }
    
    // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-    
    //  List agreements to display in component.     
    @AuraEnabled
    public static List<echosign_dev1__SIGN_Agreement__c> agreements( string recordId ) {

        List<echosign_dev1__SIGN_Agreement__c> response = new List<echosign_dev1__SIGN_Agreement__c>();
        string objLabel = objectLabel(recordId);

        if( objLabel != '' ) {
            string query =  'SELECT Id, Name, echosign_dev1__StatusVisible__c, echosign_dev1__DateSent__c, echosign_dev1__Recipient__r.Id, echosign_dev1__Recipient__r.Name, echosign_dev1__Account__r.Id, echosign_dev1__Account__r.Name, ' +
                            'echosign_dev1__Result__c, echosign_dev1__Merge_Mapping_Error__c, echosign_dev1__Data_Mapping_Error__c, echosign_dev1__Signing_URL__c, echosign_dev1__DateSigned__c, echosign_dev1__Document__c ' +
                            'FROM echosign_dev1__SIGN_Agreement__c ' +
                            'WHERE ' + objLabel + ' = \'' + recordId + '\' ORDER BY LastModifiedDate DESC ';
            response = database.query( query );                
        }                       
        return response;
    }
    // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-    
}