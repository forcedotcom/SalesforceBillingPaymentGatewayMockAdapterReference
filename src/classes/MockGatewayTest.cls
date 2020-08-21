@isTest
private class MockGatewayTest {
    
    private static final String SUCCESS = 'SUCCESS';
    private static final String DECLINE = 'DECLINE';
    private static final String SUCCESSRESPONSECODE = '100';
    private static final String FAILURERESPONSECODE = '200';
    private static final String SUCCESSRESPONSECODEMESSAGE = 'Successful transaction';
    private static final String FAILURERESPONSECODEMESSAGE = 'Transaction failed';
    private static final String GENERATETOKEN = 'GenerateToken';
    private static final String CHARGETRANSACTION = 'ChargeTransaction';
    private static final String REFUND = 'Refund';
    
    /**
    * @name validateSuccessResponse
    * @description For a success GatewayToken transaction PaymentToken needs to be set
    * @return NA
    */
    private static void validateSuccessResponse(String transactionType,
        										Map<String, blng.TransactionResult> result) {
         for(String idToProcess : result.KeySet()) {
            blng.TransactionResult transactionResult = result.get(idToProcess);
        	validateCommonSuccessResponse(transactionResult);
            if (transactionType == GENERATETOKEN) {
        		System.assert(NULL != transactionResult.getPaymentToken()); 
        	} else {
            	System.assert(NULL != transactionResult.getGatewayId()); 
        	}
         }
    }
    
    /**
    * @name validateCommonSuccessResponse
    * @description NA
    * @return NA
    */
    private static void validateCommonSuccessResponse(blng.TransactionResult transactionResult) {
        System.assertEquals(true, transactionResult.getIsSuccess());
        System.assertEquals(blng.TransactionResult.GatewayStatusType.Success,
                            transactionResult.getGatewayStatus());
        System.assertEquals(SUCCESS, transactionResult.getResponseToValidate());
    }
    
    /**
    * @name validateFailureResponse
    * @description Validates failure response
    * @param status could be Decline/Indeterminate
    * @return NA
    */
    private static void validateFailureResponse(Map<String, blng.TransactionResult> result,
                                                blng.TransactionResult.GatewayStatusType status) {

    	for(String idToProcess : result.KeySet()) {
            blng.TransactionResult transactionResult = result.get(idToProcess);
            System.assertEquals(false, transactionResult.getIsSuccess());
        	System.assertEquals(status, transactionResult.getGatewayStatus());
            System.assertEquals(DECLINE, transactionResult.getResponseToValidate());
        }
	}                                               
    
    /**
    * @name testGenerateTokenSuccess
    * @description NA
    * @return NA
    */
    public static testMethod void testGenerateTokenSuccess() {
         Map<String, blng.TransactionParameter> mapOfTransactionParameterById =
             new Map<String, blng.TransactionParameter>();
        blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        transactionParameter.setPaymentMethod(paymentMethod);
        mapOfTransactionParameterById.put(transactionParameter.toString(), transactionParameter);
        
        Map<String, blng.TransactionResult> result = MockGateway.generateToken(mapOfTransactionParameterById);
        validateSuccessResponse(GENERATETOKEN, result);
    }
    
    /**
    * @name testGenerateTokenFailure
    * @description NA
    * @return NA
    */
    public static testMethod void testGenerateTokenFailure() {
         Map<String, blng.TransactionParameter> mapOfTransactionParameterById =
             new Map<String, blng.TransactionParameter>();
        blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__PaymentType__c = 'Credit Card';
        paymentMethod.blng__CardNumber__c = '4444444444444444';
        transactionParameter.setPaymentMethod(paymentMethod);
        mapOfTransactionParameterById.put(transactionParameter.toString(), transactionParameter);
        
        Map<String, blng.TransactionResult> result = MockGateway.generateToken(mapOfTransactionParameterById);
        validateFailureResponse(result, blng.TransactionResult.GatewayStatusType.Decline);
    }
    
    /**
    * @name testChargeTransactionCCSuccess
    * @description NA
    * @return NA
    */
    public static testMethod void testChargeTransactionCCSuccess() {
         Map<String, blng.TransactionParameter> mapOfTransactionParameterById =
             new Map<String, blng.TransactionParameter>();
        blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__PaymentType__c = 'Credit Card';
        paymentMethod.blng__CardNumber__c = '4111111111111111';
        transactionParameter.setPaymentMethod(paymentMethod);
        transactionParameter.setAmount('100');
        mapOfTransactionParameterById.put(transactionParameter.toString(), transactionParameter);
        
        Map<String, blng.TransactionResult> result = MockGateway.chargeTransaction(mapOfTransactionParameterById);
        validateSuccessResponse(CHARGETRANSACTION, result);
    }
    
    /**
    * @name testChargeTransactionCCFailure
    * @description Failure test case for new PM
    * @return NA
    */
    public static testMethod void testChargeTransactionCCFailure() {
         Map<String, blng.TransactionParameter> mapOfTransactionParameterById =
             new Map<String, blng.TransactionParameter>();
        blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__PaymentType__c = 'Credit Card';
        paymentMethod.blng__CardNumber__c = '4444444444444444';
        transactionParameter.setPaymentMethod(paymentMethod);
        mapOfTransactionParameterById.put(transactionParameter.toString(), transactionParameter);
        
        Map<String, blng.TransactionResult> result = MockGateway.chargeTransaction(mapOfTransactionParameterById);
        validateFailureResponse(result, blng.TransactionResult.GatewayStatusType.Decline);
    }
    
    /**
    * @name testChargeTransactionACHSuccess
    * @description NA
    * @return NA
    */
    public static testMethod void testChargeTransactionACHSuccess() {
         Map<String, blng.TransactionParameter> mapOfTransactionParameterById =
             new Map<String, blng.TransactionParameter>();
        blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__PaymentType__c = 'ACH';
        paymentMethod.blng__BankAccountNumber__c = '1111';
        transactionParameter.setPaymentMethod(paymentMethod);
        transactionParameter.setAmount('100');
        mapOfTransactionParameterById.put(transactionParameter.toString(), transactionParameter);
        
        Map<String, blng.TransactionResult> result = MockGateway.chargeTransaction(mapOfTransactionParameterById);
        validateSuccessResponse(CHARGETRANSACTION, result);
    }
    
    /**
    * @name testChargeTransactionACHFailure
    * @description Failure test case for saved PM
    * @return NA
    */
    public static testMethod void testChargeTransactionACHFailure() {
         Map<String, blng.TransactionParameter> mapOfTransactionParameterById =
             new Map<String, blng.TransactionParameter>();
        blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        Account testAccount = new Account();
        testAccount.name = 'Mock Gateway Test';
        insert testAccount;
        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__PaymentType__c = 'Credit Card';
        paymentMethod.blng__Account__c = testAccount.Id;
        paymentMethod.blng__PaymentType__c = 'ACH';
        paymentMethod.blng__BankAccountNumber__c = '4222';
        paymentMethod.blng__BankRoutingCode__c = '12345';
        paymentMethod.blng__BankName__c = 'ACH Bank';
        paymentMethod.blng__BankAccountType__c = 'Checking';
        paymentMethod.blng__BankAccountName__c = 'ACH Fail';
        insert paymentMethod;
        
        transactionParameter.setPaymentMethod(paymentMethod);
        transactionParameter.setAmount('1000');
        mapOfTransactionParameterById.put(transactionParameter.toString(), transactionParameter);
        
        Map<String, blng.TransactionResult> result = MockGateway.chargeTransaction(mapOfTransactionParameterById);
        validateFailureResponse(result, blng.TransactionResult.GatewayStatusType.Indeterminate);
    }
    
    /**
    * @name testRefundSuccess
    * @description NA
    * @return NA
    */
    public static testMethod void testRefundSuccess() {
         Map<String, blng.TransactionParameter> mapOfTransactionParameterById =
             new Map<String, blng.TransactionParameter>();
        blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        mapOfTransactionParameterById.put(transactionParameter.toString(), transactionParameter);
        
        Map<String, blng.TransactionResult> result = MockGateway.refundTransaction(mapOfTransactionParameterById);
        validateSuccessResponse(REFUND, result);
    }
}
