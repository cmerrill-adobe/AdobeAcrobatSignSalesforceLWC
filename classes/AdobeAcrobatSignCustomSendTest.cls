@isTest
public class AdobeAcrobatSignCustomSendTest {

    @isTest
    static void testTemplates() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create a test agreement template
        echosign_dev1__Agreement_Template__c testTemplate = new echosign_dev1__Agreement_Template__c(
            Name = 'Test Template',
            echosign_dev1__Master_Object_Type__c = 'Account'
        );
        insert testTemplate;
        
        // Test the templates method
        Test.startTest();
        List<echosign_dev1__Agreement_Template__c> templates = adobeAcrobatSignCustomSend.templates(testAccount.Id);
        Test.stopTest();
        
        // Assert that the method returns the correct template
        System.assertEquals(1, templates.size());
        System.assertEquals(testTemplate.Id, templates[0].Id);
    }


    @isTest
    static void testObjectName() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test the objectName method
        Test.startTest();
        String objectName = adobeAcrobatSignCustomSend.objectName(testAccount.Id);
        Test.stopTest();

        // Assert that the method returns the correct object name
        System.assertEquals('Account', objectName);
    }

    @isTest
    static void testObjectLabel() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test the objectLabel method
        Test.startTest();
        String objectLabel = adobeAcrobatSignCustomSend.objectLabel(testAccount.Id);
        Test.stopTest();

        // Assert that the method returns the correct object label
        System.assertEquals('echosign_dev1__Account__c', objectLabel);
    }

    @isTest
    static void testAgreements() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test agreement
        echosign_dev1__SIGN_Agreement__c testAgreement = new echosign_dev1__SIGN_Agreement__c(
            Name = 'Test Agreement',
            echosign_dev1__Account__c = testAccount.Id
        );
        insert testAgreement;

        // Test the agreements method
        Test.startTest();
        List<echosign_dev1__SIGN_Agreement__c> agreements = adobeAcrobatSignCustomSend.agreements(testAccount.Id);
        Test.stopTest();

        // Assert that the method returns the correct agreement
        System.assertEquals(1, agreements.size());
        System.assertEquals(testAgreement.Id, agreements[0].Id);
    }

    @isTest
    static void testCreateAgreement() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    
        // Create a test agreement template
        echosign_dev1__Agreement_Template__c testTemplate = new echosign_dev1__Agreement_Template__c(
            Name = 'Test Template',
            echosign_dev1__Master_Object_Type__c = 'Account'
        );
        insert testTemplate;
    
        // Test the createAgreement method
        Test.startTest();
        Id agreementId = adobeAcrobatSignCustomSend.createAgreement(testTemplate.Id, testAccount.Id);
        Test.stopTest();
    
        // Assert that the method creates an agreement
        System.assertNotEquals(null, agreementId);
    }
    
    @isTest
    static void testCreateAgreementRuntime() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    
        // Create a test agreement template
        echosign_dev1__Agreement_Template__c testTemplate = new echosign_dev1__Agreement_Template__c(
            Name = 'Test Template',
            echosign_dev1__Master_Object_Type__c = 'Account'
        );
        insert testTemplate;
    
        // Create runtime variables
        Map<String, String> runtimeVariables = new Map<String, String>();
        runtimeVariables.put('signerContactID', '0035c00002SSQ6GAAX');
        runtimeVariables.put('signerTwo', '0035c00002bru80AAA');
    
        // Test the createAgreementRuntime method
        Test.startTest();
        Id agreementId = adobeAcrobatSignCustomSend.createAgreementRuntime(testTemplate.Id, testAccount.Id, runtimeVariables);
        Test.stopTest();
    
        // Assert that the method creates an agreement
        System.assertNotEquals(null, agreementId);
    }

}
